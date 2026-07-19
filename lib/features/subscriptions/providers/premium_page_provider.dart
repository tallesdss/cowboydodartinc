import 'dart:async' show unawaited;

import 'package:cowboydodartinc/core/data/api/analytics_api.dart';
import 'package:cowboydodartinc/core/data/models/entitlement.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/states/models/user_state.dart';
import 'package:cowboydodartinc/core/states/translations.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/toast/toast_service.dart';
import 'package:cowboydodartinc/features/feedbacks/repositories/feature_request_repository.dart';
import 'package:cowboydodartinc/features/subscriptions/api/subscription_payment_api.dart'
    show PendingWebCheckoutException, UserCancelledPurchaseException;
import 'package:cowboydodartinc/features/subscriptions/providers/models/premium_state.dart';
import 'package:cowboydodartinc/features/subscriptions/repositories/subscription_repository.dart';
import 'package:cowboydodartinc/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'premium_page_provider.g.dart';

@Riverpod()
class PremiumStateNotifier extends _$PremiumStateNotifier {
  final Logger _logger = Logger();

  UserState get _userState => ref.read(userStateNotifierProvider);

  SubscriptionRepository get _subscriptionRepository =>
      ref.read(subscriptionRepositoryProvider);

  AnalyticsApi? get _analyticsApi => ref.read(analyticsApiProvider);

  @override
  Future<PremiumState> build({bool preview = false}) async {
    // Admin preview (opened from the Debug screen just to look at the paywall):
    // always load the offers so the admin sees the real paywall design, even if
    // they personally hold an active subscription. Skipping the active
    // short-circuit is what keeps the preview on the offers screen instead of
    // bouncing to the "manage your subscription" view. Real side effects
    // (purchase/restore) are suppressed in [PremiumPage] when preview is on.
    //
    // A user who already has an active subscription must ALWAYS land on the
    // "subscribed" state, even if the offer list fails to load. On web the
    // offers come from Stripe and the fetch can transiently fail; without this
    // early return a paying user would wrongly see the empty-products paywall
    // and "lose" the confirmation that they paid. The active view
    // ([ActivePremiumContent]) does not need the offer list.
    final currentSubscription = _userState.subscription;
    if (!preview && currentSubscription is SubscriptionStateData) {
      return PremiumState.active(activeOffer: currentSubscription.activeOffer);
    }

    try {
      final fresh = _subscriptionRepository.peekFreshCachedOffers();
      if (fresh != null && fresh.isNotEmpty) {
        unawaited(_refreshOffersInBackground());
        return PremiumState(offers: fresh, selectedOffer: fresh.first);
      }

      final hasStaleCache =
          _subscriptionRepository.peekCachedOffers()?.isNotEmpty ?? false;
      return await _loadOffers(forceRefresh: hasStaleCache);
    } catch (err, stack) {
      // RevenueCat CONFIGURATION_ERROR (code 23) means the products exist in the
      // dashboard but aren't live on the store yet (e.g. "Ready to Submit").
      // This is expected before the first app submission — skip Sentry noise.
      final isConfigError = err is PlatformException &&
          (err.details as Map?)?['readableErrorCode'] == 'CONFIGURATION_ERROR';
      if (isConfigError) {
        _logger.w(
          'RevenueCat CONFIGURATION_ERROR: products not yet live on App Store. '
          'Showing empty paywall state.',
        );
      } else {
        await Sentry.captureException(err, stackTrace: stack);
        _logger.e(
          '...PremiumStateNotifier: init failed, '
          '👉 Make sure you have properly setup subscription '
          'following our guide (https://kasy.dev/docs/funcionalidades/revenuecat) '
          '$err --> $stack',
          stackTrace: stack,
        );
      }
      return const PremiumStateData(offers: []);
    }
  }

  Future<PremiumState> _loadOffers({bool forceRefresh = false}) async {
    final offers = await _subscriptionRepository.getOffers(
      forceRefresh: forceRefresh,
    );
    if (offers.isEmpty) {
      _logger.w(
        'The store returned no subscription offers. The paywall will show '
        'an empty-products state instead of a blank screen.',
      );
      return const PremiumState(offers: []);
    }
    return PremiumState(offers: offers, selectedOffer: offers.first);
  }

  Future<void> _refreshOffersInBackground() async {
    try {
      final offers = await _subscriptionRepository.refreshOffers();
      if (!ref.mounted || offers.isEmpty) {
        return;
      }
      final current = state.value;
      if (current is! PremiumStateData) {
        return;
      }
      state = AsyncData(
        current.copyWith(
          offers: offers,
          selectedOffer: _resolveSelectedOffer(current.selectedOffer, offers),
        ),
      );
    } catch (err, stack) {
      _logger.w('Background offers refresh failed: $err', stackTrace: stack);
    }
  }

