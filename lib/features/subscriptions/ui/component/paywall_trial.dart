import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_desktop_layout.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_trial_desktop.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_trial_palette.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_trial_video_backdrop.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_empty_state.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_offers_skeleton.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_bottom_menu.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_close_button.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/selectable_row.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Trial paywall: looping video hero, one annual plan, trial toggle, purple CTA.
///
/// The toggle is UI-only: ON starts with free trial copy, OFF charges the annual
/// plan immediately. Same [SubscriptionProduct] is purchased in both cases.
class PaywallTrial extends StatefulWidget {
  final List<SubscriptionProduct> offers;
  final SubscriptionProduct? selectedOffer;
  final OnSelectItem<SubscriptionProduct> onSelectItem;
  final OnTapSubscription? onTap;
  final OnTap? onTapRestore;
  final OnTap? onSkip;
  final bool isLoadingOffers;

  static const double _maxContentWidth = 460;

  const PaywallTrial({
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
  State<PaywallTrial> createState() => _PaywallTrialState();
}

class _PaywallTrialState extends State<PaywallTrial> {
  bool _didInitialOfferSync = false;
  bool _trialEnabled = true;

  SubscriptionProduct? get _annualOffer => _resolveAnnualOffer(widget.offers);

  bool get _motionReduced => MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    _scheduleInitialOfferSync();
  }

  @override
  void didUpdateWidget(covariant PaywallTrial oldWidget) {
    super.didUpdateWidget(oldWidget);
    final offersArrived =
        (oldWidget.isLoadingOffers && !widget.isLoadingOffers) ||
        (oldWidget.offers.isEmpty && widget.offers.isNotEmpty);
    if (offersArrived) {
      _scheduleInitialOfferSync();
    }
  }

  void _scheduleInitialOfferSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncInitialOffer());
  }

  void _syncInitialOffer() {
    if (!mounted || _didInitialOfferSync) {
      return;
    }
    if (widget.isLoadingOffers || widget.offers.isEmpty) {
      return;
    }

    final target = _annualOffer ?? widget.offers.first;

    _didInitialOfferSync = true;
    _trialEnabled = true;

    if (widget.selectedOffer?.skuId != target.skuId) {
      widget.onSelectItem(target);
    }
  }

  SubscriptionProduct? _resolveAnnualOffer(List<SubscriptionProduct> offers) {
    for (final offer in offers) {
      if (offer.durationType == DurationType.year) {
        return offer;
      }
    }
    return null;
  }

  void _setTrialEnabled(bool enabled) {
    if (_trialEnabled == enabled) {
      return;
    }
    KasyHaptics.heavy(context);
    setState(() => _trialEnabled = enabled);
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
          return PaywallTrialDesktop(
            offers: widget.offers,
            selectedOffer: widget.selectedOffer,
            onSelectItem: widget.onSelectItem,
            onTap: widget.onTap,
            onTapRestore: widget.onTapRestore,
            onSkip: widget.onSkip,
            isLoadingOffers: widget.isLoadingOffers,
          );
        }
        return _buildMobileLayout(context, constraints);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints) {
    final compact =
        DeviceType.fromWidth(constraints.maxWidth) == DeviceType.small;
    return Scaffold(
      backgroundColor: PaywallTrialPalette.canvas,
      body: LayoutBuilder(
        builder: (context, innerConstraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              const PaywallTrialVideoBackdrop(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _scrollBody(
                      context,
                      compact: compact,
                      height: constraints.maxHeight,
                    ),
                  ),
                  _bottomControls(context, compact: compact),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _scrollBody(
    BuildContext context, {
    required bool compact,
    required double height,
  }) {
    final topInset = MediaQuery.paddingOf(context).top;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        compact ? KasySpacing.pageHorizontalGutter : KasySpacing.lg,
        topInset + KasySpacing.sm,
        compact ? KasySpacing.pageHorizontalGutter : KasySpacing.lg,
        KasySpacing.lg,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: compact ? double.infinity : PaywallTrial._maxContentWidth,
            minHeight: height * 0.55,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Transform.translate(
                  offset: const Offset(0, -KasySpacing.xs),
                  child: Row(
                    children: [
                      const Spacer(),
                      AppCloseButton(
                        onTap: widget.onSkip,
                        backgroundColor: PaywallTrialPalette.closeScrim,
                        iconColor: PaywallTrialPalette.onCanvas,
                        pressOverlayColor:
                            PaywallTrialPalette.onCanvas.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.17),
                _headline(context),
                const SizedBox(height: KasySpacing.sm),
                _subtitleBlock(context),
                const SizedBox(height: KasySpacing.xl),
                _featureList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomControls(BuildContext context, {required bool compact}) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? KasySpacing.pageHorizontalGutter : KasySpacing.lg,
          0,
          compact ? KasySpacing.pageHorizontalGutter : KasySpacing.lg,
          bottomInset > 0 ? bottomInset : KasySpacing.lg,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: compact ? double.infinity : PaywallTrial._maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.isLoadingOffers)
                  const PaywallTrialSwitchSkeleton()
                else
                  _enter(_trialToggle(context), delayMs: 420),
                const SizedBox(height: KasySpacing.md),
                if (widget.isLoadingOffers)
                  const PaywallPriceSkeleton()
                else
                  _enter(_billingLine(context), delayMs: 460),
                const SizedBox(height: KasySpacing.md),
                _enter(_cta(context), delayMs: 500, slideY: 12),
                const SizedBox(height: KasySpacing.sm),
                BottomPremiumMenu(
                  style: PremiumFooterStyle.dot,
                  textColor: PaywallTrialPalette.muted,
                  onTapRestore: widget.onTapRestore,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headline(BuildContext context) {
    final copy = Translations.of(context).premium.trialPlan;
    final baseStyle = context.kasyTextTheme.displaySmall
        .withWeight(FontWeight.w800)
        .copyWith(
          color: PaywallTrialPalette.onCanvas,
          letterSpacing: -0.5,
          height: 1.05,
        );
    final accentStyle = baseStyle.copyWith(color: PaywallTrialPalette.primary);

    return _enter(
      Text.rich(
        TextSpan(
          children: [
            TextSpan(text: copy.title_before, style: baseStyle),
            TextSpan(text: copy.title_accent, style: accentStyle),
          ],
        ),
        textAlign: TextAlign.center,
      ),
      delayMs: 80,
    );
  }

  Widget _subtitleBlock(BuildContext context) {
    final copy = Translations.of(context).premium.trialPlan;
    return _enter(
      Column(
        children: [
          Text(
            copy.subtitle,
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium!
                .withWeight(FontWeight.w300)
                .copyWith(
                  color: PaywallTrialPalette.onCanvas,
                  height: 1.25,
                ),
          ),
          const SizedBox(height: KasySpacing.xs),
          Text(
            copy.social_proof,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: PaywallTrialPalette.muted,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
        ],
      ),
      delayMs: 120,
    );
  }

  Widget _featureList(BuildContext context) {
    final copy = Translations.of(context).premium.trialPlan;
    final features = [copy.feature_1, copy.feature_2, copy.feature_3];

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < features.length; i++)
            _enter(
              _TrialFeatureRow(text: features[i]),
              delayMs: 220 + (i * 60),
            ),
        ],
      ),
    );
  }

  Widget _trialToggle(BuildContext context) {
    final copy = Translations.of(context).premium.trialPlan;
    final label = _trialEnabled ? copy.trial_toggle_enabled : copy.trial_toggle_disabled;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.titleSmall?.copyWith(
              color: PaywallTrialPalette.onCanvas,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Transform.scale(
          scale: 0.88,
          alignment: Alignment.centerRight,
          child: CupertinoSwitch(
            value: _trialEnabled,
            onChanged: _setTrialEnabled,
            activeTrackColor: PaywallTrialPalette.primary,
            inactiveTrackColor: PaywallTrialPalette.toggleTrackOff,
          ),
        ),
      ],
    );
  }

  Widget _billingLine(BuildContext context) {
    final copy = Translations.of(context).premium.trialPlan;
    final offer = _annualOffer ?? widget.selectedOffer;
    final price = offer?.priceString ?? '';
    final trialDays = offer?.trialDays ?? 0;

    final text = _trialEnabled && trialDays > 0
        ? copy.billing_trial(days: trialDays, price: price)
        : copy.billing_annual(price: price);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: Text(
        key: ValueKey(text),
        text,
        textAlign: TextAlign.center,
        style: context.textTheme.bodyMedium?.copyWith(
          color: PaywallTrialPalette.muted,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _cta(BuildContext context) {
    final copy = Translations.of(context).premium.trialPlan;
    final label = _trialEnabled ? copy.cta_trial : copy.cta_no_trial;

    return KasyButton(
      label: label,
      expand: true,
      size: KasyButtonSize.large,
      backgroundColor: PaywallTrialPalette.primary,
      foregroundColor: PaywallTrialPalette.primaryForeground,
      fontWeight: FontWeight.w600,
      isLoading: widget.isLoadingOffers || widget.onTap == null,
      onPressed: widget.onTap,
    );
  }
}

class _TrialFeatureRow extends StatelessWidget {
  const _TrialFeatureRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KasySpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: PaywallTrialPalette.checkFill,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              KasyIcons.check,
              size: 14,
              color: PaywallTrialPalette.checkIcon,
            ),
          ),
          const SizedBox(width: KasySpacing.sm),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: context.kasyTextTheme.bodyMedium.withWeight(FontWeight.w500).copyWith(
                color: PaywallTrialPalette.onCanvas,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
