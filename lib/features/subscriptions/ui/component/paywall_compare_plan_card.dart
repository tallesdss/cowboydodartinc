import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_palette.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/widgets/paywall_shine_badge.dart';
import 'package:flutter/material.dart';

/// Monthly/annual picker card shared by compare paywalls.
class PaywallComparePlanCard extends StatelessWidget {
  const PaywallComparePlanCard({
    super.key,
    required this.offer,
    required this.selected,
    required this.onTap,
    required this.planLabel,
    required this.priceLine,
    required this.subtitle,
    required this.badgeTopInset,
    this.badge,
    this.desktopScale = false,
  });

  final SubscriptionProduct offer;
  final bool selected;
  final VoidCallback onTap;
  final String planLabel;
  final String priceLine;
  final String subtitle;
  final double badgeTopInset;
  final String? badge;
  final bool desktopScale;

  static const double badgeReserveHeight = KasySpacing.smd;
  static const double bodyHeight = 136;
  static const double desktopBodyHeight = 160;

  @override
  Widget build(BuildContext context) {
    final cardPadding = desktopScale
        ? const EdgeInsets.fromLTRB(
            KasySpacing.md,
            KasySpacing.lg,
            KasySpacing.md,
            KasySpacing.lg,
          )
        : const EdgeInsets.fromLTRB(
            KasySpacing.smd,
            KasySpacing.md,
            KasySpacing.smd,
            KasySpacing.md,
          );
    final planLabelStyle = desktopScale
        ? context.textTheme.titleMedium?.copyWith(
            color: PaywallComparePalette.onCanvas,
            fontWeight: FontWeight.w600,
          )
        : context.textTheme.titleSmall?.copyWith(
            color: PaywallComparePalette.onCanvas,
            fontWeight: FontWeight.w600,
          );
    final priceStyle = desktopScale
        ? context.textTheme.headlineMedium!
            .withWeight(FontWeight.w700)
            .copyWith(
              color: PaywallComparePalette.onCanvas,
              height: 1.0,
              letterSpacing: -0.4,
            )
        : context.textTheme.headlineSmall!
            .withWeight(FontWeight.w700)
            .copyWith(
              color: PaywallComparePalette.onCanvas,
              height: 1.0,
              letterSpacing: -0.4,
            );
    final subtitleStyle = desktopScale
        ? context.textTheme.bodyMedium?.copyWith(
            color: PaywallComparePalette.subtle,
            height: 1.25,
          )
        : context.textTheme.bodySmall?.copyWith(
            color: PaywallComparePalette.subtle,
            height: 1.25,
          );
    final badgeStyle = desktopScale
        ? context.textTheme.labelLarge?.copyWith(
            color: PaywallComparePalette.badgeText,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          )
        : context.textTheme.labelSmall?.copyWith(
            color: PaywallComparePalette.badgeText,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          );
    final labelPriceGap = desktopScale ? KasySpacing.md : KasySpacing.sm;
    final priceSubtitleGap = desktopScale ? KasySpacing.sm : KasySpacing.xs;

    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: badgeTopInset,
          bottom: 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(KasyRadius.lg),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: cardPadding,
                decoration: BoxDecoration(
                  color: selected
                      ? PaywallComparePalette.cardSelected
                      : PaywallComparePalette.card,
                  borderRadius: BorderRadius.circular(KasyRadius.lg),
                  border: Border.all(
                    color: selected
                        ? PaywallComparePalette.borderSelected
                        : PaywallComparePalette.border,
                    width: 2,
                  ),
                  boxShadow: selected
                      ? const [
                          BoxShadow(
                            color: PaywallComparePalette.glow,
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            planLabel,
                            style: planLabelStyle,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: selected
                              ? const Icon(
                                  KasyIcons.checkCircle,
                                  key: ValueKey('selected'),
                                  size: KasyIconSize.md,
                                  color: PaywallComparePalette.primary,
                                )
                              : Container(
                                  key: const ValueKey('unselected'),
                                  width: KasyIconSize.md,
                                  height: KasyIconSize.md,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: PaywallComparePalette.subtle
                                          .withValues(alpha: 0.45),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: labelPriceGap),
                    Text(
                      priceLine,
                      style: priceStyle,
                    ),
                    SizedBox(height: priceSubtitleGap),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: subtitleStyle,
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
            left: 0,
            right: 0,
            child: Center(
              child: PaywallShineBadge.compareSavings(
                label: badge!,
                textStyle: badgeStyle ?? context.kasyTextTheme.caption,
              ),
            ),
          ),
      ],
    );
  }
}
