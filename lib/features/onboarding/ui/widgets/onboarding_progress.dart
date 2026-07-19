import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Total number of progress steps shown across the onboarding flow.
///
/// feature 1‑3 → steps 1‑3, gender → 4, age → 5, push → 6, ATT → 7.
const int kOnboardingSteps = 7;

/// Minimal step indicator (Zero‑style): the current step is a short pill/bar,
/// every other step is a dot. Completed dots use the brand color; upcoming dots
/// fade into a faint track. No numbering — the shape alone communicates
/// progress. Centered, so it reads as a calm caption above the primary action.
class OnboardingProgress extends StatelessWidget {
  /// 1‑based index of the current step.
  final int step;
  final int totalSteps;

  const OnboardingProgress({
    super.key,
    required this.step,
    this.totalSteps = kOnboardingSteps,
  });

  static const double _dot = 7;
  static const double _barWidth = 22;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final track = colors.primary.withValues(alpha: context.isDark ? 0.20 : 0.14);
    final current = step - 1; // 0‑based

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (i) {
        final isCurrent = i == current;
        final isCompleted = i < current;
        final isLast = i == totalSteps - 1;

        return Padding(
          padding: EdgeInsets.only(right: isLast ? 0 : KasySpacing.xs),
          child: Container(
            width: isCurrent ? _barWidth : _dot,
            height: _dot,
            decoration: BoxDecoration(
              color: (isCurrent || isCompleted) ? colors.primary : track,
              borderRadius: KasyRadius.fullBorderRadius,
            ),
          ),
        );
      }),
    );
  }
}
