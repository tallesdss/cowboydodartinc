import 'package:cowboydodartinc/features/onboarding/models/user_info.dart';
import 'package:cowboydodartinc/features/onboarding/providers/onboarding_provider.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_radio_question.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/selectable_row_tile.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hero image behind the onboarding questions (gender + age). Kept here, next to
/// its users, so the flow can precache it ahead of time — see [OnboardingPage].
const String kQuestionsHeroImage = 'assets/images/ImageAge.jpg';

//--------------------------------------------
/// Question about the user's gender
//--------------------------------------------
class UserGenderOnboardingQuestion extends ConsumerWidget {
  final String nextRoute;

  const UserGenderOnboardingQuestion({
    super.key,
    required this.nextRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = Translations.of(context).onboarding.genderQuestion;
    return OnboardingRadioQuestion(
      title: translations.title,
      description: translations.description,
      btnText: translations.action,
      step: 4,
      layout: OnboardingQuestionLayout.wrap,
      heroImageAsset: kQuestionsHeroImage,
      wrapRowCounts: const [2, 1],
      optionIds: translations.options.keys.toList(),
      optionBuilder: (key, selected) => SelectableChipTile(
        label: translations.options[key] ?? '',
        selected: selected,
      ),
      // here we can add a reassurance message when the user selects an option
      // reassuranceBuilder: (key) => CheckedReassurance(
      //   text: translations.reassurance[key]!,
      // ),
      onValidate: (key) {
        // print("Selected option: $key");
        if (key != null) {
          ref
              .read(onboardingProvider.notifier)
              .onAnsweredQuestion(UserGenderInfo.fromString(key));
        }
        Navigator.of(context).pushReplacementNamed(nextRoute);
      },
    );
  }
}

//--------------------------------------------
/// Question about the user's gender
//--------------------------------------------
class UserAgeOnboardingQuestion extends ConsumerWidget {
  final String nextRoute;

  const UserAgeOnboardingQuestion({
    super.key,
    required this.nextRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = Translations.of(context).onboarding.ageQuestion;
    return OnboardingRadioQuestion(
      title: translations.title,
      description: translations.description,
      btnText: translations.action,
      step: 5,
      layout: OnboardingQuestionLayout.wrap,
      heroImageAsset: kQuestionsHeroImage,
      wrapRowCounts: const [3, 2],
      optionIds: translations.options.keys.toList(),
      optionBuilder: (key, selected) => SelectableChipTile(
        label: translations.options[key] ?? '',
        selected: selected,
      ),
      // here we can add a reassurance message when the user selects an option
      // reassuranceBuilder: (key) => CheckedReassurance(
      //   text: translations.reassurance[key]!,
      // ),
      onValidate: (key) {
        // print("Selected option: $key");
        if (key != null) {
          ref
              .read(onboardingProvider.notifier)
              .onAnsweredQuestion(UserAgeInfo.fromString(key));
        }
        Navigator.of(context).pushReplacementNamed(nextRoute);
      },
    );
  }
}
