import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_billing_note.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_backdrop.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_config.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_matrix.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_palette.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_plan_card.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_empty_state.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_offers_skeleton.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_bottom_menu.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_close_button.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/selectable_row.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Desktop web layout for [PaywallCompare]: matrix left, plan picker + CTA right.
class PaywallCompareDesktop extends StatefulWidget {
  const PaywallCompareDesktop({
    super.key,
    required this.offers,
    required this.onSelectItem,
    required this.onTap,
    required this.onTapRestore,
    required this.selectedOffer,
    required this.onSkip,
    this.isLoadingOffers = false,
  });

  final List<SubscriptionProduct> offers;
  final SubscriptionProduct? selectedOffer;
  final OnSelectItem<SubscriptionProduct> onSelectItem;
  final OnTapSubscription? onTap;
  final OnTap? onTapRestore;
  final OnTap? onSkip;
  final bool isLoadingOffers;

  static const double _maxContentWidth = 1120;
  static const double _contentTopGap =
      KasySpacing.xxxl + KasySpacing.xl;

  @override
  State<PaywallCompareDesktop> createState() => _PaywallCompareDesktopState();
}

class _PaywallCompareDesktopState extends State<PaywallCompareDesktop> {
  bool _didInitialOfferSync = false;

  List<SubscriptionProduct> get _orderedOffers =>
      orderPaywallCompareOffers(widget.offers);

  SubscriptionProduct? get _defaultOffer =>
      resolvePaywallCompareDefaultOffer(widget.offers);

