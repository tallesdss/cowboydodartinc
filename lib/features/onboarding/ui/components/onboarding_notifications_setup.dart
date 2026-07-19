import 'package:cowboydodartinc/core/data/api/analytics_api.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/onboarding/providers/onboarding_provider.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_background.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_notification_toast_showcase.dart';
import 'package:cowboydodartinc/features/onboarding/ui/widgets/onboarding_text_step_scaffold.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPermissionStep extends ConsumerWidget {
  final String nextRoute;

  const NotificationsPermissionStep({
    super.key,
    required this.nextRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = Translations.of(context).onboarding.notifications;

    return OnboardingBackground(
      child: OnboardingTextStepScaffold(
        step: 6,
        hero: const OnboardingNotificationToastShowcase(),
        heroAreaFraction: 0.66,
        heroTextSpacing: KasySpacing.md,
        title: translations.title,
        description: translations.description,
        primaryLabel: translations.continue_button,
        onPrimary: () async {
          try {
            await ref.onboardingNotifier.setupNotifications();
          } finally {
            if (context.mounted) {
              Navigator.of(context).pushNamed(nextRoute);
            }
          }
        },
        secondaryLabel: translations.skip_button,
        onSecondary: () {
          ref
              .read(analyticsApiProvider)
              .logEvent('setup_notifications_refused', {});
          Navigator.of(context).pushNamed(nextRoute);
        },
      ),
    );
  }
}
