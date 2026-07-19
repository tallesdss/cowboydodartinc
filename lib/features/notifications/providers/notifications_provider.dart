import 'dart:async';

import 'package:cowboydodartinc/core/bottom_menu/bart_inner_navigation.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/notification.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/notification_list.dart';
import 'package:cowboydodartinc/features/notifications/providers/unread_notifications_count_provider.dart';
import 'package:cowboydodartinc/features/notifications/repositories/notifications_repository.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_provider.g.dart';

const itemPerPage = 10;

@Riverpod(keepAlive: true)
class NotificationsNotifier extends _$NotificationsNotifier {
  var _locked = false;

  @override
  FutureOr<NotificationsList> build() async {
    final notificationRepository = ref.read(notificationRepositoryProvider);
    final userId = ref.watch(userStateNotifierProvider).user.idOrNull;
    if (userId == null) return NotificationsList.from([], itemPerPage);
    await Future.delayed(const Duration(milliseconds: 500));
    final res = await notificationRepository.get(
      userId,
      pageSize: itemPerPage,
    );

    // Subscribe to realtime updates: when new notifications arrive, refresh the list.
    // Skip the first emission (initial snapshot) to avoid an immediate rebuild loop.
    bool firstEmission = true;
    final sub = notificationRepository
        .listenToUnreadNotificationsCount(userId)
        .listen((count) {
      if (firstEmission) {
        firstEmission = false;
        return;
      }
      if (!_locked && state.hasValue) {
        ref.invalidateSelf();
      }
    });
    ref.onDispose(() => sub.cancel());

    return NotificationsList.from(res, itemPerPage);
  }

  Future<void> readAll() async {
    if (!state.hasValue) return;
    try {
      final notificationRepository = ref.read(notificationRepositoryProvider);
      final userId = ref.read(userStateNotifierProvider).user.idOrNull;
      if (userId == null) return;
      final unread = state.value!.data.where((n) => !n.seen).toList();
      if (unread.isEmpty) return;
      final updatedNotifications = await Future.wait(
        unread.map((n) => notificationRepository.read(userId, n)),
      );
      final seenNotifications = state.value!.data.where((n) => n.seen).toList();
      state = AsyncValue.data(
        state.value!.copyWith(
          data: [...updatedNotifications, ...seenNotifications],
        ),
      );
      // The bottom-bar unread badge reads from a separate, polled source. Nudge
      // it to re-check now so it drops as soon as we mark these read, instead of
      // lagging until the next poll cycle.
      ref.invalidate(unreadNotificationsCountProvider);
    } catch (e) {
      Logger().e("error $e");
    }
  }

  /// Delete a single notification. Optimistically removes from state, then
  /// persists the deletion on the server. Reverts on failure.
  Future<void> delete(Notification notification) async {
    if (!state.hasValue) return;
    final notificationRepository = ref.read(notificationRepositoryProvider);
    final userId = ref.read(userStateNotifierProvider).user.idOrNull;
    if (userId == null) return;
    final previous = state.value!;
    state = AsyncValue.data(
      previous.copyWith(
        data: previous.data.where((n) => n.id != notification.id).toList(),
      ),
    );
    try {
      await notificationRepository.delete(userId, notification);
      // Deleting an unread notification changes the unread count: refresh the
      // badge source now rather than waiting for its next poll.
      ref.invalidate(unreadNotificationsCountProvider);
    } catch (e) {
      Logger().e("delete error $e");
      state = AsyncValue.data(previous);
    }
  }

  /// Delete every notification currently loaded. Optimistically clears state,
  /// then persists deletions on the server. Reverts on failure.
  Future<void> deleteAll() async {
    if (!state.hasValue) return;
    final notificationRepository = ref.read(notificationRepositoryProvider);
    final userId = ref.read(userStateNotifierProvider).user.idOrNull;
    if (userId == null) return;
    final previous = state.value!;
    if (previous.data.isEmpty) return;
    state = AsyncValue.data(previous.copyWith(data: const []));
    try {
      await Future.wait(
        previous.data.map((n) => notificationRepository.delete(userId, n)),
      );
      // Clearing the list zeroes the unread count: refresh the badge now.
      ref.invalidate(unreadNotificationsCountProvider);
    } catch (e) {
      Logger().e("deleteAll error $e");
      state = AsyncValue.data(previous);
    }
  }

  Future<void> refresh() async {
    if (_locked) return;
    _locked = true;
    state = const AsyncValue.loading();
    try {
      final notificationRepository = ref.read(notificationRepositoryProvider);
      final userId = ref.read(userStateNotifierProvider).user.idOrNull;
      if (userId == null) return;
      await Future.delayed(const Duration(milliseconds: 1500));
      final res = await notificationRepository.get(userId, pageSize: itemPerPage);
      state = AsyncValue.data(NotificationsList.from(res, itemPerPage));
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    } finally {
      _locked = false;
    }
  }

  Future<void> fetchNextPage() async {
    if (_locked) return;
    if (state.value == null || state.value!.hasMore == false) return;
    _locked = true;
    try {
      final notificationRepository = ref.read(notificationRepositoryProvider);
      final userId = ref.read(userStateNotifierProvider).user.idOrNull;
      if (userId == null) return;
      if (state.value!.data.isEmpty) return;
      await Future.delayed(const Duration(milliseconds: 500));
      final nextPage = await notificationRepository.get(
        userId,
        pageSize: itemPerPage,
        startDate: state.value!.data.last.createdAt,
      );
      state = AsyncValue.data(
        state.value!.copyWith(
          data: [...state.value!.data, ...nextPage],
          hasMore: nextPage.length == itemPerPage,
        ),
      );
    } catch (e) {
      Logger().e("fetchNextPage error $e");
    } finally {
      _locked = false;
    }
  }

  /// Handle notification tap from the in-app notifications list.
  void onTapNotification(Notification notification) {
    setSettingsInnerReturnPath(kNotificationsShellReturnPath);
    notification.onTap();
  }
}
