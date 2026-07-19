import 'package:cowboydodartinc/core/data/models/entitlement.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/environments.dart';
import 'package:cowboydodartinc/features/subscriptions/api/entities/subscription_entity.dart';
import 'package:cowboydodartinc/features/subscriptions/api/revenuecat_product.dart';
import 'package:cowboydodartinc/features/subscriptions/api/subscription_payment_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:logger/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';

// We chose to use RevenueCat for in-app subscription (mobile: App Store / Play
// Store). Web subscriptions are handled by the separate Stripe module via
// [StripePaymentApi]; both implement [SubscriptionPaymentApi].
// ---
// We wrap the RevenueCat API to be able to fake it properly (Glassfy use static methods which are hard for tests)
class RevenueCatPaymentApi implements SubscriptionPaymentApi {
  bool _hasInit = false;
  final Environment _environment;

  RevenueCatPaymentApi({required Environment environment})
    : _environment = environment;

  /// RevenueCat "Test Store" public keys start with `test_`. The native SDK
  /// refuses them in release builds (TestFlight / App Store) and shows a fatal
  /// alert. Skip [Purchases.configure] until a production key is provided.
  static bool isRevenueCatTestStorePublicKey(String? key) {
    if (key == null || key.isEmpty) return false;
    return key.startsWith('test_');
  }

  String? _apiKeyForCurrentPlatform() {
    if (Platform.isAndroid) {
      return _environment.revenueCatAndroidApiKey;
    }
    if (Platform.isIOS) {
      return _environment.revenueCatIOSApiKey;
    }
    return null;
  }

  bool _mustSkipConfigureDueToSandboxKeyInRelease() {
    if (!kReleaseMode) return false;
    final String? key = _apiKeyForCurrentPlatform();
    return isRevenueCatTestStorePublicKey(key);
  }

  /// Map a RevenueCat [EntitlementInfo] to the provider-agnostic [Entitlement].
  Entitlement _toEntitlement(EntitlementInfo e) => Entitlement(
    identifier: e.identifier,
    isActive: e.isActive,
    isInTrial: e.periodType == PeriodType.trial,
    willRenew: e.willRenew,
    productId: e.productIdentifier,
    expirationDate: e.expirationDate != null
        ? DateTime.tryParse(e.expirationDate!)
        : null,
  );