  SubscriptionProduct? _resolveSelectedOffer(
    SubscriptionProduct? current,
    List<SubscriptionProduct> offers,
  ) {
    if (offers.isEmpty) {
      return null;
    }
    if (current == null) {
      return offers.first;
    }
    for (final offer in offers) {
      if (offer.skuId == current.skuId) {
        return offer;
      }
    }
    return offers.first;
  }

  Future<void> startCoupon() async {
    if (TargetPlatform.iOS != defaultTargetPlatform) {
      return;
    }
    await _subscriptionRepository.presentCodeRedemptionSheet();
  }

  void selectOffer(SubscriptionProduct offer) {
    if (state.value == null) {
      throw "cannot select offer";
    }
    final newState = switch (state.value!) {
      final PremiumStateData el => el.copyWith(selectedOffer: offer),
      final PremiumStateActive el => el.copyWith(activeOffer: offer),
      _ => null,
    };
    if (newState == null) {
      throw "cannot select offer";
    }
    state = AsyncValue.data(newState);
  }

  Future<void> purchase({String? paywall, String? redirectRoute}) async {
    if (state.value is! PremiumStateData) {
      throw "cannot purchase without offers";
    }
    final offer = state.value?.selectedOffer;
    if (offer == null) {
      throw "cannot purchase without selected offer";
    }
    await purchaseOffer(offer, paywall: paywall, redirectRoute: redirectRoute);
  }

  Future<void> purchaseOffer(
    SubscriptionProduct offer, {
    String? paywall,
    String? redirectRoute,
  }) async {
    final currentOffers = switch (state.value) {
      PremiumStateData(:final offers) => offers,
      _ => throw "cannot purchase while active",
    };
    state = AsyncData(
      PremiumState.sending(isPremium: false, offers: currentOffers, selectedOffer: offer),
    );
    try {
      final entitlements = await _subscriptionRepository.purchase(offer);
      await _activateAfterPurchase(offer, entitlements, paywall, redirectRoute);
    } on PendingWebCheckoutException {
      // Stripe web: checkout opened in a new tab. Poll until the webhook
      // activates the subscription or we time out.
      await _waitForWebPayment(offer, currentOffers, paywall: paywall, redirectRoute: redirectRoute);
    } catch (err, stackTrace) {
      state = AsyncData(PremiumState(offers: currentOffers, selectedOffer: offer));
      if (err is UserCancelledPurchaseException) return;
      if (err is SubscriptionOfferUnavailableException) {
        _subscriptionRepository.invalidateOffersCache();
        final t = ref.read(translationsProvider);
        ref.read(toastProvider).error(
          title: t.premium.error_title,
          text: t.premium.error_text,
        );
        return;
      }
      await Sentry.captureException(err, stackTrace: stackTrace);
      _logger.e("...PremiumStateNotifier: purchase failed $err : $stackTrace");
      final t = ref.read(translationsProvider);
      ref.read(toastProvider).error(
        title: t.premium.error_title,
        text: t.premium.error_text,
        reason: "We were unable to process your subscription",
      );
    }
  }

  Future<void> _activateAfterPurchase(
    SubscriptionProduct offer,
    List<Entitlement>? entitlements,
    String? paywall,
    String? redirectRoute,
  ) async {
    state = AsyncData(PremiumState.active(activeOffer: offer));
    await _analyticsApi?.logEvent("purchase", {
      "skuId": offer.skuId,
      "price": offer.price,
      "duration": offer.duration,
      "paywall": paywall,
    });
    await ref
        .read(userStateNotifierProvider.notifier)
        .refreshSubscription(product: offer, entitlements: entitlements);
    final t = ref.read(translationsProvider);
    ref.read(toastProvider).success(
      title: t.premium.purchase_success_title,
      text: t.premium.purchase_success_text,
    );
    await Future.delayed(const Duration(seconds: 2));
    if (redirectRoute != null) ref.read(goRouterProvider).go(redirectRoute);
  }

