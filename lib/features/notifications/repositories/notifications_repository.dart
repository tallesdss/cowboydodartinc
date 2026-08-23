import 'package:cowboydodartinc/core/data/api/tracking_api.dart';
import 'package:cowboydodartinc/core/initializer/onstart_service.dart';
import 'package:cowboydodartinc/core/states/notifications_dispatcher.dart';
import 'package:cowboydodartinc/features/notifications/api/local_notifier.dart';
import 'package:cowboydodartinc/features/notifications/api/notifications_api.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/notification.dart';
import 'package:cowboydodartinc/features/notifications/repositories/background_notification_handler.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:cowboydodartinc/router.dart';
import 'package:firebase_messaging/firebase_messaging.dart' show RemoteMessage;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class NotificationsRepository implements OnStartService {
  // this method is used to get the notifications from the server
  Future<List<Notification>> get(
    String userId, {
    int pageSize = 20,
    DateTime? startDate,
    int page = 0,
  });

  // mark a notification as read
  Future<Notification> read(String userId, Notification notification);

  // delete a single notification (per-user only)
  Future<void> delete(String userId, Notification notification);

  // listen to the unread notifications count
  Stream<int> listenToUnreadNotificationsCount(String userId);

  // return the permission status
  Future<NotificationPermission> getPermissionStatus();
}

final notificationRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return AppNotificationsRepository(
    notificationsApi: ref.watch(notificationsApiProvider),
    notificationPublisher: ref.watch(notificationPublisherProvider),
    localNotifier: ref.watch(localNotifierProvider),
    notificationSettings: ref.watch(notificationsSettingsProvider),
    facebookEventApi: ref.watch(facebookEventApiProvider),
  );
});

class AppNotificationsRepository implements NotificationsRepository {
  final NotificationsApi _notificationsApi;
  final NotificationPublisher _notificationPublisher;
  final LocalNotifier _localNotifier;
  final NotificationSettings _notificationSettings;
  final FacebookEventApi _facebookEventApi;

  AppNotificationsRepository({
    required NotificationsApi notificationsApi,
    required NotificationPublisher notificationPublisher,
    required LocalNotifier localNotifier,
    required NotificationSettings notificationSettings,
    required FacebookEventApi facebookEventApi,
  })  : _notificationsApi = notificationsApi,
        _localNotifier = localNotifier,
        _notificationSettings = notificationSettings,
        _facebookEventApi = facebookEventApi,
        _notificationPublisher = notificationPublisher;

  @override
  Future<void> init() async {
    final permission = await getPermissionStatus();
    if (permission is NotificationPermissionGranted) {
      await _notificationSettings.init();

      _notificationsApi.setForegroundHandler(_onMessage);
      _notificationsApi.setBackgroundHandler(onBackgroundMessage);
      _notificationsApi.setOnOpenNotificationHandler(_onOpenMessage);

      // Subscribe to topics doesn't work on web
      if (kIsWeb) {
        return;
      }
      /// If you want to subscribe to a specific topic
      _notificationsApi.registerTopic('general');

      /// If you want to subscribe to a specific topic based on the user language
      final locale = LocaleSettings.instance.currentLocale.languageCode;
      final langChannel = "general-$locale";
      _notificationsApi.registerTopic(langChannel);

      /// we register a test topic in debug mode
      if (kDebugMode) {
        debugPrint('Registering to test topic');
        _notificationsApi.registerTopic('test');
      }
    }
    
  }

  Future<void> _onMessage(RemoteMessage message) async {
    if (message.notification == null) {
      
      Logger().i('[NOTIFICATIONS REPOSITORY] 🔥 -> Notification push only with data');
      switch (message.data['type']) {
        case 'SUBSCRIPTION_TRIAL' when message.data.containsKey('price') && message.data.containsKey('currency') && message.data.containsKey('subscription_id'):
          _facebookEventApi.logMetaStartTrial(
            message.data['subscription_id'] as String, 
            double.tryParse(message.data['price'] as String) ?? 0.0, 
            message.data['currency'] as String,
          );
        case 'SUBSCRIPTION_PURCHASE' when message.data.containsKey('price') && message.data.containsKey('currency') && message.data.containsKey('subscription_id'):
          _facebookEventApi.logMetaSubscribe(
            message.data['subscription_id'] as String,
            double.tryParse(message.data['price'] as String) ?? 0.0, 
            message.data['currency'] as String,
          );
        default:
          break;
      }
      
      return;
    }
    final notification = Notification.from(
      message.notification!.toMap(),
      data: message.data,
      notifierApi: _localNotifier,
      notifierSettings: _notificationSettings,
    );
    _notificationPublisher.publish(notification);
  }

  Future<void> _onOpenMessage(RemoteMessage message) async {
    if (message.notification == null) {
      return;
    }
    if (navigatorKey.currentContext == null) {
      return;
    }
    final notification = Notification.from(
      message.notification!.toMap(),
      data: message.data,
      notifierApi: _localNotifier,
      notifierSettings: _notificationSettings,
    );
    await notification.onTap();
  }

  @override
  Future<NotificationPermission> getPermissionStatus() async {
    final systemStatus = await _notificationsApi.getPermissionStatus();
    switch (systemStatus) {
      case PermissionStatus.granted:
        return NotificationPermissionGranted(
          notificationSettings: _notificationSettings,
          repository: this,
        );
      case PermissionStatus.denied:
        return NotificationPermissionDenied(
          notificationSettings: _notificationSettings,
          repository: this,
        );
      case PermissionStatus.permanentlyDenied:
        return NotificationPermissionPermanentlyDenied();
      default:
        return NotificationPermissionWaiting(
          notificationSettings: _notificationSettings,
          repository: this,
        );
    }
  }

  @override
  Future<List<Notification>> get(
    String userId, {
    int pageSize = 20,
    DateTime? startDate,
    int page = 0,
  }) async {
    final notificationEntities = await _notificationsApi.get(
      userId,
      limit: pageSize,
      startDate: startDate,
    );
    final notifications = notificationEntities
        .map(
          (e) => Notification.withData(
            id: e.id,
            title: e.title,
            body: e.body,
            createdAt: e.creationDate,
            readAt: e.readDate,
            imageUrl: e.imageUrl,
            type: e.type,
            data: e.data,
            notifier: _localNotifier,
            notifierSettings: _notificationSettings,
          ),
        )
        .toList();
    return notifications;
  }

  @override
  Future<Notification> read(String userId, Notification notification) async {
    if (notification.id == null) {
      throw Exception('A notification without id cannot be read');
    }
    await _notificationsApi.read(userId, notification.id!);
    return notification.copyWith(readAt: DateTime.now());
  }

  @override
  Future<void> delete(String userId, Notification notification) async {
    if (notification.id == null) {
      throw Exception('A notification without id cannot be deleted');
    }
    await _notificationsApi.delete(userId, notification.id!);
  }

  @override
  Stream<int> listenToUnreadNotificationsCount(String userId) {
    return _notificationsApi.unreadNotifications(userId);
  }
}
