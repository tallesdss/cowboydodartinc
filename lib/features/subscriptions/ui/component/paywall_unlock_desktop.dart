import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_shine_sweep.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_billing_note.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_desktop_shell.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_unlock_config.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_empty_state.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_offers_skeleton.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_shine_badge.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_bottom_menu.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/selectable_row.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Desktop web layout for [PaywallUnlock]: full-screen horizontal plan cards.
class PaywallUnlockDesktop extends StatefulWidget {
  static const double _minPlanCardWidth = 280;
  static const double _maxPlanCardWidth = 340;
  static const double _planCardGap = KasySpacing.lg;
  static const double _planCardMinHeight = 500;
  static const double _ctaFixedWidth = 140;
  static const double _headerTopInset = KasySpacing.xl;
  static const double _titleSubtitleGap = KasySpacing.lg;
  static const double _bodyVerticalBias = -0.12;

  const PaywallUnlockDesktop({
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

  @override
  State<PaywallUnlockDesktop> createState() => _PaywallUnlockDesktopState();
}

class _PaywallUnlockDesktopState extends State<PaywallUnlockDesktop> {
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
  void didUpdateWidget(covariant PaywallUnlockDesktop oldWidget) {
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

  void _subscribeToOffer(SubscriptionProduct offer) {
    if (widget.isLoadingOffers || widget.onTap == null) {
      return;
    }
    if (_selected?.skuId != offer.skuId) {
      widget.onSelectItem(offer);
    }
    KasyHaptics.heavy(context);
    widget.onTap!();
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

  String? _planSubtitle(BuildContext context, SubscriptionProduct offer) {
    return switch (offer.durationType) {
      DurationType.year => offer.pricePerMonth(context),
      DurationType.month =>
        Translations.of(context).premium.comparePlan.billed_monthly,
      _ => null,
    };
  }

  String _planPriceSuffix(BuildContext context, SubscriptionProduct offer) {
    final premium = Translations.of(context).premium;
    return switch (offer.durationType) {
      DurationType.month => premium.price_per_month,
      DurationType.year => premium.price_per_year,
      DurationType.week => premium.price_per_week,
      DurationType.threeMonth => premium.price_per_three_month,
      DurationType.sixMonth => premium.price_per_six_month,
      DurationType.lifetime => premium.price_one_time,
    };
  }

  List<String> _features(BuildContext context) {
    final copy = Translations.of(context).premium.unlockPlan;
    return [
      copy.feature_1,
      copy.feature_2,
      copy.feature_3,
      copy.feature_4,
      copy.feature_5,
    ];
  }

  double _resolvePlanCardWidth(double maxContentWidth) {
    final count = _orderedOffers.isEmpty ? 2 : _orderedOffers.length;
    final gaps = (count - 1) * PaywallUnlockDesktop._planCardGap;
    final perCard = (maxContentWidth - gaps) / count;
    return perCard.clamp(
      PaywallUnlockDesktop._minPlanCardWidth,
      PaywallUnlockDesktop._maxPlanCardWidth,
    );
  }

  double _resolvePlanRowWidth(double maxContentWidth) {
    final count = _orderedOffers.isEmpty ? 2 : _orderedOffers.length;
    if (count <= 1) {
      return _resolvePlanCardWidth(maxContentWidth);
    }
    final cardWidth = _resolvePlanCardWidth(maxContentWidth);
    return cardWidth * count +
        PaywallUnlockDesktop._planCardGap * (count - 1);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty && !widget.isLoadingOffers) {
      return PaywallEmptyState(
        onTapRestore: widget.onTapRestore,
        onSkip: widget.onSkip,
      );
    }

    final colors = context.colors;
    final copy = Translations.of(context).premium.unlockPlan;
    final compareCopy = Translations.of(context).premium.comparePlan;
    final monthly = findCompareMonthlyOffer(widget.offers);
    final annual = findCompareAnnualOffer(widget.offers);
    final savings = comparePlanSavingsPercent(monthly: monthly, annual: annual);
    final features = _features(context);
    const horizontalPadding = KasySpacing.xxl;
    final contentWidth =
        MediaQuery.sizeOf(context).width - (horizontalPadding * 2);
    final planRowWidth = _resolvePlanRowWidth(contentWidth);
    final titleStyle = context.kasyTextTheme.displaySmall
        .withWeight(FontWeight.w700)
        .copyWith(
          color: colors.foreground,
          letterSpacing: -0.5,
          height: 1.12,
        );
    final descriptionStyle = context.kasyTextTheme.pageSubtitle.copyWith(
      color: colors.foregroundMuted,
      height: 1.45,
    );

    return PaywallDesktopFullscreenShell(
      backgroundColor: colors.background,
      onClose: widget.onSkip,
      closePadding: const EdgeInsets.fromLTRB(
        KasySpacing.lg,
        KasySpacing.sm,
        KasySpacing.xxl,
        0,
      ),
      footerTopPadding: KasySpacing.md,
      header: Padding(
        padding: const EdgeInsets.only(top: PaywallUnlockDesktop._headerTopInset),
        child: Column(
          children: [
            Text(
              copy.headline_desktop,
              textAlign: TextAlign.center,
              style: titleStyle,
            ),
            const SizedBox(height: PaywallUnlockDesktop._titleSubtitleGap),
            Text(
              compareCopy.headline_description,
              textAlign: TextAlign.center,
              style: descriptionStyle,
            ),
          ],
        ),
      ),
      body: Align(
        alignment: const Alignment(0, PaywallUnlockDesktop._bodyVerticalBias),
        child: widget.isLoadingOffers
              ? SizedBox(
                  width: planRowWidth,
                  child: const PaywallPlanColSkeleton(),
                )
              : SizedBox(
                  width: planRowWidth,
                  height: PaywallUnlockDesktop._planCardMinHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < _orderedOffers.length; i++) ...[
                        if (i > 0)
                          const SizedBox(
                            width: PaywallUnlockDesktop._planCardGap,
                          ),
                        Expanded(
                          child: _UnlockDesktopPlanCard(
                            featured: _orderedOffers[i].durationType ==
                                DurationType.year,
                            onSubscribe: widget.isLoadingOffers ||
                                    widget.onTap == null
                                ? null
                                : () => _subscribeToOffer(_orderedOffers[i]),
                            ctaLabel: copy.cta_desktop,
                            isSubscribeLoading: widget.isLoadingOffers ||
                                widget.onTap == null,
                            planLabel:
                                _planLabel(context, _orderedOffers[i]),
                            priceAmount: _orderedOffers[i].priceString,
                            priceSuffix: _planPriceSuffix(
                              context,
                              _orderedOffers[i],
                            ),
                            subtitle: _planSubtitle(
                              context,
                              _orderedOffers[i],
                            ),
                            badge: _orderedOffers[i].durationType ==
                                    DurationType.year &&
                                savings != null
                                ? compareCopy.best_offer_badge(
                                    percent: savings,
                                  )
                                : null,
                            features: features,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
      ),
      footer: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: planRowWidth),
              child: Text(
                resolvePaywallBillingNote(
                  storeNote: copy.billing_note,
                  webNote: copy.billing_note_web,
                ),
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.foregroundMuted,
                  height: 1.35,
                ),
              ),
            ),
          ),
          const SizedBox(height: KasySpacing.sm),
          BottomPremiumMenu(
            style: PremiumFooterStyle.dot,
            textColor: colors.foregroundMuted,
            onTapRestore: widget.onTapRestore,
          ),
        ],
      ),
    );
  }
}

