import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Faded smartphone outline — thick border, dynamic island, optional bottom bleed.
class OnboardingPhoneFrame extends StatelessWidget {
  const OnboardingPhoneFrame({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  static const double borderWidth = 3.5;
  static const double radius = 38;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final Color edge = context.isDark
        ? colors.outline.withValues(alpha: 0.38)
        : Colors.white;
    final BorderRadius borderRadius = BorderRadius.circular(radius);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.surface.withValues(
                          alpha: context.isDark ? 0.38 : 0.58,
                        ),
                        colors.surface.withValues(
                          alpha: context.isDark ? 0.16 : 0.28,
                        ),
                        colors.surface.withValues(
                          alpha: context.isDark ? 0.06 : 0.10,
                        ),
                      ],
                      stops: const [0.0, 0.62, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(color: edge, width: borderWidth),
              ),
            ),
          ),
          SizedBox(
            width: width,
            child: Column(
              children: [
                const SizedBox(height: KasySpacing.md),
                Container(
                  width: 58,
                  height: 17,
                  decoration: BoxDecoration(
                    color: colors.onBackground.withValues(alpha: 0.08),
                    borderRadius: KasyRadius.fullBorderRadius,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dissolves the phone base into the page background (emerges from below).
class OnboardingPhoneBottomBleed extends StatelessWidget {
  const OnboardingPhoneBottomBleed({super.key});

  @override
  Widget build(BuildContext context) {
    final Color pageBg = Theme.of(context).scaffoldBackgroundColor;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              pageBg.withValues(alpha: 0.0),
              pageBg.withValues(alpha: 0.35),
              pageBg.withValues(alpha: 0.82),
              pageBg,
            ],
            stops: const [0.0, 0.38, 0.72, 1.0],
          ),
        ),
      ),
    );
  }
}
