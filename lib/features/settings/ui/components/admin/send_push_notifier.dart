import 'package:cowboydodartinc/features/notifications/api/notifications_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'send_push_notifier.g.dart';

@riverpod
class SendPushNotifier extends _$SendPushNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> send({
    required String title,
    required String body,
    String? imageUrl,
    String? route,
    List<String> emails = const [],
    bool sendToAll = false,
  }) async {
    state = const AsyncLoading();
    final api = ref.read(notificationsApiProvider);
    try {
      if (sendToAll) {
        await api.sendNotificationToAll(title: title, body: body, imageUrl: imageUrl, route: route);
      } else {
        await api.sendNotificationToEmails(
          emails,
          title: title,
          body: body,
          imageUrl: imageUrl,
          route: route,
        );
      }
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void reset() => state = const AsyncData(null);
}
