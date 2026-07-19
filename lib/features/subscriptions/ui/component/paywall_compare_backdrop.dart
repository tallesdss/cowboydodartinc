import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_compare_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Radial glow backdrop shared by [PaywallCompare] and [PaywallCompareDesktop].
class PaywallCompareBackdrop extends StatelessWidget {
  const PaywallCompareBackdrop({
    super.key,
    this.motionReduced = false,
  });

  final bool motionReduced;

  @override
  Widget build(BuildContext context) {
    final glow = motionReduced
        ? const SizedBox.shrink()
        : Animate(
            effects: const [
              FadeEffect(
                duration: Duration(milliseconds: 600),
                curve: Curves.easeOut,
              ),
            ],
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.85),
                  radius: 1.15,
                  colors: [
                    PaywallComparePalette.glow,
                    PaywallComparePalette.canvas.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: PaywallComparePalette.canvasDeep),
        glow,
      ],
    );
  }
}
