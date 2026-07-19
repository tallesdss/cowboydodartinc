import 'package:cowboydodartinc/core/data/api/analytics_api.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/toast/toast_service.dart';
import 'package:cowboydodartinc/features/subscriptions/providers/models/premium_state.dart';
import 'package:cowboydodartinc/features/subscriptions/providers/premium_page_provider.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/active_premium_content.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_empty_state.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PremiumPageArgs {
  // The redirect route to navigate to after the purchase
  final String? redirect;
  // The delay to show the close button
  final int? delayCloseMs;
  // Whether to show the trial bottom sheet when the user skip the purchase
  final bool? showTrialBottomSheet;

  const PremiumPageArgs({
    this.redirect,
    this.delayCloseMs,
    this.showTrialBottomSheet = false,
  });
}

/// The premium page is the page where the user can subscribe to the premium offer
/// It's also named as Paywall
///
/// - This page is responsible for displaying the offers or the active subscription
/// - It also handles the purchase and restore of the subscription
/// - It also handles the redirection after the purchase see [PremiumPageArgs]
class PremiumPage extends ConsumerWidget {
  final PremiumPageArgs? args;
  final PaywallFactory? paywall;

  /// Preview mode: the paywall is opened from the admin Debug screen just to
  /// review the design. The offers screen is always shown (even for an admin
  /// who already subscribed) and the purchase/restore actions are suppressed so
  /// the admin never starts a real transaction. See [PremiumStateNotifier].
  final bool preview;

  const PremiumPage({
    super.key,
    this.args,
    this.paywall,
    this.preview = false,
  });

  bool get hasRedirect => args?.redirect != null;

  void _handleRedirection(BuildContext context) {
    if (hasRedirect) {
      context.go(args!.redirect!);
    }
  }

  PremiumStateNotifier getNotifier(WidgetRef ref) =>
      ref.read(premiumStateProvider(preview: preview).notifier);

  /// In preview the buy/restore buttons must not trigger a real transaction.
  /// Show a short note instead so the admin knows the action is intentionally
  /// disabled rather than broken.
  void _notifyPreviewDisabled(WidgetRef ref) {
    ref.read(toastProvider).alert(
      title: t.premium.preview_disabled_title,
      text: t.premium.preview_disabled_text,
    );
  }

  void _exitPaywall(BuildContext context, WidgetRef ref) {
    if (!preview) {
      ref.read(analyticsApiProvider).logEvent('premium_exit', {});
    }
    if (hasRedirect) {
      _handleRedirection(context);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  Widget _buildPaywall({
    required BuildContext context,
    required WidgetRef ref,
    required PaywallFactory paywallFactory,
    required List<SubscriptionProduct> offers,
    required SubscriptionProduct? selectedOffer,
    required bool isLoadingOffers,
  }) {
    return paywallFactory.build(
      offers: offers,
      selectedOffer: selectedOffer,
      isLoadingOffers: isLoadingOffers,
      onSelectItem: isLoadingOffers
          ? (_) {}
          : (offer) => getNotifier(ref).selectOffer(offer),
      onSkip: () => _exitPaywall(context, ref),
      onTapRestore: isLoadingOffers
          ? null
          : () => preview
              ? _notifyPreviewDisabled(ref)
              : getNotifier(ref).restore(redirectRoute: args?.redirect),
      onTap: isLoadingOffers
          ? null
          : () => preview
              ? _notifyPreviewDisabled(ref)
              : getNotifier(ref).purchase(
                  paywall: paywallFactory.name,
                  redirectRoute: args?.redirect,
                ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumStateProvider(preview: preview));
    final paywallFactory = paywall ?? PaywallFactory.unlock;

    if (premiumState.isLoading && !premiumState.hasValue) {
      final hasActiveSubscription = !preview &&
          ref.read(userStateNotifierProvider).subscription
              is SubscriptionStateData;
      if (!hasActiveSubscription) {
        return _buildPaywall(
          context: context,
          ref: ref,
          paywallFactory: paywallFactory,
          offers: const [],
          selectedOffer: null,
          isLoadingOffers: true,
        );
      }
    }

    return switch (premiumState) {
      AsyncError() => Center(child: Text(t.premium.error_loading)),
      AsyncLoading() => const SizedBox.shrink(),
      AsyncData(:final value) => switch (value) {
        final PremiumStateActive _ => ActivePremiumContent(
          onTap: (String reason) async {
            await getNotifier(ref).saveUnsubscribeReason(reason);
            await getNotifier(ref).unsubscribe();
          },
          onExit: () {
            if (hasRedirect) {
              _handleRedirection(context);
            } else if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        final PremiumStateSending data => paywallFactory.buildSending(
          offers: data.offers,
          selectedOffer: data.selectedOffer,
          onSelectItem: (offer) => getNotifier(ref).selectOffer(offer),
        ),
        PremiumStateData(offers: final offers) when offers.isEmpty =>
          PaywallEmptyState(
            onSkip: () {
              if (!preview) {
                ref
                    .read(analyticsApiProvider)
                    .logEvent('premium_empty_exit', {});
              }
              if (hasRedirect) {
                _handleRedirection(context);
              } else if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            onTapRestore: () => preview
                ? _notifyPreviewDisabled(ref)
                : getNotifier(ref).restore(redirectRoute: args?.redirect),
          ),
        final PremiumStateData data => _buildPaywall(
          context: context,
          ref: ref,
          paywallFactory: paywallFactory,
          offers: data.offers,
          selectedOffer: data.selectedOffer,
          isLoadingOffers: false,
        ),
      },
    };
  }
}
