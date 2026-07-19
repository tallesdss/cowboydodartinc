import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_desktop_shell.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_solo.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_solo_config.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_solo_palette.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_empty_state.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_offers_skeleton.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/premium_bottom_menu.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/selectable_row.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/subscription_product_formatting.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Desktop web layout for [PaywallSolo]: centered modal with hero banner.
class PaywallSoloDesktop extends StatefulWidget {
  static const double _heroBannerHeight = 200;
  static const double _heroGradientBleed = 64;
  static const Alignment _heroImageAlignment = Alignment(0, -0.5);

  const PaywallSoloDesktop({
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
  State<PaywallSoloDesktop> createState() => _PaywallSoloDesktopState();
}

class _PaywallSoloDesktopState extends State<PaywallSoloDesktop> {
  bool _didInitialOfferSync = false;

  SubscriptionProduct? get _featuredOffer =>
      resolvePaywallSoloFeaturedOffer(widget.offers);

  SubscriptionProduct? get _effectiveOffer =>
      widget.selectedOffer ?? _featuredOffer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFeaturedOffer());
  }

  @override
  void didUpdateWidget(covariant PaywallSoloDesktop oldWidget) {
    super.didUpdateWidget(oldWidget);
    final offersArrived =
        (oldWidget.isLoadingOffers && !widget.isLoadingOffers) ||
        (oldWidget.offers.isEmpty && widget.offers.isNotEmpty);
    if (offersArrived) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncFeaturedOffer());
    }
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

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty && !widget.isLoadingOffers) {
      return PaywallEmptyState(
        onTapRestore: widget.onTapRestore,
        onSkip: widget.onSkip,
      );
    }

    final solo = Translations.of(context).premium.solo;
    final headlineStyle = context.kasyTextTheme.pageTitle
        .withWeight(FontWeight.w500)
        .copyWith(
          color: PaywallSoloPalette.onCanvas,
          height: 1.12,
          letterSpacing: -0.5,
        );
    final features = <({IconData icon, String label})>[
      (icon: KasyIcons.notificationOff, label: solo.feature_1),
      (icon: KasyIcons.download, label: solo.feature_2),
      (icon: KasyIcons.flash, label: solo.feature_3),
      (icon: KasyIcons.video, label: solo.feature_4),
    ];

    return PaywallDesktopModalShell(
      panelColor: PaywallSoloPalette.canvas,
      onClose: widget.onSkip,
      closeScrim: PaywallSoloPalette.cardBorder.withValues(alpha: 0.9),
      closeIconColor: PaywallSoloPalette.onCanvas,
      maxWidth: 880,
      maxHeight: 620,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: PaywallSoloDesktop._heroBannerHeight,
                width: double.infinity,
                child: Image.asset(
                  kPaywallSoloHeroImage,
                  fit: BoxFit.cover,
                  alignment: PaywallSoloDesktop._heroImageAlignment,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height:
                    PaywallSoloDesktop._heroBannerHeight +
                    PaywallSoloDesktop._heroGradientBleed,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          PaywallSoloPalette.canvas,
                          PaywallSoloPalette.canvas.withValues(alpha: 0.96),
                          PaywallSoloPalette.canvas.withValues(alpha: 0.68),
                          PaywallSoloPalette.canvas.withValues(alpha: 0.24),
                          PaywallSoloPalette.canvasDeep.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.24, 0.48, 0.74, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ColoredBox(
              color: PaywallSoloPalette.canvas,
              child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                KasySpacing.xxl,
                KasySpacing.lg,
                KasySpacing.xxl,
                KasySpacing.lg,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(solo.headline_1, style: headlineStyle),
                        Text(solo.headline_2, style: headlineStyle),
                        const SizedBox(height: KasySpacing.lg),
                        if (widget.isLoadingOffers)
                          const PaywallPriceSkeleton()
                        else
                          _pricePill(context),
                      ],
                    ),
                  ),
                  const SizedBox(width: KasySpacing.xxl),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(KasySpacing.lg),
                      decoration: BoxDecoration(
                        color: PaywallSoloPalette.card,
                        borderRadius: BorderRadius.circular(KasyRadius.xl),
                        border: Border.all(color: PaywallSoloPalette.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < features.length; i++) ...[
                            if (i > 0) const SizedBox(height: KasySpacing.sm),
                            _SoloDesktopBenefitRow(
                              icon: features[i].icon,
                              label: features[i].label,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              KasySpacing.xxl,
              0,
              KasySpacing.xxl,
              KasySpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KasyButton(
                  label: solo.subscribe,
                  expand: true,
                  size: KasyButtonSize.large,
                  backgroundColor: PaywallSoloPalette.primary,
                  foregroundColor: PaywallSoloPalette.primaryForeground,
                  fontWeight: FontWeight.w600,
                  isLoading: widget.isLoadingOffers || widget.onTap == null,
                  onPressed: widget.onTap,
                ),
                const SizedBox(height: KasySpacing.sm),
                BottomPremiumMenu(
                  style: PremiumFooterStyle.dot,
                  textColor: PaywallSoloPalette.muted,
                  onTapRestore: widget.onTapRestore,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pricePill(BuildContext context) {
    final offer = _effectiveOffer;
    if (offer == null) {
      return const SizedBox.shrink();
    }
    final suffix = offer.pricePeriodSuffix(context);
    return Container(
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
              ),
            ),
            if (suffix.isNotEmpty)
              TextSpan(
                text: suffix,
                style: context.textTheme.titleSmall?.copyWith(
                  color: PaywallSoloPalette.pricePillText,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SoloDesktopBenefitRow extends StatelessWidget {
  const _SoloDesktopBenefitRow({
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
          width: 24,
          height: 24,
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
