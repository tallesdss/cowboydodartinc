import 'dart:async' show unawaited;

import 'package:cowboydodartinc/core/data/models/entitlement.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/initializer/onstart_service.dart';
import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:cowboydodartinc/features/subscriptions/api/entities/subscription_entity.dart';
import 'package:cowboydodartinc/features/subscriptions/api/subscription_api.dart';
import 'package:cowboydodartinc/features/subscriptions/api/subscription_payment_api.dart';
import 'package:cowboydodartinc/features/subscriptions/api/subscription_payment_api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final subscriptionRepositoryProvider = Provider(
  (ref) => SubscriptionRepository(
    subscriptionApi: ref.watch(subscriptionApiProvider),
    inAppSubscriptionApi: ref.watch(inAppSubscriptionApiProvider),
    prefs: ref.watch(sharedPreferencesProvider).prefs,
    // remoteConfig: ref.watch(remoteConfigApiProvider),
  ),
);

const _lastAskKey = 'subscription_last_asking_date';

/// How long cached store offerings stay valid before a forced refresh.
const Duration kSubscriptionOffersCacheTtl = Duration(minutes: 15);

/// This class is responsible for managing the subscription of the user
/// It will be used to know if the user is subscribed or not and to get the subscription
/// A fake implementation of the revenue cat is used for units test see: [InAppSubscriptionApiFake]
class SubscriptionRepository implements OnStartService {
  final SubscriptionApi _subscriptionApi;

  final SubscriptionPaymentApi _inAppSubscriptionApi;

  final SharedPreferences? _prefs;

  final Logger _logger;

  /// You can use the remote config to configure the subscription module
  /// For example, you can set the number of hours between two requests to the API
  // final RemoteConfigApi? _remoteConfig;

  List<SubscriptionProduct>? _cachedOffers;
  DateTime? _offersCachedAt;
  Future<List<SubscriptionProduct>>? _inflightOffers;

  SubscriptionRepository({
    required SubscriptionApi subscriptionApi,
    required SubscriptionPaymentApi inAppSubscriptionApi,
    required SharedPreferences? prefs,
    // RemoteConfigApi? remoteConfig,
    Logger? logger,
  })  : _subscriptionApi = subscriptionApi,
        _logger = logger ?? Logger(),
        _prefs = prefs,
        // _remoteConfig = remoteConfig,
        _inAppSubscriptionApi = inAppSubscriptionApi;

  /// Last fetched default offering, if any (may be outside [kSubscriptionOffersCacheTtl]).
  List<SubscriptionProduct>? peekCachedOffers() => _cachedOffers;

  /// Cached offerings only when still within [kSubscriptionOffersCacheTtl].
  List<SubscriptionProduct>? peekFreshCachedOffers() {
    if (!isOffersCacheFresh) {
      return null;
    }
    return _cachedOffers;
  }

  bool get isOffersCacheFresh {
    final cachedAt = _offersCachedAt;
    if (_cachedOffers == null || cachedAt == null) {
      return false;
    }
    return DateTime.now().difference(cachedAt) < kSubscriptionOffersCacheTtl;
  }

  void invalidateOffersCache() {
    _cachedOffers = null;
    _offersCachedAt = null;
  }

  @override
  Future<void> init() async {
    try {
      // We must init the subscription API
      await _inAppSubscriptionApi.init();
      // Warm offerings so paywalls can render prices without a blank loading screen.
      unawaited(_fetchAndCacheOffers());
    } catch (e) {
      _logger.w('''
        Revenuecat seems not to be initialized. 
        👉 Please check that you have setup your account on https://revenuecat.com
        And that you have added your token in the environment file or variable (see lib/environments.dart)
        or
        👉 Remove completely the subscription module if you don't need it
      ''');
    }
  }

  // We use a custom subscriber id to be able to identify the user
  Future<void> initUser(String userId) async {
    await _inAppSubscriptionApi.initUser(userId);
    
  }

  /// We get the subscription of the user
  /// We fetch the subscription from our own API and not directly from RevenueCat
  /// So we can grant some free subscription to users easily
  /// Either you can uncomment the code to directly check from RevenueCat
  Future<Subscription> get(String userId) async {
    final entity = await _subscriptionApi.get(userId);
    final subscription = Subscription.fromEntity(
      entity,
      lastAskingDate,
    );
    if (subscription.isActive) {
      final entitlements = await _inAppSubscriptionApi.getEntitlements();
      final product = await _inAppSubscriptionApi.getFromProductId(
        entity!.skuId,
      );

      // When the payment provider has no entitlement data (e.g. Stripe returns
      // an empty list), synthesize one from the backend entity so the UI can
      // show trial status, expiration date and renewal info.
      final effectiveEntitlements =
          (entitlements == null || entitlements.isEmpty)
          ? _entitlementsFromEntity(entity)
          : entitlements;

      return switch(subscription) {
        final SubscriptionStateData active => active.copyWith(
          activeOffer: product,
          entitlements: effectiveEntitlements,
        ),
        _ => subscription,
      };
    }
    // RC fallback: backend has no active record (webhook may not have arrived yet).
    // RevenueCat is the source of truth for purchases — consult it before
    // marking the user as inactive.
    final rcEntitlements = await _inAppSubscriptionApi.getEntitlements();
    if (rcEntitlements != null && rcEntitlements.isNotEmpty) {
      _logger.i(
        'No active backend subscription — RevenueCat reports active entitlements. '
        'Treating as active (webhook likely delayed).',
      );
      return Subscription.active(entitlements: rcEntitlements);
    }
    return subscription;
  }

