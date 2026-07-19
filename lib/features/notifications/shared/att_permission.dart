import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/data/api/tracking_api.dart';
import 'package:cowboydodartinc/core/icons/kasy_icons.dart';
import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:cowboydodartinc/core/states/components/maybeshow_component.dart';
import 'package:cowboydodartinc/core/states/models/event_model.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/features/subscriptions/repositories/subscription_repository.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Requests App Tracking Transparency (ATT) on iOS if not yet determined.
///
/// Apple only allows the native ATT prompt to be shown once per install, so we
/// gate the system call behind a soft explanation dialog (KasyDialog) first.
/// If the user dismisses the soft dialog, we back off and ask again later (up
/// to [_maxSoftAttempts] times, with [_cooldown] between attempts). After the
/// last attempt we stop asking forever.
///
/// To remove: delete this file and remove [MaybeShowAttPermission] from
/// [HomePage]'s event list.
class MaybeShowAttPermission implements MaybeShowWithRef {
  static const Duration _settleDelay = Duration(milliseconds: 1500);
  static const int _maxSoftAttempts = 3;
  static const Duration _cooldown = Duration(days: 7);

  @override
  Future<bool> handle(WidgetRef ref, AppEvent event) async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    if (event is! OnAppStartEvent) return false;

    final status = await Permission.appTrackingTransparency.status;
    // `denied` in permission_handler maps to iOS "notDetermined" — never asked.
    if (!status.isDenied) return false;

    final prefs = ref.read(sharedPreferencesProvider);
    final attempts = prefs.getAttSoftDismissCount();
    if (attempts >= _maxSoftAttempts) return false;

    final lastAsked = prefs.getAttSoftLastAskedAt();
    if (lastAsked != null &&
        DateTime.now().difference(lastAsked) < _cooldown) {
      return false;
    }

    await Future<void>.delayed(_settleDelay);
    await prefs.setAttSoftLastAskedAt(DateTime.now());
    if (!ref.context.mounted) return false;

    final confirmed = await _showExplanationDialog(ref.context);
    if (!confirmed) {
      await prefs.setAttSoftDismissCount(attempts + 1);
      return false;
    }

    await Permission.appTrackingTransparency.request();
    await prefs.setAttSoftDismissCount(_maxSoftAttempts);

    final userId = ref.read(userStateNotifierProvider).user.idOrNull;
    if (userId != null) {
      ref.read(subscriptionRepositoryProvider).initUser(userId).ignore();
      ref.read(facebookEventApiProvider).initUser(userId).ignore();
    }

    return true;
  }

  Future<bool> _showExplanationDialog(BuildContext context) async {
    final confirmed = await showKasyBlurDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final t = Translations.of(dialogContext).onboarding.att;
        return KasyDialog(
          leadingIcon: KasyIcons.privacy,
          iconTone: KasyDialogIconTone.info,
          title: t.title,
          message: t.description,
          showCloseButton: false,
          actions: [
            KasyButton(
              label: t.continue_button,
              expand: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }
}
