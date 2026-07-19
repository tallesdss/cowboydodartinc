import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_shine_sweep.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_billing_note.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_desktop_layout.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_unlock_config.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_unlock_desktop.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_empty_state.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_offers_skeleton.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_shine_badge.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_bottom_menu.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_close_button.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/selectable_row.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

const String kPaywallUnlockHeroImage = 'assets/images/img-planUnlock.png';

/// Unlock paywall: onboarding conversion with hero parallax, stacked plans,
/// theme-driven colors (light/dark). Shown after the onboarding loader.
class PaywallUnlock extends StatefulWidget {
  final List<SubscriptionProduct> offers;
  final SubscriptionProduct? selectedOffer;
  final OnSelectItem<SubscriptionProduct> onSelectItem;
  final OnTapSubscription? onTap;
  final OnTap? onTapRestore;
  final OnTap? onSkip;
  final bool isLoadingOffers;

  static const double _maxContentWidth = 480;
  static const double _heroImageLift = 0;
  static const double _parallaxFactor = 0.42;

  const PaywallUnlock({
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
  State<PaywallUnlock> createState() => _PaywallUnlockState();
}

class _PaywallUnlockState extends State<PaywallUnlock>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _didInitialOfferSync = false;
  double _scrollOffset = 0;
  late final AnimationController _footerEntrance;
  late final Animation<Offset> _footerSlide;

  static const Duration _footerEntranceDuration = Duration(milliseconds: 480);

  List<SubscriptionProduct> get _orderedOffers =>
      orderPaywallCompareOffers(widget.offers);

  SubscriptionProduct? get _defaultOffer =>
      resolvePaywallCompareDefaultOffer(widget.offers);

  SubscriptionProduct? get _selected =>
      widget.selectedOffer ?? _defaultOffer;

  bool get _motionReduced => MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
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
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _footerEntrance.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final next = _scrollController.offset;
    if ((next - _scrollOffset).abs() < 0.5) {
      return;
    }
    setState(() => _scrollOffset = next);
  }

  @override
  void didUpdateWidget(covariant PaywallUnlock oldWidget) {
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
    final offer = _defaultOffer;
    if (offer == null) {
      return;
    }
    _didInitialOfferSync = true;
    if (widget.selectedOffer?.skuId != offer.skuId) {
      widget.onSelectItem(offer);
    }
  }

