import 'package:cowboydodartinc/features/notifications/api/device_api.dart';
import 'package:cowboydodartinc/features/notifications/api/entities/device_entity.dart';

class FakeDeviceApi implements DeviceApi {
  OnTokenRefresh? refreshTokenCallback;

  @override
  Future<DeviceEntity> register(String userId, DeviceEntity device) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Future.value(device.copyWith(id: 'fake_id'));
  }

  @override
  Future<void> unregister(String userId, String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> touch(String userId, String installationId) async {}

  @override
  Future<void> cleanupStaleDevices(
    String userId,
    String currentInstallationId,
  ) async {}

  @override
  Future<DeviceEntity> get() {
    return Future.value(
      DeviceEntity(
        installationId: 'fake_installation_id',
        token: 'fake_token',
        operatingSystem: OperatingSystem.android,
        creationDate: DateTime.now(),
        lastUpdateDate: DateTime.now(),
      ),
    );
  }

  @override
  void onTokenRefresh(OnTokenRefresh onTokenRefresh) {
    refreshTokenCallback = onTokenRefresh;
  }

  @override
  Future<DeviceEntity> update(String userId, DeviceEntity device) {
    return Future.value(device.copyWith(lastUpdateDate: DateTime.now()));
  }

  @override
  void removeOnTokenRefreshListener() {
    refreshTokenCallback = null;
  }

  
  @override
  Future<void> clear(String userId) {
    return Future.value();
  }
  
  @override
  Future<Map<String, String>> fetchDeviceProperties() {
    return Future.value({
      'appLongVersion': '1.0.0',
      'osVersion': '1.0.0',
      'deviceModel': '1.0.0',
      'deviceLocale': '1.0.0',
      'timezone': '1.0.0',
      'carrier': '1.0.0',
      'screenWidth': '1.0.0',
      'screenHeight': '1.0.0',
    });
  }
  
}
