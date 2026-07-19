import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_progress.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_step_header.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_sticky_footer.dart';
import 'package:flutter/material.dart';

/// No-op for the invisible secondary-action placeholder (never tapped — its
/// [Visibility] keeps it non-interactive). A top-level tear-off so the
/// placeholder can stay `const`.
void onboardingTextStepNoop() {}

/// Text-only onboarding step — same title position, typography and sticky
/// footer as the gender/age hero-question screens, without an illustration.
class OnboardingTextStepScaffold extends StatelessWidget {
  const OnboardingTextStepScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.secondaryVariant = KasyButtonVariant.link,
    this.totalSteps = kOnboardingSteps,
    this.hero,
    this.heroAreaFraction = 0.50,
    this.heroTextSpacing = 0,
  });

  final int step;
  final int totalSteps;
  final String title;
  final String description;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final KasyButtonVariant secondaryVariant;
  final Widget? hero;

  /// Upper slot height as a fraction of the scroll viewport (gender/age use 0.50).
  final double heroAreaFraction;

  /// Extra gap between the hero slot and the title block.
  final double heroTextSpacing;

  static const double _gutter = KasySpacing.lg;

  Widget _textBlock(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: _gutter),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineLarge?.copyWith(
                color: context.colors.onBackground,
              ),
            ),
            const SizedBox(height: KasySpacing.smd),
            Text(
              description,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.muted,
                height: 1.45,
              ),
            ),
          ],
        ),
      );

  Widget _footer(BuildContext context) => DeviceSizeBuilder(
        builder: (device) => OnboardingStickyFooter(
          animate: false,
          maxContentWidth: device == DeviceType.small ? null : 600,
          children: [
            OnboardingProgress(step: step, totalSteps: totalSteps),
            const SizedBox(height: KasySpacing.xl),
            KasyButton(
              label: primaryLabel,
              expand: true,
              onPressed: onPrimary,
            ),
            const SizedBox(height: KasySpacing.xs),
            if (secondaryLabel != null && onSecondary != null)
              KasyButton(
                label: secondaryLabel!,
                variant: secondaryVariant,
                expand: true,
                onPressed: onSecondary,
              )
            else
              const Visibility(
                visible: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: KasyButton(
                  label: ' ',
                  variant: KasyButtonVariant.link,
                  expand: true,
                  onPressed: onboardingTextStepNoop,
                ),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final scrollBody = LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const OnboardingStepHeader(),
                if (hero != null) ...[
                  SizedBox(
                    height: constraints.maxHeight * heroAreaFraction,
                    child: hero,
                  ),
                  SizedBox(height: heroTextSpacing),
                ] else
                  SizedBox(height: constraints.maxHeight * 0.50),
                _textBlock(context),
                const SizedBox(height: KasySpacing.md),
              ],
            ),
          ),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SafeArea(
            bottom: false,
            child: ResponsiveBuilder(
              small: scrollBody,
              medium: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: scrollBody,
                ),
              ),
            ),
          ),
        ),
        _footer(context),
      ],
    );
  }
}
