import 'dart:convert';

import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:cowboydodartinc/features/notifications/api/device_api.dart';
import 'package:cowboydodartinc/features/notifications/api/entities/device_entity.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/device.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) {
    final prefsLoader = ref.watch(sharedPreferencesProvider);
    return DeviceRepository(
      prefs: prefsLoader.prefs,
      deviceApi: ref.watch(deviceApiProvider),
    );
  },
);

const _devicePrefsKey = 'device';
const _deviceUserIdPrefsKey = 'device_user_id';

typedef OnTokenRefreshCallback = void Function(Device device);

/// This repository is responsible for the device registration
/// You need to register the device in your backend to be able to send notifications
/// You can also unregister the device
/// The device is also stored in the shared preferences to prevent spamming the backend
/// The token is updated when the token is refreshed
/// Optionnaly you can also add the user id to the methods
class DeviceRepository {
  final DeviceApi _deviceApi;
  final SharedPreferences _prefs;

  DeviceRepository({
    required DeviceApi deviceApi,
    required SharedPreferences prefs,
  })  : _deviceApi = deviceApi,
        _prefs = prefs;

  Future<Device?> get() async {
    final deviceEntity = await _getFromPrefs();
    if (deviceEntity == null) {
      return null;
    }
    return Device.fromEntity(deviceEntity);
  }

  Future<void> register(String userId) async {
    final device = await _getFromPrefs();
    final newDevice = await _deviceApi.get();
    final cachedUserId = _prefs.getString(_deviceUserIdPrefsKey);
    // Only skip re-registration if BOTH the token AND the user haven't changed.
    // Without the userId check, a new anonymous user (same device token) would
    // reuse the cached prefs and never register in the database.
    if (device != null && device.token == newDevice.token && cachedUserId == userId) {
      // Heartbeat — keeps the backend's stale-device filter (60d TTL) from
      // dropping this active install. Cheap: one Firestore update per launch.
      await _deviceApi.touch(userId, newDevice.installationId);
      return;
    }
    // Include device properties so the welcome notification fires in the correct locale.
    final extraData = await _deviceApi.fetchDeviceProperties();
    final deviceWithLocale = newDevice.copyWith(extraData: extraData);
    final response = await _deviceApi.register(userId, deviceWithLocale);
    await _saveInPrefs(response);
    await _prefs.setString(_deviceUserIdPrefsKey, userId);
    // Remove orphan devices left by previous installs on the same physical
    // device (different installationId, never touched again). Without this,
    // a re-install (Xcode -> TestFlight, or TestFlight build update with an
    // uninstall in between) leaves stale tokens that still receive push,
    // causing duplicated notifications.
    await _deviceApi.cleanupStaleDevices(userId, newDevice.installationId);
  }

  Future<void> unregister(String userId) async {
    final device = await _getFromPrefs();
    if (device == null) {
      return;
    }
    await _deviceApi.unregister(userId, device.installationId);
    await _removeFromPrefs();
    await _prefs.remove(_deviceUserIdPrefsKey);
  }

  void onTokenUpdate(OnTokenRefreshCallback onTokenRefresh) {
    _deviceApi.onTokenRefresh((token) async {
      final device = await _getFromPrefs();
      if (device == null) {
        return;
      }
      final updatedDevice = device.copyWith(token: token);
      onTokenRefresh(Device.fromEntity(updatedDevice));
    });
  }

  void removeTokenUpdateListener() {
    _deviceApi.removeOnTokenRefreshListener();
  }

  Future<void> updateToken(String token) async {
    final device = await _getFromPrefs();
    if (device == null) return;
    final userId = _prefs.getString(_deviceUserIdPrefsKey);
    if (userId == null) return;
    final updatedDevice = device.copyWith(token: token);
    await _deviceApi.update(userId, updatedDevice);
    await _saveInPrefs(updatedDevice);
  }

  Future<void> refreshExtraData() async {
    final device = await _getFromPrefs();
    if (device == null) return;
    final userId = _prefs.getString(_deviceUserIdPrefsKey);
    if (userId == null) return;
    final extraData = await _deviceApi.fetchDeviceProperties();
    if (device.extraData.toString() == extraData.toString()) return;
    final updatedDevice = device.copyWith(extraData: extraData);
    await _deviceApi.update(userId, updatedDevice);
    await _saveInPrefs(updatedDevice);
  }
  
  
  /// ------------------------------
  /// PRIVATES
  /// ------------------------------

  Future<void> _saveInPrefs(DeviceEntity device) async {
    final json = device.toJsonForPrefs();
    final data = jsonEncode(json);
    await _prefs.setString(_devicePrefsKey, data);
  }

  Future<DeviceEntity?> _getFromPrefs() async {
    final deviceJson = _prefs.getString(_devicePrefsKey);
    if (deviceJson != null) {
      final deviceMap = jsonDecode(deviceJson) as Map<String, dynamic>;
      return DeviceEntity.fromPrefs(deviceMap);
    }
    return null;
  }

  Future<void> _removeFromPrefs() async {
    await _prefs.remove(_devicePrefsKey);
  }
}
