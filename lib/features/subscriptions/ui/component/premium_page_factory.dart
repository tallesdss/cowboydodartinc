import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_solo.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_trial.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_unlock.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/selectable_row.dart';
import 'package:flutter/material.dart';

typedef OnTapSubscription = void Function();

typedef OnTap = void Function();

/// Factory for the four subscription paywall layouts shipped with the kit.
///
/// | Id | Use case | Kit rebrand |
/// |----|----------|-------------|
/// | [solo] | Single plan | No. Creative skin stays as shipped. |
/// | [compare] | Monthly vs annual | No. Creative skin stays as shipped. |
/// | [trial] | Free-trial toggle | No. Creative skin stays as shipped. |
/// | [unlock] | Onboarding / conversion | Yes. Uses `context.colors` / `KasyColors`. |
///
/// Solo / Compare / Trial are intentional marketing templates. Only Unlock
/// follows a Figma → `colors.dart` rebrand.
abstract class PaywallFactory {
  final String name;

  const PaywallFactory(this.name);

  @factory
  Widget build({
    required List<SubscriptionProduct> offers,
    required SubscriptionProduct? selectedOffer,
    required OnSelectItem<SubscriptionProduct> onSelectItem,
    required OnTapSubscription? onTap,
    required OnTap? onTapRestore,
    required OnTap? onSkip,
    bool isLoadingOffers = false,
  });

  Widget buildSending({
    required List<SubscriptionProduct> offers,
    required SubscriptionProduct? selectedOffer,
    required OnSelectItem<SubscriptionProduct> onSelectItem,
  }) {
    return build(
      offers: offers,
      selectedOffer: selectedOffer,
      onSelectItem: onSelectItem,
      onTap: null,
      onTapRestore: null,
      onSkip: null,
    );
  }

  /// One plan, benefits + CTA. Best for single-tier apps.
  static const solo = _PaywallSoloFactory();

  /// Side-by-side plans with a free vs premium comparison table.
  static const compare = _PaywallCompareFactory();

  /// Toggle to enable a free trial (typically on the annual plan).
  static const trial = _PaywallTrialFactory();

  /// Conversion-focused layout for onboarding or hard paywalls.
  static const unlock = _PaywallUnlockFactory();

  static const List<PaywallFactory> values = [solo, compare, trial, unlock];
}

class _PaywallTrialFactory extends PaywallFactory {
  const _PaywallTrialFactory() : super('trial');

  @override
  Widget build({
    required List<SubscriptionProduct> offers,
    required SubscriptionProduct? selectedOffer,
    required OnSelectItem<SubscriptionProduct> onSelectItem,
    required OnTapSubscription? onTap,
    required OnTap? onTapRestore,
    required OnTap? onSkip,
    bool isLoadingOffers = false,
  }) {
    return PaywallTrial(
      offers: offers,
      selectedOffer: selectedOffer,
      onSelectItem: onSelectItem,
      onTap: onTap,
      onTapRestore: onTapRestore,
      onSkip: onSkip,
      isLoadingOffers: isLoadingOffers,
    );
  }
}

class _PaywallUnlockFactory extends PaywallFactory {
  const _PaywallUnlockFactory() : super('unlock');

  @override
  Widget build({
    required List<SubscriptionProduct> offers,
    required SubscriptionProduct? selectedOffer,
    required OnSelectItem<SubscriptionProduct> onSelectItem,
    required OnTapSubscription? onTap,
    required OnTap? onTapRestore,
    required OnTap? onSkip,
    bool isLoadingOffers = false,
  }) {
    return PaywallUnlock(
      offers: offers,
      selectedOffer: selectedOffer,
      onSelectItem: onSelectItem,
      onTap: onTap,
      onTapRestore: onTapRestore,
      onSkip: onSkip,
      isLoadingOffers: isLoadingOffers,
    );
  }
}

class _PaywallSoloFactory extends PaywallFactory {
  const _PaywallSoloFactory() : super('solo');

  @override
  Widget build({
    required List<SubscriptionProduct> offers,
    required SubscriptionProduct? selectedOffer,
    required OnSelectItem<SubscriptionProduct> onSelectItem,
    required OnTapSubscription? onTap,
    required OnTap? onTapRestore,
    required OnTap? onSkip,
    bool isLoadingOffers = false,
  }) {
    return PaywallSolo(
      offers: offers,
      selectedOffer: selectedOffer,
      onSelectItem: onSelectItem,
      onTap: onTap,
      onTapRestore: onTapRestore,
      onSkip: onSkip,
      isLoadingOffers: isLoadingOffers,
    );
  }
}

class _PaywallCompareFactory extends PaywallFactory {
  const _PaywallCompareFactory() : super('compare');

  @override
  Widget build({
    required List<SubscriptionProduct> offers,
    required SubscriptionProduct? selectedOffer,
    required OnSelectItem<SubscriptionProduct> onSelectItem,
    required OnTapSubscription? onTap,
    required OnTap? onTapRestore,
    required OnTap? onSkip,
    bool isLoadingOffers = false,
  }) {
    return PaywallCompare(
      offers: offers,
      selectedOffer: selectedOffer,
      onSelectItem: onSelectItem,
      onTap: onTap,
      onTapRestore: onTapRestore,
      onSkip: onSkip,
      isLoadingOffers: isLoadingOffers,
    );
  }
}
