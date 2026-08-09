import 'dart:async';
import 'dart:convert';
import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:cowboydodartinc/features/notifications/api/entities/notifications_entity.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/notification.dart';
import 'package:cowboydodartinc/features/notifications/repositories/notifications_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final mockNotificationRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => MockNotificationsRepository(ref.watch(sharedPreferencesProvider)),
);

class MockNotificationsRepository implements NotificationsRepository {
  final SharedPreferencesBuilder _prefsBuilder;
  final StreamController<int> _unreadCountController = StreamController<int>.broadcast();
  static const String _keyNotifications = 'mock_notifications';

  MockNotificationsRepository(this._prefsBuilder);

  @override
  Future<void> init() async {
    // Initialized by main provider already.
  }

  @override
  Future<List<Notification>> get(
    String userId, {
    int pageSize = 20,
    DateTime? startDate,
    int page = 0,
  }) async {
    final list = _getAll();
    final userList = list.where((n) => n.data != null && n.data!['userId'] == userId).toList();
    // Sort by descending createdAt
    userList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return userList;
  }

  @override
  Future<Notification> read(String userId, Notification notification) async {
    final list = _getAll();
    final index = list.indexWhere((n) => n.id == notification.id);
    if (index >= 0) {
      final updated = list[index].copyWith(readAt: DateTime.now());
      list[index] = updated;
      await _saveAll(list);
      _emitUnreadCount(userId);
      return updated;
    }
    return notification;
  }

  @override
  Future<void> delete(String userId, Notification notification) async {
    final list = _getAll();
    list.removeWhere((n) => n.id == notification.id);
    await _saveAll(list);
    _emitUnreadCount(userId);
  }

  @override
  Stream<int> listenToUnreadNotificationsCount(String userId) {
    // Emit initial value on listen
    Future.microtask(() => _emitUnreadCount(userId));
    return _unreadCountController.stream;
  }

  @override
  Future<NotificationPermission> getPermissionStatus() {
    throw UnimplementedError('Mock does not use permission status');
  }

  // --- Mock specific methods ---

  Future<void> createNotification(String userId, Notification notification) async {
    final list = _getAll();
    // Ensure we tag the notification with the userId so we can filter later.
    final updatedData = Map<String, dynamic>.from(notification.data ?? {});
    updatedData['userId'] = userId;
    final newNotif = notification.copyWith(
      data: updatedData, 
      id: notification.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    );
    list.add(newNotif);
    await _saveAll(list);
    _emitUnreadCount(userId);
  }

  List<Notification> _getAll() {
    final prefs = _prefsBuilder.prefs;
    final jsonList = prefs.getStringList(_keyNotifications) ?? [];
    return jsonList.map((jsonStr) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return Notification.withData(
          id: map['id'] as String?,
          title: map['title'] as String,
          body: map['body'] as String,
          createdAt: DateTime.parse(map['createdAt'] as String),
          readAt: map['readAt'] != null ? DateTime.parse(map['readAt'] as String) : null,
          imageUrl: map['imageUrl'] as String?,
          type: map['type'] != null ? NotificationTypes.values.firstWhere(
            (e) => e.name == map['type'],
            orElse: () => NotificationTypes.OTHER,
          ) : null,
          data: map['data'] as Map<String, dynamic>?,
        );
      } catch (e) {
        Logger().e("Failed to parse mock notification: $e");
        return null;
      }
    }).whereType<Notification>().toList();
  }

  Future<void> _saveAll(List<Notification> list) async {
    final jsonList = list.map((n) {
      return jsonEncode({
        'id': n.id,
        'title': n.title,
        'body': n.body,
        'createdAt': n.createdAt.toIso8601String(),
        'readAt': n.readAt?.toIso8601String(),
        'imageUrl': n.imageUrl,
        'type': n.type?.name,
        'data': n.data,
      });
    }).toList();
    await _prefsBuilder.prefs.setStringList(_keyNotifications, jsonList);
  }

  void _emitUnreadCount(String userId) {
    final list = _getAll();
    final userList = list.where((n) => n.data != null && n.data!['userId'] == userId).toList();
    final unread = userList.where((n) => n.readAt == null).length;
    _unreadCountController.add(unread);
  }
}
