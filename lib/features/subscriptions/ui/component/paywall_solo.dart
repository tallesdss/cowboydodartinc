import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_desktop_layout.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_solo_config.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_solo_desktop.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_solo_palette.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_empty_state.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_offers_skeleton.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_bottom_menu.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/selectable_row.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/subscription_product_formatting.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

const String kPaywallSoloHeroImage = 'assets/images/img-plansolo.png';

/// Solo paywall: one plan, hero image + warm gradient, benefits card, yellow CTA.
class PaywallSolo extends StatefulWidget {
  final List<SubscriptionProduct> offers;
  final SubscriptionProduct? selectedOffer;
  final OnSelectItem<SubscriptionProduct> onSelectItem;
  final OnTapSubscription? onTap;
  final OnTap? onTapRestore;
  final OnTap? onSkip;
  final bool isLoadingOffers;

  static const double _maxContentWidth = 460;
  static const double _heroImageLift = -28;
  static const double _topBarActionHeight = 32;

  const PaywallSolo({
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
  State<PaywallSolo> createState() => _PaywallSoloState();
}

class _PaywallSoloState extends State<PaywallSolo> {
  bool _didInitialOfferSync = false;

  SubscriptionProduct? get _featuredOffer =>
      resolvePaywallSoloFeaturedOffer(widget.offers);

  SubscriptionProduct? get _effectiveOffer =>
      widget.selectedOffer ?? _featuredOffer;

  @override
  void initState() {
    super.initState();
    _scheduleFeaturedOfferSync();
  }

  @override
  void didUpdateWidget(covariant PaywallSolo oldWidget) {
    super.didUpdateWidget(oldWidget);
    final offersArrived =
        (oldWidget.isLoadingOffers && !widget.isLoadingOffers) ||
        (oldWidget.offers.isEmpty && widget.offers.isNotEmpty);
    if (offersArrived) {
      _scheduleFeaturedOfferSync();
    }
  }

  void _scheduleFeaturedOfferSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFeaturedOffer());
  }

  void _syncFeaturedOffer() {
    if (!mounted || _didInitialOfferSync) {
      return;
    }
    if (widget.isLoadingOffers || widget.offers.isEmpty) {
      return;
    }
    final featured = _featuredOffer;
    if (featured == null) {
      return;
    }
    _didInitialOfferSync = true;
    if (widget.selectedOffer?.skuId != featured.skuId) {
      widget.onSelectItem(featured);
    }
  }

  bool get _motionReduced => MediaQuery.disableAnimationsOf(context);

  Widget _soloEnter(
    Widget child, {
    int delayMs = 0,
    double slideY = 10,
    bool scale = false,
  }) {
    if (_motionReduced) {
      return child;
    }
    final delay = Duration(milliseconds: delayMs);
    final effects = <Effect>[
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
      if (scale)
        ScaleEffect(
          delay: delay,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          begin: const Offset(0.96, 0.96),
          alignment: Alignment.centerLeft,
        ),
    ];
    return Animate(effects: effects, child: child);
  }

