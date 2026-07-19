import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_background.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_illustration_scaffold.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_progress.dart';
import 'package:flutter/material.dart';

/// No-op for the invisible secondary-action placeholder (never tapped, since
/// its [Visibility] keeps it non-interactive). A top-level tear-off so the
/// placeholder can stay `const`.
void _noop() {}

/// A generic onboarding presentation step: a live module mockup as hero, a
/// left‑aligned title/description and a sticky primary action.
class OnboardingStep extends StatelessWidget {
  final String title;
  final String description;
  final String btnText;
  final String nextRoute;
  final int step;
  final int totalSteps;
  final Widget image;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final String? backLabel;
  final VoidCallback? onSkip;
  final String? skipLabel;
  final VoidCallback? onSecondary;
  final String? secondaryLabel;

  const OnboardingStep({
    super.key,
    required this.title,
    required this.description,
    required this.btnText,
    required this.nextRoute,
    required this.step,
    required this.image,
    this.totalSteps = kOnboardingSteps,
    this.onNext,
    this.onBack,
    this.backLabel,
    this.onSkip,
    this.skipLabel,
    this.onSecondary,
    this.secondaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingBackground(
      child: OnboardingIllustrationScaffold(
        step: step,
        totalSteps: totalSteps,
        title: title,
        description: description,
        image: image,
        onBack: onBack,
        backLabel: backLabel,
        onSkip: onSkip,
        skipLabel: skipLabel,
        footerActions: [
          KasyButton(
            label: btnText,
            expand: true,
            onPressed: () {
              if (onNext != null) {
                onNext!.call();
              } else {
                Navigator.of(context).pushReplacementNamed(nextRoute);
              }
            },
          ),
          const SizedBox(height: KasySpacing.xs),
          if (onSecondary != null && secondaryLabel != null)
            KasyButton(
              label: secondaryLabel!,
              variant: KasyButtonVariant.link,
              expand: true,
              onPressed: onSecondary,
            )
          else
            // Reserve the secondary action's exact footprint on steps that have
            // none, so the step indicator and primary button sit at the same
            // height on every feature step (identical layout across screens).
            const Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: KasyButton(
                label: ' ',
                variant: KasyButtonVariant.link,
                expand: true,
                onPressed: _noop,
              ),
            ),
        ],
      ),
    );
  }
}