class _UnlockDesktopPlanCard extends StatelessWidget {
  const _UnlockDesktopPlanCard({
    required this.featured,
    required this.planLabel,
    required this.priceAmount,
    required this.priceSuffix,
    required this.features,
    required this.ctaLabel,
    this.onSubscribe,
    this.isSubscribeLoading = false,
    this.subtitle,
    this.badge,
  });

  final bool featured;
  final String planLabel;
  final String priceAmount;
  final String priceSuffix;
  final String? subtitle;
  final List<String> features;
  final String? badge;
  final String ctaLabel;
  final VoidCallback? onSubscribe;
  final bool isSubscribeLoading;

  static const EdgeInsets _cardPadding = EdgeInsets.fromLTRB(
    KasySpacing.lg,
    KasySpacing.lg,
    KasySpacing.lg,
    KasySpacing.lg,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final planLabelStyle = context.textTheme.titleLarge!.withWeight(
      FontWeight.w700,
    ).copyWith(
      color: colors.foreground,
      height: 1.15,
    );
    final subtitleStyle = context.textTheme.bodyMedium?.copyWith(
      color: colors.foregroundMuted,
      height: 1.35,
    );
    final priceStyle = context.textTheme.headlineLarge!.withWeight(
      FontWeight.w700,
    ).copyWith(
      color: colors.foreground,
      height: 1.0,
      letterSpacing: -0.5,
    );
    final priceSuffixStyle = context.textTheme.bodyLarge?.copyWith(
      color: colors.foregroundMuted,
      fontWeight: FontWeight.w500,
      height: 1.0,
    );
    final featureStyle = context.textTheme.bodyLarge!.withWeight(
      FontWeight.w500,
    ).copyWith(
      color: colors.foreground,
      height: 1.35,
    );
    final badgeStyle = context.textTheme.labelMedium!.copyWith(
      color: colors.warningForeground,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
      height: 1.0,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(KasyRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(KasyRadius.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: _cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(planLabel, style: planLabelStyle),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: KasySpacing.sm),
                        PaywallShineBadge(
                          label: badge!,
                          textStyle: badgeStyle,
                          backgroundColor: colors.warning,
                          shineIntensity: KasyShineIntensity.soft,
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: KasySpacing.xs),
                    Text(subtitle!, style: subtitleStyle),
                  ],
                  const SizedBox(height: KasySpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          priceAmount,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: priceStyle,
                        ),
                      ),
                      if (priceSuffix.isNotEmpty) ...[
                        const SizedBox(width: KasySpacing.xs),
                        Text(priceSuffix, style: priceSuffixStyle),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: colors.separator),
            Expanded(
              child: Padding(
                padding: _cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < features.length; i++) ...[
                      _UnlockDesktopFeatureRow(
                        label: features[i],
                        style: featureStyle,
                      ),
                      if (i < features.length - 1)
                        const SizedBox(height: KasySpacing.sm),
                    ],
                    const Spacer(),
                    if (onSubscribe != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _PlanCardCta(
                          label: ctaLabel,
                          featured: featured,
                          isLoading: isSubscribeLoading,
                          onPressed: onSubscribe,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnlockDesktopFeatureRow extends StatelessWidget {
  const _UnlockDesktopFeatureRow({
    required this.label,
    required this.style,
  });

  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: colors.successSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(
            KasyIcons.check,
            size: 14,
            color: colors.success,
          ),
        ),
        const SizedBox(width: KasySpacing.sm),
        Expanded(child: Text(label, style: style)),
      ],
    );
  }
}

class _PlanCardCta extends StatelessWidget {
  const _PlanCardCta({
    required this.label,
    required this.featured,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool featured;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (featured) {
      return KasyButton(
        key: const ValueKey<String>('premium_subscribe_button'),
        label: label,
        width: PaywallUnlockDesktop._ctaFixedWidth,
        backgroundColor: colors.primary,
        foregroundColor: colors.primaryForeground,
        fontWeight: FontWeight.w600,
        isLoading: isLoading,
        onPressed: onPressed,
      );
    }
    return KasyButton(
      label: label,
      width: PaywallUnlockDesktop._ctaFixedWidth,
      variant: KasyButtonVariant.secondary,
      backgroundColor: Colors.transparent,
      foregroundColor: colors.primary,
      borderColor: colors.primary,
      fontWeight: FontWeight.w600,
      isLoading: isLoading,
      onPressed: onPressed,
    );
  }
}
