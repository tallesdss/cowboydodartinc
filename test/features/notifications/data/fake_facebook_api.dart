import 'package:cowboydodartinc/core/data/api/tracking_api.dart';
import 'package:cowboydodartinc/core/states/models/user_state.dart';
import 'package:cowboydodartinc/features/notifications/repositories/device_repository.dart';

class FakeFacebookEventApi implements FacebookEventApi {
  @override
  DeviceRepository get deviceRepository => throw UnimplementedError();

  @override
  Future<void> init() {
    return Future.value();
  }

  @override
  Future<void> initUser(String userId) {
    return Future.value();
  }

  @override
  Future<void> logMetaStartTrial(
    String orderId,
    double price,
    String currency,
  ) {
    return Future.value();
  }

  @override
  Future<void> logMetaSubscribe(String orderId, double price, String currency) {
    return Future.value();
  }

  @override
  Future<void> requestIDFA() {
    return Future.value();
  }

  @override
  UserState get userState => throw UnimplementedError();
}