  List<Entitlement> _entitlementsFromEntity(SubscriptionEntity entity) {
    final now = DateTime.now();
    final trialEnd = entity.trialEnd;
    final isInTrial = trialEnd != null && trialEnd.isAfter(now);
    final willRenew = entity.status != SubscriptionStatus.CANCELLED;
    return [
      Entitlement(
        identifier: entity.skuId,
        isInTrial: isInTrial,
        willRenew: willRenew,
        expirationDate: isInTrial ? trialEnd : entity.periodEndDate,
      ),
    ];
  }

  // We can have multiple offers (BASIC MONTH, BASIC YEAR, GOLD MONTH, GOLD YEAR, ...)
  Future<List<SubscriptionProduct>> getOffers({
    String? offerId,
    bool forceRefresh = false,
  }) {
    if (offerId != null) {
      return _inAppSubscriptionApi.getOffers(offerId);
    }
    if (!forceRefresh && isOffersCacheFresh && _cachedOffers != null) {
      return Future.value(_cachedOffers!);
    }
    return _fetchAndCacheOffers();
  }

  /// Refreshes the default offering and updates the in-memory cache.
  Future<List<SubscriptionProduct>> refreshOffers() {
    return getOffers(forceRefresh: true);
  }

  /// Loads the latest store product for [skuId] before starting checkout.
  Future<SubscriptionProduct> resolveOfferForPurchase(String skuId) async {
    final offers = await refreshOffers();
    for (final offer in offers) {
      if (offer.skuId == skuId) {
        return offer;
      }
    }
    throw SubscriptionOfferUnavailableException(skuId);
  }

  Future<List<SubscriptionProduct>> _fetchAndCacheOffers() {
    final inflight = _inflightOffers;
    if (inflight != null) {
      return inflight;
    }
    final future = _inAppSubscriptionApi.getOffers(null).then((offers) {
      _cachedOffers = offers;
      _offersCachedAt = DateTime.now();
      _inflightOffers = null;
      return offers;
    }).catchError((Object err, StackTrace stack) {
      _inflightOffers = null;
      Error.throwWithStackTrace(err, stack);
    });
    _inflightOffers = future;
    return future;
  }

  // We check if the user has a permission
  // This allows us to add multiple permissions within subscription
  // If you want only have a single premium subscription, you can create a single permission 'premium'
  Future<bool> checkPermission(String permissionToCheck) async {
    final permissions = await _inAppSubscriptionApi.getPermissions();
    final hasPermission = permissions.any(
      (e) => e.identifier == permissionToCheck && e.isActive,
    );
    if (!hasPermission) throw Exception("Permission denied: $permissionToCheck");
    return true;
  }

  /// The purchase method is used to buy a subscription or a product.
  /// The concrete provider ([RevenueCatPaymentApi] on mobile, StripePaymentApi
  /// on web) handles the platform specifics and throws
  /// [UserCancelledPurchaseException] when the user cancels.
  Future<List<Entitlement>?> purchase(SubscriptionProduct product) async {
    final liveProduct = await resolveOfferForPurchase(product.skuId);
    await _inAppSubscriptionApi.purchaseProduct(liveProduct);
    invalidateOffersCache();
    return _inAppSubscriptionApi.getEntitlements();
  }

  /// Unsubscribe / manage the subscription.
  /// [origin] is where the subscription was purchased; the provider opens the
  /// correct management flow (store page or Stripe portal) only when allowed on
  /// the current platform.
  Future<void> unsubscribe(SubscriptionStore? origin) async {
    await _inAppSubscriptionApi.unsubscribe(origin);
  }

  /// Restore a previous purchase
  /// For ex if the user has changed his phone
  /// he can restore his previous purchase
  Future<void> restorePurchase() async {
    await _inAppSubscriptionApi.restorePurchase();
    invalidateOffersCache();
  }

  /// iOS-only: present the offer-code redemption sheet.
  Future<void> presentCodeRedemptionSheet() async {
    await _inAppSubscriptionApi.presentCodeRedemptionSheet();
  }

  /// Save the last time we showed the subscription paywall
  Future<void> saveLastAskingDate() async {
    if (_prefs == null) return;
    final now = DateTime.now();
    await _prefs.setInt(_lastAskKey, now.millisecondsSinceEpoch);
  }

  /// Get the last time we showed the subscription paywall
  DateTime? get lastAskingDate {
    final lastAsk = _prefs?.getInt(_lastAskKey);
    if (lastAsk == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(lastAsk);
  }
}

class SubscriptionOfferUnavailableException implements Exception {
  final String skuId;

  SubscriptionOfferUnavailableException(this.skuId);

  @override
  String toString() => 'Subscription offer unavailable: $skuId';
}
