import 'package:cowboydodartinc/components/kasy_link.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Top onboarding row: an optional leading Back action on the left and an
/// optional trailing Skip action on the right, sitting on the top line.
///
/// The step indicator no longer lives here — it moved down next to the primary
/// action (see [OnboardingProgress] in the sticky footer). When a side has no
/// action, a small spacer keeps the row height stable across steps.
class OnboardingStepHeader extends StatelessWidget {
  const OnboardingStepHeader({
    super.key,
    this.onBack,
    this.backLabel,
    this.onSkip,
    this.skipLabel,
    this.horizontalPadding = KasySpacing.lg,
  });

  final VoidCallback? onBack;
  final String? backLabel;
  final VoidCallback? onSkip;
  final String? skipLabel;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final Color muted = context.colors.muted;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        0,
      ),
      child: Row(
        children: [
          if (onBack != null)
            KasyLink(
              label: backLabel ?? 'Back',
              color: muted,
              onPressed: onBack,
            )
          else
            // Keep the row's height stable across steps that have no Back.
            const SizedBox(height: 20),
          const Spacer(),
          if (onSkip != null)
            KasyLink(
              label: skipLabel ?? 'Skip',
              color: muted,
              onPressed: onSkip,
            )
          else
            const SizedBox(height: 20),
        ],
      ),
    );
  }
}
