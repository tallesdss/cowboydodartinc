import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_progress.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_step_header.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_sticky_footer.dart';
import 'package:flutter/material.dart';

/// Shared "clean premium" layout for onboarding steps:
/// segmented progress + step counter on top, a centered hero (live module
/// mockup) filling the upper area, then a left‑aligned title/description block
/// sitting just above a sticky footer with the primary actions.
class OnboardingIllustrationScaffold extends StatelessWidget {
  const OnboardingIllustrationScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.description,
    required this.footerActions,
    this.totalSteps = kOnboardingSteps,
    this.image,
    this.imageMaxHeight = 320,
    this.titleWidget,
    this.descriptionWidget,
    this.footerAnimationDelayMs = 360,
    // Onboarding illustration steps are animation‑free by default.
    this.animateFooter = false,
    this.onBack,
    this.backLabel,
    this.onSkip,
    this.skipLabel,
  });

  final int step;
  final int totalSteps;
  final String title;
  final String description;
  final Widget? image;
  final List<Widget> footerActions;
  final double imageMaxHeight;
  final Widget? titleWidget;
  final Widget? descriptionWidget;
  final int footerAnimationDelayMs;
  final bool animateFooter;
  final VoidCallback? onBack;
  final String? backLabel;
  final VoidCallback? onSkip;
  final String? skipLabel;

  static const double _gutter = KasySpacing.lg;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final Widget header = OnboardingStepHeader(
      onBack: onBack,
      backLabel: backLabel,
      onSkip: onSkip,
      skipLabel: skipLabel,
    );

    final Widget hero = image == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: Center(
              // Scales the mockup to fit the available space (never upscales
              // beyond its natural size). No fixed height cap, so a tall mockup
              // never overflows its own box.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                // No entrance animation — the hero appears instantly.
                child: image,
              ),
            ),
          );

    final Widget textBlock = Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, KasySpacing.md, _gutter, 0),
      child: Column(
        // Centered hero block (title + subtitle), matching the clean
        // single‑column onboarding reference. (Column centers cross‑axis by
        // default, so no explicit crossAxisAlignment needed.)
        children: [
          titleWidget ??
              Text(
                title,
                textAlign: TextAlign.center,
                // Hero title scale (headlineLarge = 28/w800): bold, centered.
                style: context.textTheme.headlineLarge?.copyWith(
                  color: colors.onBackground,
                ),
              ),
          const SizedBox(height: KasySpacing.smd),
          descriptionWidget ??
              Text(
                description,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: colors.muted,
                  height: 1.45,
                ),
              ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SafeArea(
            bottom: false,
            // Fill the screen on tall devices (hero centered), but scroll
            // gracefully on short ones instead of overflowing.
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          header,
                          Expanded(child: Center(child: hero)),
                          textBlock,
                          // Extra breathing room below lifts the title/subtitle
                          // block up off the footer.
                          const SizedBox(height: KasySpacing.lg),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        OnboardingStickyFooter(
          animate: animateFooter,
          animationDelayMs: footerAnimationDelayMs,
          children: [
            // Step indicator now lives just above the primary action; the
            // larger gap below lifts it (and the whole bottom cluster) up.
            OnboardingProgress(step: step, totalSteps: totalSteps),
            const SizedBox(height: KasySpacing.xl),
            ...footerActions,
          ],
        ),
      ],
    );
  }
}
