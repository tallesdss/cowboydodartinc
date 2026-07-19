import 'package:cowboydodartinc/core/data/api/analytics_api.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/onboarding/providers/onboarding_provider.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_att_privacy_showcase.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_background.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_text_step_scaffold.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ATT Permission Step
/// ATT is only available on iOS
/// This is the consent screen for iOS 14+ that asks the user to allow the app to access the ATT framework
/// In a few words you need this to get the IDFA (Identifier for Advertisers) which is used for tracking purposes
/// So you can create better facebook ads, google ads, etc...
class AttPermissionStep extends ConsumerWidget {
  final String nextRoute;

  const AttPermissionStep({
    super.key,
    required this.nextRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = Translations.of(context).onboarding.att;

    return OnboardingBackground(
      child: OnboardingTextStepScaffold(
        step: 7,
        hero: const OnboardingAttPrivacyShowcase(),
        heroAreaFraction: 0.66,
        heroTextSpacing: KasySpacing.md,
        title: translations.title,
        description: translations.description,
        primaryLabel: translations.continue_button,
        onPrimary: () async {
          try {
            await ref.onboardingNotifier.requestAtt();
          } finally {
            if (context.mounted) {
              Navigator.of(context).pushNamed(nextRoute);
            }
          }
        },
        secondaryLabel: translations.skip_button,
        onSecondary: () {
          ref.read(analyticsApiProvider).logEvent('setup_att_refused', {});
          Navigator.of(context).pushNamed(nextRoute);
        },
      ),
    );
  }
}
