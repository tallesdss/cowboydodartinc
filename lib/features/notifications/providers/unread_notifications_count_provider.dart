import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/features/notifications/repositories/notifications_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live count of the signed-in user's unread notifications. Emits 0 when there
/// is no user. Shared source for badging the notifications item everywhere it
/// appears in the navigation (bottom bar, sidebar).
///
/// Watches the user id, so it automatically re-subscribes to the right stream
/// when the account changes (avoids leaking the previous user's count).
final unreadNotificationsCountProvider = StreamProvider.autoDispose<int>((ref) {
  final String? userId = ref.watch(userStateNotifierProvider).user.idOrNull;
  if (userId == null) return Stream<int>.value(0);
  return ref
      .read(notificationRepositoryProvider)
      .listenToUnreadNotificationsCount(userId);
});
