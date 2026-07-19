import 'package:cowboydodartinc/core/initializer/onstart_service.dart';
import 'package:cowboydodartinc/core/states/models/user_state.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/features/notifications/repositories/device_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// No-op tracking. Run: kasy add facebook to activate Facebook Events.
final facebookEventApiProvider = Provider(
  (ref) => FacebookEventApi(
    deviceRepository: ref.watch(deviceRepositoryProvider),
    userState: ref.watch(userStateNotifierProvider),
  ),
);

class FacebookEventApi implements OnStartService {
  final DeviceRepository deviceRepository;
  final UserState userState;
  FacebookEventApi({required this.deviceRepository, required this.userState});
  @override Future<void> init() async {}
  Future<void> initUser(String userId) async {}
  Future<void> requestIDFA() async {}
  Future<void> logMetaStartTrial(String orderId, double price, String currency) async {}
  Future<void> logMetaSubscribe(String orderId, double price, String currency) async {}
}
