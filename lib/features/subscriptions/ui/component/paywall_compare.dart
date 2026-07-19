import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_billing_note.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_backdrop.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_config.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_desktop.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_matrix.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_palette.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_plan_card.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_desktop_layout.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_empty_state.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_offers_skeleton.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_bottom_menu.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_close_button.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/selectable_row.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Compare paywall: free vs premium matrix + monthly/annual plan picker.
class PaywallCompare extends StatefulWidget {
  final List<SubscriptionProduct> offers;
  final SubscriptionProduct? selectedOffer;
  final OnSelectItem<SubscriptionProduct> onSelectItem;
  final OnTapSubscription? onTap;
  final OnTap? onTapRestore;
  final OnTap? onSkip;
  final bool isLoadingOffers;

  static const double _maxContentWidth = 520;

  const PaywallCompare({
    super.key,
    required this.offers,
    required this.onSelectItem,
    required this.onTap,
    required this.onTapRestore,
    required this.selectedOffer,
    required this.onSkip,
    this.isLoadingOffers = false,
  });

  @override
  State<PaywallCompare> createState() => _PaywallCompareState();
}

class _PaywallCompareState extends State<PaywallCompare>
    with SingleTickerProviderStateMixin {
  bool _didInitialOfferSync = false;
  late final AnimationController _footerEntrance;
  late final Animation<Offset> _footerSlide;

  static const Duration _footerEntranceDuration = Duration(milliseconds: 480);

  List<SubscriptionProduct> get _orderedOffers =>
      orderPaywallCompareOffers(widget.offers);

  SubscriptionProduct? get _defaultOffer =>
      resolvePaywallCompareDefaultOffer(widget.offers);

  SubscriptionProduct? get _selected =>
      widget.selectedOffer ?? _defaultOffer;

  @override
  void initState() {
    super.initState();
    _footerEntrance = AnimationController(
      vsync: this,
      duration: _footerEntranceDuration,
    );
    _footerSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _footerEntrance,
        curve: Curves.easeOutCubic,
      ),
    );
    _scheduleDefaultOfferSync();
    _scheduleFooterEntrance();
  }

  @override
  void dispose() {
    _footerEntrance.dispose();
    super.dispose();
  }

  void _scheduleFooterEntrance() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (MediaQuery.disableAnimationsOf(context)) {
        _footerEntrance.value = 1;
        return;
      }
      _footerEntrance.forward(from: 0);
    });
  }

  @override
  void didUpdateWidget(covariant PaywallCompare oldWidget) {
    super.didUpdateWidget(oldWidget);
    final offersArrived =
        (oldWidget.isLoadingOffers && !widget.isLoadingOffers) ||
        (oldWidget.offers.isEmpty && widget.offers.isNotEmpty);
    if (offersArrived) {
      _scheduleDefaultOfferSync();
    }
  }

  void _scheduleDefaultOfferSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncDefaultOffer());
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

  bool get _motionReduced => MediaQuery.disableAnimationsOf(context);

  Widget _enter(
    Widget child, {
    int delayMs = 0,
    double slideY = 10,
  }) {
    if (_motionReduced) {
      return child;
    }
    final delay = Duration(milliseconds: delayMs);
    return Animate(
      effects: [
        FadeEffect(
          delay: delay,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
        ),
        MoveEffect(
          delay: delay,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOut,
          begin: Offset(0, slideY),
          end: Offset.zero,
        ),
      ],
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty && !widget.isLoadingOffers) {
      return PaywallEmptyState(
        onTapRestore: widget.onTapRestore,
        onSkip: widget.onSkip,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (shouldUsePaywallDesktopLayout(constraints.maxWidth)) {
          return PaywallCompareDesktop(
            offers: widget.offers,
            selectedOffer: widget.selectedOffer,
            onSelectItem: widget.onSelectItem,
            onTap: widget.onTap,
            onTapRestore: widget.onTapRestore,
            onSkip: widget.onSkip,
            isLoadingOffers: widget.isLoadingOffers,
          );
        }
        return _buildMobileLayout(context);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: PaywallComparePalette.canvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _backdrop(),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  DeviceType.fromWidth(constraints.maxWidth) == DeviceType.small;
              final maxWidth =
                  compact ? constraints.maxWidth : PaywallCompare._maxContentWidth;
              final topInset = MediaQuery.paddingOf(context).top;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        compact
                            ? KasySpacing.pageHorizontalGutter
                            : KasySpacing.lg,
                        topInset + (compact ? 0 : KasySpacing.sm),
                        compact
                            ? KasySpacing.pageHorizontalGutter
                            : KasySpacing.lg,
                        KasySpacing.lg,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: SizedBox(
                            width: double.infinity,
                            child: _scrollContent(context, compact: compact),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _footerBar(
                    context,
                    compact: compact,
                    maxWidth: maxWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _backdrop() {
    return PaywallCompareBackdrop(motionReduced: _motionReduced);
  }

  Widget _scrollContent(BuildContext context, {required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _restoreButton(context),
            AppCloseButton(
              onTap: () => widget.onSkip?.call(),
              backgroundColor: PaywallComparePalette.closeScrim,
              iconColor: PaywallComparePalette.muted,
              pressOverlayColor: PaywallComparePalette.onCanvas.withValues(alpha: 0.1),
            ),
          ],
        ),
        SizedBox(height: compact ? KasySpacing.lg : KasySpacing.xl),
        _headline(context, compact: compact),
        SizedBox(height: compact ? KasySpacing.xl : KasySpacing.xxl),
        PaywallCompareFeatureMatrix(motionReduced: _motionReduced),
        SizedBox(height: compact ? KasySpacing.xl : KasySpacing.xxl),
        _planPicker(context),
      ],
    );
  }

  Widget _planPicker(BuildContext context) {
    if (widget.isLoadingOffers) {
      return _enter(
        const PaywallPlanRowSkeleton(),
        delayMs: 300,
      );
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
    const cardBodyHeight = PaywallComparePlanCard.bodyHeight;
    const badgeReserve = PaywallComparePlanCard.badgeReserveHeight;
    final badgeTopInset = showSavingsBadge ? badgeReserve : 0.0;
    final cardTotalHeight = badgeTopInset + cardBodyHeight;

    return _enter(
      Row(
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
                  badge: offers[i].durationType == PaywallCompareConfig.badgeDuration &&
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
      ),
      delayMs: 300,
    );
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

  Widget _footerBar(
    BuildContext context, {
    required bool compact,
    required double maxWidth,
  }) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    final bar = DecoratedBox(
      decoration: BoxDecoration(
        color: PaywallComparePalette.footerBar,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KasyRadius.xl),
        ),
        border: Border(
          top: BorderSide(
            color: PaywallComparePalette.border.withValues(alpha: 0.9),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? KasySpacing.pageHorizontalGutter : KasySpacing.lg,
          KasySpacing.xl,
          compact ? KasySpacing.pageHorizontalGutter : KasySpacing.lg,
          bottomInset > 0 ? bottomInset : KasySpacing.lg,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: _footer(context),
          ),
        ),
      ),
    );

    if (_motionReduced) {
      return bar;
    }

    return SlideTransition(
      position: _footerSlide,
      child: bar,
    );
  }

  Widget _footer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cta(context),
        const SizedBox(height: KasySpacing.sm),
        _billingNote(context),
        const SizedBox(height: KasySpacing.sm),
        const BottomPremiumMenu(
          style: PremiumFooterStyle.dot,
          textColor: PaywallComparePalette.muted,
        ),
      ],
    );
  }

  Widget _restoreButton(BuildContext context) {
    if (widget.onTapRestore == null) {
      return const SizedBox.shrink();
    }
    final label = Translations.of(context).premium.restore_action;
    final textStyle = context.textTheme.bodyMedium!.copyWith(
      color: PaywallComparePalette.muted,
      fontWeight: FontWeight.w500,
    );
    return InkWell(
      onTap: widget.onTapRestore,
      borderRadius: BorderRadius.circular(KasyRadius.sm),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KasySpacing.sm,
          KasySpacing.xs,
          0,
          KasySpacing.xs,
        ),
        child: Text(label, style: textStyle),
      ),
    );
  }

  Widget _headline(BuildContext context, {required bool compact}) {
    final copy = Translations.of(context).premium.comparePlan;
    final titleStyle = context.kasyTextTheme.pageTitle
        .withWeight(FontWeight.w700)
        .copyWith(
          color: PaywallComparePalette.onCanvas,
          height: 1.15,
          letterSpacing: -0.4,
        );
    final descriptionStyle = context.kasyTextTheme.bodyMedium.copyWith(
      color: PaywallComparePalette.muted,
      height: 1.4,
    );

    return Column(
      children: [
        _enter(
          Text(
            copy.headline_1,
            style: titleStyle,
            textAlign: TextAlign.center,
          ),
          delayMs: 80,
        ),
        const SizedBox(height: KasySpacing.sm),
        _enter(
          Text(
            copy.headline_description,
            style: descriptionStyle,
            textAlign: TextAlign.center,
          ),
          delayMs: 140,
        ),
      ],
    );
  }

  Widget _billingNote(BuildContext context) {
    final copy = Translations.of(context).premium.comparePlan;
    return Text(
      resolvePaywallBillingNote(
        storeNote: copy.billing_note,
        webNote: copy.billing_note_web,
      ),
      textAlign: TextAlign.center,
      style: context.textTheme.bodySmall?.copyWith(
        color: PaywallComparePalette.subtle,
        height: 1.35,
      ),
    );
  }

  Widget _cta(BuildContext context) {
    final copy = Translations.of(context).premium.comparePlan;
    return KasyButton(
      label: copy.continue_cta,
      expand: true,
      size: KasyButtonSize.large,
      backgroundColor: PaywallComparePalette.primary,
      foregroundColor: PaywallComparePalette.onCanvas,
      fontWeight: FontWeight.w600,
      isLoading: widget.isLoadingOffers || widget.onTap == null,
      onPressed: widget.onTap,
    );
  }
}
