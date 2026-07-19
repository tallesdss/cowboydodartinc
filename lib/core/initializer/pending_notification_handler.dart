import 'package:cowboydodartinc/features/notifications/api/local_notifier.dart';
import 'package:cowboydodartinc/features/notifications/api/notifications_api.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pendingNotificationHandlerProvider = Provider<PendingNotificationHandler>(
  (ref) => PendingNotificationHandler(
    notificationsApi: ref.watch(notificationsApiProvider),
  ),
);

/// This class is responsible for handling the pending notification
/// and when the app is ready, we process the notification
/// Firebase automatically stores the initial message and remove it after getting it
class PendingNotificationHandler {

  final NotificationsApi _notificationsApi;

  PendingNotificationHandler({
    required NotificationsApi notificationsApi,
  }) : _notificationsApi = notificationsApi;

  Future<Notification?> fetchNotificationToProcess() async {
    final message = await _notificationsApi.getInitialMessage();
    if (message == null) {
      return null;
    }
    if (message.notification == null) {
      return null;
    }
    // Only process if the notification was sent recently (within 30 seconds).
    // This prevents re-navigation on hot restart during development, where the
    // native Firebase layer keeps the last message even after a Dart restart.
    final sentTime = message.sentTime;
    if (sentTime != null && DateTime.now().difference(sentTime).inSeconds > 30) {
      return null;
    }
    final notification = Notification.from(
      message.notification!.toMap(),
      data: message.data,
      notifierApi: LocalNotifier(notificationManager: FlutterLocalNotificationsPlugin()),
      notifierSettings: defaultNotificationSettings,
    );
    return notification;
  }

}