  /// Polls the subscription backend every 5 s until the Stripe webhook delivers
  /// the activation (up to 10 min). Runs while the state is [PremiumStateSending].
  Future<void> _waitForWebPayment(
    SubscriptionProduct offer,
    List<SubscriptionProduct> currentOffers, {
    String? paywall,
    String? redirectRoute,
  }) async {
    const maxAttempts = 120; // 10 min at 5 s intervals
    const interval = Duration(seconds: 5);
    final userId = _userState.user.idOrNull;
    if (userId == null) {
      state = AsyncData(PremiumState(offers: currentOffers, selectedOffer: offer));
      return;
    }

    try {
      for (var i = 0; i < maxAttempts; i++) {
        await Future.delayed(interval);
        if (state.value is! PremiumStateSending) return;
        try {
          final sub = await _subscriptionRepository.get(userId);
          if (sub.isActive) {
            await _activateAfterPurchase(offer, null, paywall, redirectRoute);
            return;
          }
        } catch (_) {
          // network / backend error → keep polling; disposal propagates to
          // the outer catch on the next state.value access.
        }
      }

      // Timed out — revert to paywall and ask the user to restore if they paid.
      if (state.value is PremiumStateSending) {
        state = AsyncData(PremiumState(offers: currentOffers, selectedOffer: offer));
        final t = ref.read(translationsProvider);
        ref.read(toastProvider).error(
          title: t.premium.web_checkout_timeout_title,
          text: t.premium.web_checkout_timeout_text,
        );
      }
    } catch (_) {
      // Provider was disposed while polling (user left the paywall). Ignore.
    }
  }

  Future<void> unsubscribe() async {
    // _analytics.logPageOpened("launch_unsubscribe_page");
    // Route by the subscription's origin (store). The UI only reaches here when
    // the subscription can be managed on the current platform; the cross-platform
    // case is handled with an info dialog before this is called.
    final store = _userState.subscription?.store;
    await _subscriptionRepository.unsubscribe(store);
  }

  Future<void> saveUnsubscribeReason(String reason) async {
    try {
      final userId = _userState.user.idOrNull;
      if (userId == null) return;
      await ref
          .read(featureRequestRepositoryProvider)
          .createNewFeatureSuggestion(
            userId: userId,
            title: "unsubscribed",
            description: reason,
          );
      _logger.i('👉 Unsubscribe reason saved successfully');
    } catch (err, stackTrace) {
      _logger.e('👉 Error saving unsubscribe reason: $err : $stackTrace');
      await Sentry.captureException(err, stackTrace: stackTrace);
      // Don't rethrow as we don't want to block the unsubscribe process
    }
  }

  Future<void> restore({String? redirectRoute}) async {
    if (state.value is! PremiumStateData) {
      throw "cannot restore while active";
    }
    final data = state.value! as PremiumStateData;

    // Only enter loading state when there are offers to display; with an empty
    // offer list the paywall already shows the empty-state UI.
    if (data.offers.isNotEmpty) {
      state = AsyncData(
        PremiumState.sending(
          isPremium: false,
          offers: data.offers,
          selectedOffer: data.selectedOffer,
        ),
      );
    }

    try {
      // Store-level restore: RevenueCat on native (asks Apple/Google to restore
      // purchases), a no-op on web (Stripe status lives server-side). Best-effort
      // — RevenueCat throws when there is nothing to restore, but the backend
      // re-read below is the source of truth and decides the message, so both
      // web and native end on the same friendly "nothing to restore" path.
      try {
        await _subscriptionRepository.restorePurchase();
      } catch (_) {
        // Ignore: fall through to the backend check.
      }

      // Re-read the backend to learn the real state: the webhook may have
      // already written the subscription. Only flip to active when the backend
      // actually confirms it — otherwise we'd show a false "restored" success.
      final userId = _userState.user.idOrNull;
      final restored = userId == null
          ? null
          : await _subscriptionRepository.get(userId);
      final t = ref.read(translationsProvider);

      if (restored is SubscriptionStateData && restored.isActive) {
        await ref
            .read(userStateNotifierProvider.notifier)
            .refreshSubscription(
              product: restored.activeOffer,
              entitlements: restored.entitlements,
            );
        state = AsyncData(
          PremiumState.active(activeOffer: restored.activeOffer),
        );
        ref.read(toastProvider).success(
          title: t.premium.restore_success_title,
          text: t.premium.restore_success_text,
        );
        await Future.delayed(const Duration(seconds: 2));
        if (redirectRoute != null) ref.read(goRouterProvider).go(redirectRoute);
        return;
      }

      // Nothing to restore: revert to the paywall and tell the user, instead of
      // a misleading success toast.
      state = AsyncData(
        PremiumStateData(offers: data.offers, selectedOffer: data.selectedOffer),
      );
      ref.read(toastProvider).alert(
        title: t.premium.restore_none_title,
        text: t.premium.restore_none_text,
      );
    } catch (err, trace) {
      _logger.e("Error while restoring purchase: $err : $trace");
      state = AsyncData(
        PremiumStateData(offers: data.offers, selectedOffer: data.selectedOffer),
      );
      final t = ref.read(translationsProvider);
      ref
          .read(toastProvider)
          .error(
            title: t.premium.error_title,
            text: t.premium.error_text,
            reason: "We were unable to restore your subscription",
          );
    }
  }
}

class SubscriptionException implements Exception {
  final String message;

  SubscriptionException(this.message);
}