  SubscriptionProduct? get _selected =>
      widget.selectedOffer ?? _defaultOffer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncDefaultOffer());
  }

  @override
  void didUpdateWidget(covariant PaywallCompareDesktop oldWidget) {
    super.didUpdateWidget(oldWidget);
    final offersArrived =
        (oldWidget.isLoadingOffers && !widget.isLoadingOffers) ||
        (oldWidget.offers.isEmpty && widget.offers.isNotEmpty);
    if (offersArrived) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncDefaultOffer());
    }
  }

  void _syncDefaultOffer() {
    if (!mounted || _didInitialOfferSync) {
      return;
    }
    if (widget.isLoadingOffers || widget.offers.isEmpty) {
      return;
    }
    final target = _defaultOffer;
    if (target == null) {
      return;
    }
    _didInitialOfferSync = true;
    if (widget.selectedOffer?.skuId != target.skuId) {
      widget.onSelectItem(target);
    }
  }

  void _selectOffer(SubscriptionProduct offer) {
    if (widget.selectedOffer?.skuId == offer.skuId) {
      return;
    }
    KasyHaptics.heavy(context);
    widget.onSelectItem(offer);
  }

  String _planLabel(BuildContext context, SubscriptionProduct offer) {
    final premium = Translations.of(context).premium;
    return switch (offer.durationType) {
      DurationType.month => premium.duration_recuring_label_monthly,
      DurationType.year => premium.duration_recuring_label_annual,
      DurationType.week => premium.duration_recuring_label_weekly,
      DurationType.lifetime => premium.duration_lifetime,
      DurationType.threeMonth => premium.comparePlan.plan_three_month,
      DurationType.sixMonth => premium.comparePlan.plan_six_month,
    };
  }

  String _planSubtitle(BuildContext context, SubscriptionProduct offer) {
    final copy = Translations.of(context).premium.comparePlan;
    final premium = Translations.of(context).premium;
    return switch (offer.durationType) {
      DurationType.year => offer.pricePerMonth(context),
      DurationType.month => copy.billed_monthly,
      DurationType.week => copy.billed_every(period: premium.duration_weekly),
      DurationType.threeMonth => copy.plan_three_month,
      DurationType.sixMonth => copy.plan_six_month,
      DurationType.lifetime => premium.duration_lifetime,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty && !widget.isLoadingOffers) {
      return PaywallEmptyState(
        onTapRestore: widget.onTapRestore,
        onSkip: widget.onSkip,
      );
    }

    final copy = Translations.of(context).premium.comparePlan;
    final titleStyle = context.kasyTextTheme.displaySmall
        .withWeight(FontWeight.w700)
        .copyWith(
          color: PaywallComparePalette.onCanvas,
          letterSpacing: -0.5,
          height: 1.12,
        );
    final descriptionStyle = context.kasyTextTheme.pageSubtitle.copyWith(
      color: PaywallComparePalette.muted,
      height: 1.45,
    );

    return Scaffold(
      backgroundColor: PaywallComparePalette.canvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PaywallCompareBackdrop(),
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: PaywallCompareDesktop._maxContentWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        KasySpacing.xxl,
                        KasySpacing.lg,
                        KasySpacing.xxl,
                        KasySpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: KasySpacing.xxl),
                          Text(
                            copy.headline_1,
                            textAlign: TextAlign.center,
                            style: titleStyle,
                          ),
                          const SizedBox(height: KasySpacing.sm),
                          Text(
                            copy.headline_description,
                            textAlign: TextAlign.center,
                            style: descriptionStyle,
                          ),
                          const SizedBox(height: PaywallCompareDesktop._contentTopGap),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Flexible(
                                      flex: 11,
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: PaywallCompareFeatureMatrix(
                                          desktopScale: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: KasySpacing.xxl),
                                    Expanded(
                                      flex: 9,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          _planAndActionColumn(context),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: KasySpacing.lg,
                  right: KasySpacing.lg,
                  child: AppCloseButton(
                    onTap: widget.onSkip,
                    backgroundColor: PaywallComparePalette.closeScrim,
                    iconColor: PaywallComparePalette.muted,
                    pressOverlayColor: PaywallComparePalette.onCanvas
                        .withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _planAndActionColumn(BuildContext context) {
    final copy = Translations.of(context).premium.comparePlan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _planPicker(context),
        const SizedBox(height: KasySpacing.xl),
        KasyButton(
          label: copy.continue_cta,
          expand: true,
          size: KasyButtonSize.large,
          backgroundColor: PaywallComparePalette.primary,
          foregroundColor: PaywallComparePalette.onCanvas,
          fontWeight: FontWeight.w600,
          isLoading: widget.isLoadingOffers || widget.onTap == null,
          onPressed: widget.onTap,
        ),
        const SizedBox(height: KasySpacing.sm),
        Text(
          resolvePaywallBillingNote(
            storeNote: copy.billing_note,
            webNote: copy.billing_note_web,
          ),
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            color: PaywallComparePalette.subtle,
            height: 1.35,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        BottomPremiumMenu(
          style: PremiumFooterStyle.dot,
          textColor: PaywallComparePalette.muted,
          onTapRestore: widget.onTapRestore,
        ),
      ],
    );
  }

  Widget _planPicker(BuildContext context) {
    if (widget.isLoadingOffers) {
      return const PaywallPlanRowSkeleton();
    }

    final offers = _orderedOffers;
    if (offers.isEmpty) {
      return const SizedBox.shrink();
    }

    final monthly = findCompareMonthlyOffer(widget.offers);
    final annual = findCompareAnnualOffer(widget.offers);
    final savings = comparePlanSavingsPercent(monthly: monthly, annual: annual);
    final copy = Translations.of(context).premium.comparePlan;

    final showSavingsBadge = savings != null;
    const cardBodyHeight = PaywallComparePlanCard.desktopBodyHeight;
    const badgeReserve = PaywallComparePlanCard.badgeReserveHeight;
    final badgeTopInset = showSavingsBadge ? badgeReserve : 0.0;
    final cardTotalHeight = badgeTopInset + cardBodyHeight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < offers.length; i++) ...[
          if (i > 0) const SizedBox(width: KasySpacing.smd),
          Expanded(
            child: SizedBox(
              height: cardTotalHeight,
              child: PaywallComparePlanCard(
                offer: offers[i],
                selected: _selected?.skuId == offers[i].skuId,
                onTap: () => _selectOffer(offers[i]),
                badgeTopInset: badgeTopInset,
                desktopScale: true,
                badge:
                    offers[i].durationType == PaywallCompareConfig.badgeDuration &&
                        showSavingsBadge
                    ? copy.best_offer_badge(percent: savings)
                    : null,
                planLabel: _planLabel(context, offers[i]),
                priceLine: offers[i].priceString,
                subtitle: _planSubtitle(context, offers[i]),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
