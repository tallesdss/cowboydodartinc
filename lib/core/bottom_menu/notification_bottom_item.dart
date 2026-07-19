import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/notifications/providers/unread_notifications_count_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom-bar notifications icon with an unread-count badge.
///
/// The badge is purely an unread indicator (works on web too) — it is not tied
/// to push notifications, which are native-only. The count comes from the shared
/// [unreadNotificationsCountProvider], which re-subscribes per signed-in user.
class BottomItemNotification extends ConsumerWidget {
  const BottomItemNotification({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const icon = Icon(KasyIcons.notification);
    final int count =
        ref.watch(unreadNotificationsCountProvider).value ?? 0;
    if (count == 0) return icon;
    return Badge(
      backgroundColor: context.colors.error,
      textColor: context.colors.onError,
      label: Text(count > 99 ? '99+' : '$count'),
      child: icon,
    );
  }
}