  @override
  Future<void> init() async {
    // RevenueCat is mobile-only (Android/iOS). Web subscriptions are handled by
    // the Stripe module when present; never configure RevenueCat on web.
    if (kIsWeb) return;
    if (!_environment.isRevenueCatConfigured) {
      Logger().w('=== RevenueCat API key not provided ===');
      Logger().w(
        'Dont forget to set RC_ANDROID_API_KEY and RC_IOS_API_KEY within your environments.dart file',
      );
      return;
    }
    if (_mustSkipConfigureDueToSandboxKeyInRelease()) {
      Logger().w(
        'RevenueCat sandbox/test public key in a release build — skipping '
        'Purchases.configure (SDK would otherwise show a fatal alert). '
        'Use the App Store / Play Store public API key from the RevenueCat '
        'dashboard for TestFlight and production.',
      );
      return;
    }
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(
        _environment.revenueCatAndroidApiKey!,
      );
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_environment.revenueCatIOSApiKey!);
    } else {
      throw Exception("Unsupported platform");
    }
    await Purchases.configure(configuration);
    _hasInit = true;
  }

  // We use a custom subscriber id to be able to identify the user
  @override
  Future<void> initUser(String userId) async {
    if (kDebugMode && !_environment.isRevenueCatConfigured) {
      Logger().w('=== RevenueCat API key not provided ===');
      Logger().w(
        'Dont forget to set RC_ANDROID_API_KEY and RC_IOS_API_KEY within your environments.dart file',
      );
      return;
    }
    if (!_hasInit) {
      return;
    }

    await Purchases.logIn(userId);
  }

  // We can dissociate the user from the subscription
  @override
  Future<void> disconnectUser() async {
    if (!_hasInit) {
      return;
    }
    await Purchases.logOut();
  }

  @override
  Future<List<SubscriptionProduct>> getOffers(String? offerId) async {
    if (kDebugMode && !_environment.isRevenueCatConfigured) {
      Logger().d(
        '=== RevenueCatPaymentApi.getOffers: returning fake offers ===',
      );
      Logger().d(
        'Dont forget to set RC_ANDROID_API_KEY and RC_IOS_API_KEY within your environments.dart file',
      );

      return SubscriptionProductAdapter(
        // ignore: prefer_const_constructors
        offering: Offering('fake-offer', 'lorem ipsum', const {}, const [
          Package(
            'fake-month-package',
            PackageType.monthly,
            StoreProduct(
              'pro.monthly.testsku',
              'Premium Monthly Subscription', // description
              'Monthly', // title
              9.99, // price
              r'$9.99', // priceString
              'USD', // currencyCode
              productCategory: ProductCategory.subscription,
              subscriptionPeriod: 'P1M', // 1 month (ISO 8601)
            ),
            PresentedOfferingContext('fake-offer', null, null),
          ),
          Package(
            'fake-annual-package',
            PackageType.annual,
            StoreProduct(
              'pro.annual.testsku',
              'Premium Annual Subscription', // description
              'Annual', // title
              99.99, // price
              r'$99.99', // priceString
              'USD', // currencyCode
              productCategory: ProductCategory.subscription,
              subscriptionPeriod: 'P1Y', // 1 year (ISO 8601)
              introductoryPrice: IntroductoryPrice(
                0.0, // price
                r'$0.00', // priceString
                'P3D', // period (ISO 8601)
                1, // cycles
                PeriodUnit.day,
                3, // periodNumberOfUnits
              ),
            ),
            PresentedOfferingContext('fake-offer', null, null),
          ),
        ]),
      ).transform();
    }
    if (!_hasInit) {
      return [];
    }
    final offers = await Purchases.getOfferings();
    Logger().i(
      'RevenueCat offerings fetched: current=${offers.current?.identifier}, '
      'currentPackages=${offers.current?.availablePackages.length ?? 0}, '
      'allOfferings=${offers.all.map((key, value) => MapEntry(key, value.availablePackages.length))}',
    );
    var offer = offers.current;
    if (offerId != null) {
      offer = offers.getOffering(offerId);
    }
    return SubscriptionProductAdapter(offering: offer).transform();
  }

  Future<void> purchase(StoreProduct storeProduct) {
    if (!_hasInit) {
      throw StateError(
        'RevenueCat is not configured (missing or sandbox API key in release).',
      );
    }
    final purchaseParams = PurchaseParams.storeProduct(storeProduct);
    return Purchases.purchase(purchaseParams);
  }

  Future<void> purchasePackage(Package package) {
    if (!_hasInit) {
      throw StateError(
        'RevenueCat is not configured (missing or sandbox API key in release).',
      );
    }
    final purchaseParams = PurchaseParams.package(package);
    return Purchases.purchase(purchaseParams);
  }

  @override
  Future<void> purchaseProduct(SubscriptionProduct product) async {
    if (product is! RevenueCatProduct) {
      throw ArgumentError(
        'RevenueCatPaymentApi can only purchase a RevenueCatProduct',
      );
    }
    try {
      await purchasePackage(product.revenueCatPackage);
    } on PlatformException catch (e) {
      final error = PurchasesErrorHelper.getErrorCode(e);
      if (error == PurchasesErrorCode.purchaseCancelledError) {
        throw UserCancelledPurchaseException();
      }
      rethrow;
    }
  }

  @override
  Future<void> presentCodeRedemptionSheet() {
    if (TargetPlatform.iOS != defaultTargetPlatform) {
      throw "Only available on iOS";
    }
    if (!_hasInit) {
      return Future<void>.value();
    }
    return Purchases.presentCodeRedemptionSheet();
  }

  @override
  Future<void> unsubscribe(SubscriptionStore? origin) async {
    // RevenueCat only manages App Store / Play Store subscriptions, and only on
    // the matching device. The caller (provider) already decided this is the
    // right place to manage; here we just open the current platform's store.
    if (Platform.isAndroid) {
      launchUrl(
        Uri.parse("https://play.google.com/store/account/subscriptions"),
      );
    } else if (Platform.isIOS) {
      launchUrl(
        Uri.parse("https://apps.apple.com/account/subscriptions"),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception("Unsupported platform");
    }
  }

  Future<List<Package>> getLastPurchase() async {
    if (!_hasInit) {
      return [];
    }
    final customerInfo = await Purchases.getCustomerInfo();
    final purchases = customerInfo.allPurchasedProductIdentifiers;

    if (purchases.isEmpty) {
      return [];
    }
    final List<Package> result = [];
    final offers = await Purchases.getOfferings();
    for (final offerKey in offers.all.keys) {
      if (offers.all[offerKey]?.availablePackages == null) {
        continue;
      }
      for (final element in offers.all[offerKey]!.availablePackages) {
        if (purchases.contains(element.storeProduct.identifier)) {
          result.add(element);
        }
      }
    }
    return result;
  }

  @override
  Future<SubscriptionProduct?> getFromProductId(String productId) async {
    if (!_hasInit) {
      return null;
    }
    final offers = await Purchases.getOfferings();
    for (final offerKey in offers.all.keys) {
      if (offers.all[offerKey]?.availablePackages == null) {
        continue;
      }
      for (final element in offers.all[offerKey]!.availablePackages) {
        if (element.storeProduct.identifier == productId) {
          return RevenueCatProduct(
            revenueCatOffer: offers.all[offerKey]!,
            revenueCatPackage: element,
          );
        }
      }
    }
    return null;
  }

  Future<List<SubscriptionProduct>> getActiveSubscription() async {
    if (!_hasInit) {
      return [];
    }
    final List<SubscriptionProduct> products = [];

    final customerInfo = await Purchases.getCustomerInfo();
    final subscriptions = customerInfo.activeSubscriptions;
    if (subscriptions.isEmpty) {
      return [];
    }
    final List<(Offering, Package)> result = [];
    final offers = await Purchases.getOfferings();
    for (final offerKey in offers.all.keys) {
      if (offers.all[offerKey]?.availablePackages == null) {
        continue;
      }
      final offer = offers.all[offerKey]!;
      for (final element in offer.availablePackages) {
        if (subscriptions.contains(element.storeProduct.identifier)) {
          result.add((offer, element));
        }
      }
    }

    for (final element in result) {
      products.add(
        RevenueCatProduct(
          revenueCatOffer: element.$1,
          revenueCatPackage: element.$2,
        ),
      );
    }
    return products;
  }

  @override
  Future<void> restorePurchase() async {
    if (kIsWeb) {
      // Restore is not supported on web for RevenueCat. Return without error.
      return;
    }
    if (!_hasInit) {
      return;
    }
    final restoredInfo = await Purchases.restorePurchases();
    if (restoredInfo.entitlements.all.isEmpty) {
      throw Exception("No purchase to restore");
    }
  }

  @override
  Future<List<Entitlement>> getPermissions() async {
    if (!_hasInit) {
      return [];
    }
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.active.values
        .map(_toEntitlement)
        .toList();
  }

  @override
  Future<List<Entitlement>?> getEntitlements() async {
    if (!_hasInit) {
      return [];
    }
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.active.values
        .map(_toEntitlement)
        .toList();
  }
}

class SubscriptionProductAdapter {
  final Offering? _offering;

  SubscriptionProductAdapter({required Offering? offering})
    : _offering = offering;

  List<SubscriptionProduct> transform() {
    try {
      final List<SubscriptionProduct> products = [];
      // final offer = _offerings.current;
      if (_offering == null) {
        throw Exception('No offer found');
      }
      for (final package in _offering.availablePackages) {
        products.add(
          RevenueCatProduct(
            revenueCatOffer: _offering,
            revenueCatPackage: package,
          ),
        );
      }
      return products;
    } catch (e, s) {
      Logger().e(e, stackTrace: s);
      rethrow;
    }
  }
}