  Widget _soloHeroEnter(Widget child) {
    if (_motionReduced) {
      return child;
    }
    return Animate(
      effects: const [
        FadeEffect(
          duration: Duration(milliseconds: 480),
          curve: Curves.easeOut,
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
          return PaywallSoloDesktop(
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
          backgroundColor: PaywallSoloPalette.canvas,
          body: LayoutBuilder(
            builder: (context, innerConstraints) {
              final bool compact = DeviceType.fromWidth(
                    innerConstraints.maxWidth,
                  ) ==
                  DeviceType.small;
              return compact
                  ? _mobileLayout(context, innerConstraints.maxHeight)
                  : _wideLayout(context);
            },
          ),
        );
      },
    );
  }

  Widget _mobileLayout(BuildContext context, double height) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _heroBackdrop(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: KasySpacing.pageHorizontalGutter,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _soloEnter(_topBar(context), slideY: 6),
                            SizedBox(height: constraints.maxHeight * 0.34),
                            _headline(context),
                            const SizedBox(height: KasySpacing.md),
                            _pricePill(context),
                            const SizedBox(height: KasySpacing.lg),
                            _benefitsCard(context),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  KasySpacing.pageHorizontalGutter,
                  0,
                  KasySpacing.pageHorizontalGutter,
                  KasySpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _soloEnter(_subscribeButton(context), delayMs: 480, slideY: 12),
                    const SizedBox(height: KasySpacing.sm),
                    _soloEnter(
                      const BottomPremiumMenu(
                        style: PremiumFooterStyle.dot,
                        textColor: PaywallSoloPalette.muted,
                      ),
                      delayMs: 520,
                      slideY: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _wideLayout(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _heroBackdrop(),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: PaywallSolo._maxContentWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: KasySpacing.lg,
                vertical: KasySpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _soloEnter(_topBar(context), slideY: 6),
                  const SizedBox(height: 220),
                  _headline(context),
                  const SizedBox(height: KasySpacing.md),
                  _pricePill(context),
                  const SizedBox(height: KasySpacing.lg),
                  _benefitsCard(context),
                  const SizedBox(height: KasySpacing.xl),
                  _soloEnter(_subscribeButton(context), delayMs: 480, slideY: 12),
                  const SizedBox(height: KasySpacing.sm),
                  _soloEnter(
                    const BottomPremiumMenu(
                      style: PremiumFooterStyle.dot,
                      textColor: PaywallSoloPalette.muted,
                    ),
                    delayMs: 520,
                    slideY: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroBackdrop() {
    return _soloHeroEnter(
      Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: PaywallSoloPalette.canvasDeep),
          Transform.translate(
            offset: const Offset(0, PaywallSolo._heroImageLift),
            child: Image.asset(
              kPaywallSoloHeroImage,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  PaywallSoloPalette.canvas,
                  PaywallSoloPalette.canvas,
                  PaywallSoloPalette.canvas.withValues(alpha: 0.92),
                  PaywallSoloPalette.canvas.withValues(alpha: 0.45),
                  PaywallSoloPalette.canvasDeep.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.42, 0.58, 0.78, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    final solo = Translations.of(context).premium.solo;
    final textStyle = context.textTheme.bodyMedium!.copyWith(
      color: PaywallSoloPalette.onCanvas,
      fontWeight: FontWeight.w500,
    );
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: PaywallSolo._topBarActionHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: widget.onSkip,
                borderRadius: BorderRadius.circular(KasyRadius.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      KasyIcons.arrowBackIos,
                      size: KasyIconSize.sm,
                      color: PaywallSoloPalette.onCanvas,
                    ),
                    const SizedBox(width: KasySpacing.xs),
                    Text(solo.back, style: textStyle),
                  ],
                ),
              ),
            ),
            if (widget.onTapRestore != null)
              Align(
                alignment: Alignment.centerRight,
                child: _restoreButton(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _restoreButton(BuildContext context) {
    final label = Translations.of(context).premium.restore_action;
    final restoreTextStyle = context.textTheme.bodyMedium!.copyWith(
      color: PaywallSoloPalette.onCanvas.withValues(alpha: 0.82),
      fontWeight: FontWeight.w500,
    );
    return SizedBox(
      height: PaywallSolo._topBarActionHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTapRestore,
          borderRadius: BorderRadius.circular(KasyRadius.sm),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: PaywallSoloPalette.canvasDeep.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(KasyRadius.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: KasySpacing.sm),
              child: Center(
                child: Text(label, style: restoreTextStyle),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headline(BuildContext context) {
    final solo = Translations.of(context).premium.solo;
    final style = context.kasyTextTheme.displaySmall.withWeight(FontWeight.w400).copyWith(
      color: PaywallSoloPalette.onCanvas,
      height: 1.12,
      letterSpacing: -0.8,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _soloEnter(Text(solo.headline_1, style: style), delayMs: 100),
        _soloEnter(Text(solo.headline_2, style: style), delayMs: 180),
      ],
    );
  }

  Widget _pricePill(BuildContext context) {
    return _soloEnter(
      Align(
        alignment: Alignment.centerLeft,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          child: widget.isLoadingOffers
              ? const PaywallPriceSkeleton(key: ValueKey('solo-price-loading'))
              : _pricePillContent(context),
        ),
      ),
      delayMs: 260,
      slideY: 8,
      scale: true,
    );
  }

  Widget _pricePillContent(BuildContext context) {
    final offer = _effectiveOffer;
    if (offer == null) {
      return const SizedBox.shrink(key: ValueKey('solo-price-empty'));
    }
    final suffix = offer.pricePeriodSuffix(context);
    return Container(
      key: ValueKey(offer.skuId),
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.sm,
      ),
      decoration: BoxDecoration(
        color: PaywallSoloPalette.pricePill,
        borderRadius: BorderRadius.circular(KasyRadius.full),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: offer.priceString,
              style: context.textTheme.titleLarge?.copyWith(
                color: PaywallSoloPalette.pricePillText,
                fontWeight: FontWeight.w800,
                height: 1.0,
                letterSpacing: -0.3,
              ),
            ),
            if (suffix.isNotEmpty)
              TextSpan(
                text: suffix,
                style: context.textTheme.titleSmall?.copyWith(
                  color: PaywallSoloPalette.pricePillText,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _benefitsCard(BuildContext context) {
    final solo = Translations.of(context).premium.solo;
    final items = <({IconData icon, String label})>[
      (icon: KasyIcons.notificationOff, label: solo.feature_1),
      (icon: KasyIcons.download, label: solo.feature_2),
      (icon: KasyIcons.flash, label: solo.feature_3),
      (icon: KasyIcons.video, label: solo.feature_4),
    ];
    final rows = [
      for (var i = 0; i < items.length; i++)
        _SoloBenefitRow(
          icon: items[i].icon,
          label: items[i].label,
        ),
    ];

    if (_motionReduced) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.md,
          vertical: KasySpacing.smd,
        ),
        decoration: BoxDecoration(
          color: PaywallSoloPalette.card,
          borderRadius: BorderRadius.circular(KasyRadius.xl),
          border: Border.all(color: PaywallSoloPalette.cardBorder),
        ),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const SizedBox(height: KasySpacing.sm),
              rows[i],
            ],
          ],
        ),
      );
    }

    return _soloEnter(
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.md,
          vertical: KasySpacing.smd,
        ),
        decoration: BoxDecoration(
          color: PaywallSoloPalette.card,
          borderRadius: BorderRadius.circular(KasyRadius.xl),
          border: Border.all(color: PaywallSoloPalette.cardBorder),
        ),
        child: Column(
          children: AnimateList(
            interval: 75.ms,
            delay: 360.ms,
            effects: [
              FadeEffect(duration: 280.ms, curve: Curves.easeOut),
              MoveEffect(
                duration: 320.ms,
                curve: Curves.easeOut,
                begin: const Offset(-0.03, 0),
                end: Offset.zero,
              ),
            ],
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: KasySpacing.sm),
                rows[i],
              ],
            ],
          ),
        ),
      ),
      delayMs: 320,
      slideY: 12,
    );
  }

  Widget _subscribeButton(BuildContext context) {
    final solo = Translations.of(context).premium.solo;
    return KasyButton(
      label: solo.subscribe,
      expand: true,
      size: KasyButtonSize.large,
      backgroundColor: PaywallSoloPalette.primary,
      foregroundColor: PaywallSoloPalette.primaryForeground,
      fontWeight: FontWeight.w600,
      isLoading: widget.isLoadingOffers || widget.onTap == null,
      onPressed: widget.onTap,
    );
  }
}

class _SoloBenefitRow extends StatelessWidget {
  const _SoloBenefitRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: KasyIconSize.md,
          color: PaywallSoloPalette.onCanvas,
        ),
        const SizedBox(width: KasySpacing.md),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyLarge?.copyWith(
              color: PaywallSoloPalette.onCanvas,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: PaywallSoloPalette.checkFill,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            KasyIcons.check,
            size: KasyIconSize.sm,
            color: PaywallSoloPalette.checkIcon,
          ),
        ),
      ],
    );
  }
}
