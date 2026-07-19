import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_feature.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_module_mockups.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

class OnboardingFeatureOne extends StatelessWidget {
  final String nextRoute;
  final VoidCallback? onSkip;
  final VoidCallback? onLogin;

  const OnboardingFeatureOne({
    super.key,
    required this.nextRoute,
    this.onSkip,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context).onboarding.feature_1;
    return OnboardingStep(
      title: translations.title,
      description: translations.description,
      btnText: translations.action,
      nextRoute: nextRoute,
      step: 1,
      image: const EarningsMockup(),
      onSkip: onSkip,
      skipLabel: translations.skip,
      onSecondary: onLogin,
      secondaryLabel: onLogin != null ? translations.login : null,
    );
  }
}

class OnboardingFeatureTwo extends StatelessWidget {
  final String nextRoute;
  final VoidCallback? onBack;

  const OnboardingFeatureTwo({
    super.key,
    required this.nextRoute,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context).onboarding.feature_2;
    return OnboardingStep(
      title: translations.title,
      description: translations.description,
      btnText: translations.action,
      nextRoute: nextRoute,
      step: 2,
      image: const AuthMockup(),
      onBack: onBack,
      backLabel: translations.back,
    );
  }
}

class OnboardingFeatureThree extends StatelessWidget {
  final String nextRoute;

  const OnboardingFeatureThree({
    super.key,
    required this.nextRoute,
  });

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context).onboarding.feature_3;
    return OnboardingStep(
      title: translations.title,
      description: translations.description,
      btnText: translations.action,
      nextRoute: nextRoute,
      step: 3,
      image: const AiChatMockup(),
    );
  }
}
