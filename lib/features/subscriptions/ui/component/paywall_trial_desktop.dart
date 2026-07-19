import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_desktop_shell.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_trial_palette.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_trial_video_backdrop.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_empty_state.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_offers_skeleton.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_bottom_menu.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/selectable_row.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/cupertino.dart';

/// Desktop web layout for [PaywallTrial]: split modal with video branding panel.
class PaywallTrialDesktop extends StatefulWidget {
  const PaywallTrialDesktop({
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

  static const double _benefitsTopGap = KasySpacing.xxl + KasySpacing.md;
  static const double _benefitsColumnGap = KasySpacing.xl;
  static const double _benefitsRowGap = KasySpacing.lg;

  @override
  State<PaywallTrialDesktop> createState() => _PaywallTrialDesktopState();
}

class _PaywallTrialDesktopState extends State<PaywallTrialDesktop> {
  bool _didInitialOfferSync = false;
  bool _trialEnabled = true;

  SubscriptionProduct? get _annualOffer => _resolveAnnualOffer(widget.offers);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncInitialOffer());
  }

  @override
  void didUpdateWidget(covariant PaywallTrialDesktop oldWidget) {
    super.didUpdateWidget(oldWidget);
    final offersArrived =
        (oldWidget.isLoadingOffers && !widget.isLoadingOffers) ||
        (oldWidget.offers.isEmpty && widget.offers.isNotEmpty);
    if (offersArrived) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncInitialOffer());
    }
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

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty && !widget.isLoadingOffers) {
      return PaywallEmptyState(
        onTapRestore: widget.onTapRestore,
        onSkip: widget.onSkip,
      );
    }

    final copy = Translations.of(context).premium.trialPlan;
    final features = [
      copy.feature_1,
      copy.feature_2,
      copy.feature_3,
      copy.feature_4,
    ];
    final titleStyle = context.kasyTextTheme.titleLarge
        .withWeight(FontWeight.w800)
        .copyWith(
          color: PaywallTrialPalette.onCanvas,
          letterSpacing: -0.3,
        );
    final socialProofStyle = context.kasyTextTheme.pageTitle
        .withWeight(FontWeight.w600)
        .copyWith(
          color: PaywallTrialPalette.onCanvas,
          height: 1.15,
          letterSpacing: -0.2,
        );

    return PaywallDesktopModalShell(
      panelColor: PaywallTrialPalette.canvas,
      onClose: widget.onSkip,
      closeScrim: PaywallTrialPalette.closeScrim,
      closeIconColor: PaywallTrialPalette.onCanvas,
      maxWidth: 980,
      maxHeight: 640,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 42,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const PaywallTrialVideoBackdrop(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        PaywallTrialPalette.canvas,
                        PaywallTrialPalette.canvas.withValues(alpha: 0.35),
                        PaywallTrialPalette.canvas.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    KasySpacing.xxl,
                    KasySpacing.xxxl,
                    KasySpacing.lg,
                    KasySpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: copy.title_before, style: titleStyle),
                            TextSpan(
                              text: copy.title_accent,
                              style: titleStyle.copyWith(
                                color: PaywallTrialPalette.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: KasySpacing.sm),
                      Text(
                        copy.subtitle,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: PaywallTrialPalette.muted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 58,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                KasySpacing.xl,
                KasySpacing.lg,
                KasySpacing.xl,
                KasySpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              copy.social_proof,
                              style: socialProofStyle,
                            ),
                            const SizedBox(height: PaywallTrialDesktop._benefitsTopGap),
                            Wrap(
                              spacing: PaywallTrialDesktop._benefitsColumnGap,
                              runSpacing: PaywallTrialDesktop._benefitsRowGap,
                              children: [
                                for (final feature in features)
                                  SizedBox(
                                    width: 200,
                                    child: _TrialDesktopFeatureRow(
                                      text: feature,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (widget.isLoadingOffers) ...[
                    const PaywallTrialSwitchSkeleton(),
                    const SizedBox(height: KasySpacing.md),
                    const PaywallPriceSkeleton(),
                  ] else ...[
                    _trialToggle(context),
                    const SizedBox(height: KasySpacing.md),
                    _billingLine(context),
                  ],
                  const SizedBox(height: KasySpacing.md),
                  KasyButton(
                    label: _trialEnabled ? copy.cta_trial : copy.cta_no_trial,
                    expand: true,
                    size: KasyButtonSize.large,
                    backgroundColor: PaywallTrialPalette.primary,
                    foregroundColor: PaywallTrialPalette.primaryForeground,
                    fontWeight: FontWeight.w600,
                    isLoading: widget.isLoadingOffers || widget.onTap == null,
                    onPressed: widget.onTap,
                  ),
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
        ],
      ),
    );
  }

  Widget _trialToggle(BuildContext context) {
    final copy = Translations.of(context).premium.trialPlan;
    final label =
        _trialEnabled ? copy.trial_toggle_enabled : copy.trial_toggle_disabled;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.titleMedium!.withWeight(
              FontWeight.w600,
            ).copyWith(
              color: PaywallTrialPalette.onCanvas,
            ),
          ),
        ),
        CupertinoSwitch(
          value: _trialEnabled,
          onChanged: _setTrialEnabled,
          activeTrackColor: PaywallTrialPalette.primary,
          inactiveTrackColor: PaywallTrialPalette.toggleTrackOff,
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

    return Text(
      text,
      style: context.textTheme.bodyLarge!.withWeight(FontWeight.w400).copyWith(
        color: PaywallTrialPalette.muted,
        height: 1.35,
      ),
    );
  }
}

class _TrialDesktopFeatureRow extends StatelessWidget {
  const _TrialDesktopFeatureRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
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
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyLarge!.withWeight(FontWeight.w500).copyWith(
              color: PaywallTrialPalette.onCanvas,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
