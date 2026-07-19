import 'package:cowboydodartinc/core/icons/kasy_icons.dart';
import 'package:cowboydodartinc/features/notifications/api/local_notifier.dart';
import 'package:cowboydodartinc/features/notifications/ui/widgets/permission_request_view.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef FutureCallback = Future<void> Function();

/// Asks the user to opt in BEFORE showing the real OS notification dialog.
/// On iOS the OS prompt can only be shown once, so this soft pre‑prompt protects
/// that single shot: if the user accepts here, we trigger the system dialog.
///
/// It is just a thin wrapper over [PermissionRequestView] (the reusable
/// skeleton) wired to the notification permission. To build the same screen for
/// location, camera, contacts, … copy this file, swap the icon/copy and call the
/// matching permission API inside `onAccept`.
class RequestNotificationPermission extends ConsumerWidget {
  final FutureCallback? onAccept;
  final FutureCallback? onRefuse;

  const RequestNotificationPermission({
    super.key,
    this.onAccept,
    this.onRefuse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = Translations.of(context).request_notification_permission;
    return PermissionRequestView(
      icon: KasyIcons.notification,
      title: translations.title,
      description: translations.description,
      acceptLabel: translations.continue_button,
      skipLabel: translations.skip_button,
      onAccept: () {
        ref.read(notificationsSettingsProvider).askPermission().then(
          (accepted) => switch (accepted) {
            true => onAccept?.call(),
            false => onRefuse?.call(),
          },
        );
      },
      onSkip: () => onRefuse?.call(),
    );
  }
}
