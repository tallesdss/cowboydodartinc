import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_shine_sweep.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_palette.dart';
import 'package:flutter/material.dart';

/// Paywall savings pill with a periodic mirror-shine sweep.
class PaywallShineBadge extends StatelessWidget {
  const PaywallShineBadge({
    super.key,
    required this.label,
    required this.textStyle,
    required this.backgroundColor,
    this.boxShadow,
    this.shineIntensity = KasyShineIntensity.standard,
    this.padding = const EdgeInsets.symmetric(
      horizontal: KasySpacing.sm,
      vertical: KasySpacing.xs,
    ),
  });

  /// Compare annual savings pill.
  factory PaywallShineBadge.compareSavings({
    required String label,
    required TextStyle textStyle,
  }) {
    return PaywallShineBadge(
      label: label,
      textStyle: textStyle,
      backgroundColor: PaywallComparePalette.badge,
      boxShadow: const [
        BoxShadow(
          color: Color(0x40000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  final String label;
  final TextStyle textStyle;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final KasyShineIntensity shineIntensity;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(KasyRadius.full),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(KasyRadius.full),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: KasyShineSweep(intensity: shineIntensity),
            ),
            Padding(
              padding: padding,
              child: Text(
                label,
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