  void _scheduleFooterEntrance() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (_motionReduced) {
        _footerEntrance.value = 1;
        return;
      }
      _footerEntrance.forward(from: 0);
    });
  }

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
          return PaywallUnlockDesktop(
            offers: widget.offers,
            selectedOffer: widget.selectedOffer,
            onSelectItem: widget.onSelectItem,
            onTap: widget.onTap,
            onTapRestore: widget.onTapRestore,
            onSkip: widget.onSkip,
            isLoadingOffers: widget.isLoadingOffers,
          );
        }
        return Scaffold(
          backgroundColor: context.colors.background,
          body: LayoutBuilder(
            builder: (context, innerConstraints) {
              final compact = DeviceType.fromWidth(innerConstraints.maxWidth) ==
                  DeviceType.small;
              return compact
                  ? _mobileLayout(context, innerConstraints.maxHeight)
                  : _wideLayout(context, innerConstraints.maxHeight);
            },
          ),
        );
      },
    );
  }

  Widget _mobileLayout(BuildContext context, double height) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      fit: StackFit.expand,
      children: [
        _heroBackdrop(context, height),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: KasySpacing.pageHorizontalGutter,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _headline(context),
                          const SizedBox(height: KasySpacing.xl),
                          _features(context),
                          const SizedBox(height: KasySpacing.xl),
                          _planSection(context),
                          const SizedBox(height: KasySpacing.sm),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _footerBar(context, compact: true),
          ],
        ),
        Positioned(
          top: topInset + KasySpacing.xs,
          right: KasySpacing.pageHorizontalGutter,
          child: Transform.translate(
            offset: const Offset(0, -4),
            child: AppCloseButton(onTap: widget.onSkip),
          ),
        ),
      ],
    );
  }

  Widget _wideLayout(BuildContext context, double height) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      fit: StackFit.expand,
      children: [
        _heroBackdrop(context, height),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: PaywallUnlock._maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: KasySpacing.lg,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _headline(context),
                              const SizedBox(height: KasySpacing.xl),
                              _features(context),
                              const SizedBox(height: KasySpacing.xl),
                              _planSection(context),
                              const SizedBox(height: KasySpacing.sm),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _footerBar(context, compact: false),
              ],
            ),
          ),
        ),
        Positioned(
          top: topInset + KasySpacing.sm,
          right: KasySpacing.lg,
          child: AppCloseButton(onTap: widget.onSkip),
        ),
      ],
    );
  }

  Widget _heroBackdrop(BuildContext context, double height) {
    final colors = context.colors;
    final parallax = _scrollOffset * PaywallUnlock._parallaxFactor;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: colors.backgroundSecondary),
        Transform.translate(
          offset: Offset(0, PaywallUnlock._heroImageLift - parallax),
          child: Image.asset(
            kPaywallUnlockHeroImage,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            width: double.infinity,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                colors.background,
                colors.background,
                colors.background.withValues(alpha: 0.94),
                colors.background.withValues(alpha: 0.45),
                colors.background.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.50, 0.68, 0.88, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _headline(BuildContext context) {
    final copy = Translations.of(context).premium.unlockPlan;
    final style = context.kasyTextTheme.displaySmall
        .withWeight(FontWeight.w800)
        .copyWith(
          color: context.colors.foreground,
          height: 1.08,
          letterSpacing: 0.4,
        );

    return Column(
      children: [
        _enter(Text(copy.headline_1, textAlign: TextAlign.center, style: style), delayMs: 80),
        const SizedBox(height: KasySpacing.xs),
        _enter(Text(copy.headline_2, textAlign: TextAlign.center, style: style), delayMs: 140),
      ],
    );
  }

  Widget _features(BuildContext context) {
    final colors = context.colors;
    final copy = Translations.of(context).premium.unlockPlan;
    final items = [
      (
        icon: KasyIcons.star,
        iconColor: colors.primary,
        iconBackground: colors.primarySoft,
        text: copy.feature_1,
      ),
      (
        icon: KasyIcons.flash,
        iconColor: colors.warning,
        iconBackground: colors.warningSoft,
        text: copy.feature_2,
      ),
      (
        icon: KasyIcons.time,
        iconColor: colors.success,
        iconBackground: colors.successSoft,
        text: copy.feature_3,
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: KasySpacing.smd),
          _enter(
            _FeatureRow(
              icon: items[i].icon,
              iconColor: items[i].iconColor,
              iconBackground: items[i].iconBackground,
              label: items[i].text,
            ),
            delayMs: 180 + (i * 60),
          ),
        ],
      ],
    );
  }

  Widget _planSection(BuildContext context) {
    if (widget.isLoadingOffers) {
      return const PaywallPlanColSkeleton();
    }

    final offers = _orderedOffers;
    if (offers.isEmpty) {
      return const SizedBox.shrink();
    }

    final monthly = findCompareMonthlyOffer(widget.offers);
    final annual = findCompareAnnualOffer(widget.offers);
    final savings = comparePlanSavingsPercent(monthly: monthly, annual: annual);
    final compareCopy = Translations.of(context).premium.comparePlan;

    return Column(
      children: [
        for (var i = 0; i < offers.length; i++) ...[
          if (i > 0) const SizedBox(height: KasySpacing.sm),
          _enter(
            _UnlockPlanCard(
              offer: offers[i],
              selected: _selected?.skuId == offers[i].skuId,
              onTap: () {
                KasyHaptics.selection(context);
                widget.onSelectItem(offers[i]);
              },
              planLabel: _planLabel(context, offers[i]),
              priceLine: _planPriceLine(context, offers[i]),
              trailing: _planTrailing(context, offers[i]),
              badge: offers[i].durationType == DurationType.year && savings != null
                  ? compareCopy.best_offer_badge(percent: savings)
                  : null,
            ),
            delayMs: 360 + (i * 70),
          ),
        ],
      ],
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

  String _planPriceLine(BuildContext context, SubscriptionProduct offer) {
    final copy = Translations.of(context).premium.unlockPlan;
    final price = offer.priceString;
    return switch (offer.durationType) {
      DurationType.year => copy.plan_annual_price(price: price),
      DurationType.month => copy.plan_monthly_price(price: price),
      _ => price,
    };
  }

  String? _planTrailing(BuildContext context, SubscriptionProduct offer) {
    return switch (offer.durationType) {
      DurationType.year => offer.pricePerMonth(context),
      DurationType.month => Translations.of(context).premium.comparePlan.billed_monthly,
      _ => null,
    };
  }

  Widget _footerBar(BuildContext context, {required bool compact}) {
    final colors = context.colors;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final bar = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? KasySpacing.pageHorizontalGutter : KasySpacing.lg,
          KasySpacing.md,
          compact ? KasySpacing.pageHorizontalGutter : KasySpacing.lg,
          bottomInset > 0 ? bottomInset : KasySpacing.lg,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: PaywallUnlock._maxContentWidth),
            child: _footer(context),
          ),
        ),
      ),
    );

    if (_motionReduced) {
      return bar;
    }

    return SlideTransition(position: _footerSlide, child: bar);
  }

  Widget _footer(BuildContext context) {
    final copy = Translations.of(context).premium.unlockPlan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cta(context, copy.cta),
        const SizedBox(height: KasySpacing.sm),
        Text(
          resolvePaywallBillingNote(
            storeNote: copy.billing_note,
            webNote: copy.billing_note_web,
          ),
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.foregroundMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: KasySpacing.sm),
        BottomPremiumMenu(
          style: PremiumFooterStyle.dot,
          textColor: context.colors.foregroundMuted,
          onTapRestore: widget.onTapRestore,
        ),
      ],
    );
  }

  Widget _cta(BuildContext context, String label) {
    final colors = context.colors;
    return KasyButton(
      key: const ValueKey('premium_subscribe_button'),
      label: label,
      expand: true,
      size: KasyButtonSize.large,
      backgroundColor: colors.primary,
      foregroundColor: colors.primaryForeground,
      fontWeight: FontWeight.w700,
      isLoading: widget.isLoadingOffers || widget.onTap == null,
      onPressed: widget.onTap,
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final parts = label.split(' ');
    final lead = parts.isNotEmpty ? parts.first : label;
    final rest = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final baseStyle = context.textTheme.bodyLarge?.copyWith(
      color: colors.foreground,
      height: 1.25,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final restColor = Color.lerp(
      colors.foregroundMuted,
      colors.foreground,
      isDark ? 0.34 : 0.28,
    )!;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(KasyRadius.md),
          ),
          child: Icon(icon, size: KasyIconSize.md, color: iconColor),
        ),
        const SizedBox(width: KasySpacing.smd),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: baseStyle,
              children: [
                TextSpan(
                  text: lead,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (rest.isNotEmpty)
                  TextSpan(
                    text: ' $rest',
                    style: TextStyle(
                      color: restColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UnlockPlanCard extends StatelessWidget {
  const _UnlockPlanCard({
    required this.offer,
    required this.selected,
    required this.onTap,
    required this.planLabel,
    required this.priceLine,
    this.trailing,
    this.badge,
  });

  final SubscriptionProduct offer;
  final bool selected;
  final VoidCallback onTap;
  final String planLabel;
  final String priceLine;
  final String? trailing;
  final String? badge;

  static const double _badgeTopInset = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = selected && isDark ? colors.primarySoft : colors.surface;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(top: badge != null ? _badgeTopInset : 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(KasyRadius.lg),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: KasySpacing.smd,
                  vertical: KasySpacing.md,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(KasyRadius.lg),
                  border: Border.all(
                    color: selected ? colors.primary : colors.border,
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: selected && isDark
                      ? [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.22),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: selected
                          ? Icon(
                              KasyIcons.checkCircle,
                              key: const ValueKey('selected'),
                              size: KasyIconSize.md,
                              color: colors.primary,
                            )
                          : Container(
                              key: const ValueKey('unselected'),
                              width: KasyIconSize.md,
                              height: KasyIconSize.md,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.foregroundMuted.withValues(alpha: 0.45),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: KasySpacing.smd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            planLabel,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            priceLine,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: colors.foreground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null)
                      Text(
                        trailing!,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.foregroundMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: 0,
            right: KasySpacing.md,
            child: PaywallShineBadge(
              label: badge!,
              textStyle: context.textTheme.labelSmall!.copyWith(
                color: colors.warningForeground,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
              backgroundColor: colors.warning,
              shineIntensity: KasyShineIntensity.soft,
            ),
          ),
      ],
    );
  }
}
