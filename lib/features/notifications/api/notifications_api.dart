import 'package:cowboydodartinc/core/data/api/base_api_exceptions.dart';
import 'package:cowboydodartinc/features/notifications/api/entities/notifications_entity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final notificationsApiProvider = Provider<NotificationsApi>(
  (ref) => FirebaseNotificationsApi(
    messaging: FirebaseMessaging.instance,
    logger: Logger(),
    client: Supabase.instance.client,
  ),
);

/// This class is responsible for listening from firebase notifications
/// As I like repositories to not depend on external libraries
/// I wrapped some of the firebase messaging methods
///
/// You could use directly the firebase messaging methods but making a fake implementation
/// of this class would be harder.
abstract class NotificationsApi {
  /// Request permission to receive notifications
  Future<void> requestPermission();

  // Used to listen to notifications when the app is in foreground
  void setForegroundHandler(OnRemoteMessage handler);

  // Used to listen to notifications when the app is in background
  void setBackgroundHandler(OnRemoteMessage handler);

  // Used to listen to notifications when user clicks on the notification
  void setOnOpenNotificationHandler(OnRemoteMessage handler);

  // Used to get the initial message from the app 
  // (notification opened when the app is not ready)
  Future<RemoteMessage?> getInitialMessage();

  // Used to get the past notifications from the server
  Future<List<NotificationEntity>> get(
    String userId, {
    DateTime? startDate,
    required int limit,
    int page = 0,
  });

  // Used to mark a notification as read
  Future<void> read(String userId, String notificationId);

  // Used to delete a single notification (per-user only)
  Future<void> delete(String userId, String notificationId);

  // Used to get the unread notifications count
  Stream<int> unreadNotifications(String userId);

  // Used to register to a topic
  void registerTopic(String topic);

  // Used to unregister from a topic
  void unregisterTopic(String topic);

  // Used to get the permission status
  Future<PermissionStatus> getPermissionStatus();

  // Admin: find a user's ID by their email address
  Future<String?> findUserByEmail(String email);

  // Admin: create a notification for a specific user (triggers push via webhook)
  Future<void> sendNotification(
    String userId, {
    required String title,
    required String body,
    String? imageUrl,
    String? route,
  });

  // Admin: send a notification to a list of emails
  Future<void> sendNotificationToEmails(
    List<String> emails, {
    required String title,
    required String body,
    String? imageUrl,
    String? route,
  });

  // Admin: create a notification for every registered user
  Future<void> sendNotificationToAll({
    required String title,
    required String body,
    String? imageUrl,
    String? route,
  });
}

typedef OnRemoteMessage = Future<void> Function(RemoteMessage message);

class FirebaseNotificationsApi implements NotificationsApi {
  final FirebaseMessaging _messaging;
  final SupabaseClient _client;
  final Logger _logger;

  FirebaseNotificationsApi({
    required FirebaseMessaging messaging,
    required SupabaseClient client,
    required Logger logger,
  })  : _messaging = messaging,
        _client = client,
        _logger = logger;

  @override
  Future<void> requestPermission() async {
    try {
      await _messaging.requestPermission();
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  void setForegroundHandler(OnRemoteMessage handler) {
    FirebaseMessaging.onMessage.listen(handler);
  }

  @override
  void setBackgroundHandler(OnRemoteMessage handler) {
    FirebaseMessaging.onBackgroundMessage(handler);
  }

  @override
  void setOnOpenNotificationHandler(OnRemoteMessage handler) {
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }

  @override
  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  @override
  void registerTopic(String topic) {
    _messaging.subscribeToTopic(topic);
  }

  @override
  void unregisterTopic(String topic) {
    _messaging.unsubscribeFromTopic(topic);
  }

  // Used to get the past notifications from the server
  @override
  Future<List<NotificationEntity>> get(
    String userId, {
    DateTime? startDate,
    required int limit,
    int page = 0,
  }) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('creation_date', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);
      if (response.isEmpty) {
        return [];
      }
      return response
          .map((e) {
            try {
              return NotificationEntity.fromJson(e);
            } catch (e) {
              return null;
            }
          })
          .whereType<NotificationEntity>()
          .toList();
    } catch (e, stacktrace) {
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }

  @override
  Future<void> read(String userId, String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'read_date': DateTime.now().toString()})
          .eq('user_id', userId)
          .eq('id', notificationId);
    } catch (e, stacktrace) {
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }

  @override
  Future<void> delete(String userId, String notificationId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('user_id', userId)
          .eq('id', notificationId);
    } catch (e, stacktrace) {
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }

  @override
  Stream<int> unreadNotifications(String userId) {
    try {
      return _client
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('creation_date')
          .limit(10)
          .map((el) => el.where((item) => item['read_date'] == null))
          .map((event) => event.length);
    } catch (e, stacktrace) {
      debugPrint('$e: $stacktrace');
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }

  @override
  Future<PermissionStatus> getPermissionStatus() {
    return Permission.notification.status;
  }

  @override
  Future<String?> findUserByEmail(String email) async {
    try {
      final result = await _client
          .from('users')
          .select('id')
          .eq('email', email)
          .limit(1);
      if (result.isEmpty) return null;
      return result.first['id'] as String?;
    } catch (e, s) {
      _logger.e('findUserByEmail error: $e: $s');
      return null;
    }
  }

  @override
  Future<void> sendNotification(
    String userId, {
    required String title,
    required String body,
    String? imageUrl,
    String? route,
  }) async {
    await _client.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      if (route != null && route.isNotEmpty) 'data': {'route': route},
      'type': 'OTHER',
    });
  }

  @override
  Future<void> sendNotificationToEmails(
    List<String> emails, {
    required String title,
    required String body,
    String? imageUrl,
    String? route,
  }) async {
    final notFound = <String>[];
    for (final email in emails) {
      final userId = await findUserByEmail(email.trim());
      if (userId == null) {
        notFound.add(email.trim());
      } else {
        await sendNotification(userId, title: title, body: body, imageUrl: imageUrl, route: route);
      }
    }
    if (notFound.isNotEmpty) throw UsersNotFoundError(notFound.join(', '));
  }

  @override
  Future<void> sendNotificationToAll({
    required String title,
    required String body,
    String? imageUrl,
    String? route,
  }) async {
    // Paginate in chunks of 1000 (PostgREST default page size) to avoid
    // silently dropping users when the devices table exceeds 1000 rows.
    const int pageSize = 1000;
    int offset = 0;
    final Set<String> userIds = {};
    while (true) {
      final page = await _client
          .from('devices')
          .select('user_id')
          .order('user_id')
          .range(offset, offset + pageSize - 1);
      for (final r in page) {
        userIds.add(r['user_id'] as String);
      }
      if (page.length < pageSize) break;
      offset += pageSize;
    }
    await Future.wait(
      userIds.map(
        (id) => sendNotification(id, title: title, body: body, imageUrl: imageUrl, route: route),
      ),
    );
  }
}

class UsersNotFoundError implements Exception {
  final String emails;
  const UsersNotFoundError(this.emails);

  @override
  String toString() => emails;
}
