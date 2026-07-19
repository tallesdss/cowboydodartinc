import 'dart:async';
import 'dart:io' as io;

import 'package:cowboydodartinc/core/data/api/base_api_exceptions.dart';
import 'package:cowboydodartinc/features/notifications/api/entities/device_entity.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_io/io.dart';

abstract class DeviceApi {
  /// We use a unique id for the device / installation
  /// This allows to send notifications to a specific device
  /// iOS and Android tends now to restrict the use of device id
  /// You could also generate your own id and store it in the device
  /// But as we use firebase for notifications we can use the firebase installation id
  Future<DeviceEntity> get();

  /// Register the device in the backend
  /// Of course your backend should check if the device is already registered
  /// throws an [ApiError] if something goes wrong
  Future<DeviceEntity> register(String userId, DeviceEntity device);

  /// Update the device in the backend
  /// throws an [ApiError] if something goes wrong
  Future<DeviceEntity> update(String userId, DeviceEntity device);

  /// Unregister the device in the backend
  Future<void> unregister(String userId, String deviceId);

  /// Heartbeat — update `last_update_date` on the current device row.
  /// Used so the backend can detect orphan rows from previous installs.
  Future<void> touch(String userId, String installationId);

  /// Delete device rows of the same user that haven't been touched in a while.
  /// Called after registering a fresh installation to remove orphans left by
  /// previous installs (whose installation_id no longer matches).
  Future<void> cleanupStaleDevices(String userId, String currentInstallationId);

  /// Listen to token refresh
  void onTokenRefresh(OnTokenRefresh onTokenRefresh);

  /// Remove the token refresh listener
  void removeOnTokenRefreshListener();

  
  /// Fetches all device properties
  /// Returns a map with all device information
  Future<Map<String, String>> fetchDeviceProperties();

  /// Clear the devices for a user
  Future<void> clear(String userId);
  
}

typedef OnTokenRefresh = void Function(String token);

final deviceApiProvider = Provider<DeviceApi>(
  (ref) => FirebaseDeviceApi(
    client: Supabase.instance.client,
    messaging: FirebaseMessaging.instance,
    installations: FirebaseInstallations.instance,
  ),
);

class FirebaseDeviceApi implements DeviceApi {
  final SupabaseClient _client;
  final FirebaseMessaging _messaging;
  final FirebaseInstallations _installations;
  StreamSubscription? _onTokenRefreshSubscription;

  FirebaseDeviceApi({
    required SupabaseClient client,
    required FirebaseMessaging messaging,
    required FirebaseInstallations installations,
  })  : _client = client,
        _messaging = messaging,
        _installations = installations;

  @override
  Future<DeviceEntity> get() async {
    try {
      final installationId = await _installations.getId();
      // On iOS, the APNS token may not be immediately available on first launch.
      // We wait up to ~10 seconds before giving up.
      if (defaultTargetPlatform == TargetPlatform.iOS && !kIsWeb) {
        for (int i = 0; i < 10; i++) {
          final apns = await _messaging.getAPNSToken();
          if (apns != null) break;
          await Future.delayed(const Duration(seconds: 1));
        }
      }
      // Register the installation even without a push token. On iOS the FCM
      // token stays null until the user grants notification permission (and
      // getToken can even throw before APNS is ready). We still create the
      // device row — so the welcome notification fires and the install is
      // tracked — and the token fills in later via onTokenRefresh once push is
      // enabled.
      String token = '';
      try {
        token = await _messaging.getToken() ?? '';
      } catch (_) {
        token = '';
      }
      final os = Platform.isAndroid
          ? OperatingSystem.android //
          : OperatingSystem.ios;
      return DeviceEntity(
        installationId: installationId,
        token: token,
        operatingSystem: os,
        creationDate: DateTime.now(),
        lastUpdateDate: DateTime.now(),
      );
    } catch (e) {
      throw ApiError(
        code: 0,
        message: '$e',
      );
    }
  }

  @override
  Future<DeviceEntity> register(String userId, DeviceEntity device) async {
    try {
      final deviceCpy = device.copyWith(userId: userId);
      // Use upsert so that re-registering the same (user_id, installation_id)
      // pair (e.g. token refresh, app reinstall) updates the row instead of
      // throwing a UNIQUE constraint violation.
      final result = await _client
          .from('devices')
          .upsert(deviceCpy.toJson(), onConflict: 'user_id,installation_id')
          .select();
      return DeviceEntity.fromJson(result.first);
    } catch (e, trace) {
      throw ApiError(
        code: 0,
        message: '$e : $trace',
      );
    }
  }

  @override
  Future<DeviceEntity> update(String userId, DeviceEntity device) async {
    try {
      final result = await _client
          .from('devices') //
          .update(device.toJson())
          .eq('installation_id', device.installationId)
          .select();
      return DeviceEntity.fromJson(result.first);
    } catch (e, trace) {
      throw ApiError(
        code: 0,
        message: '$e: $trace',
      );
    }
  }

  @override
  Future<void> unregister(String userId, String installationId) async {
    try {
      await _client
          .from('devices') //
          .delete()
          .eq('installation_id', installationId);
    } catch (e) {
      throw ApiError(
        code: 0,
        message: '$e',
      );
    }
  }

  @override
  Future<void> touch(String userId, String installationId) async {
    try {
      await _client
          .from('devices')
          .update({'last_update_date': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .eq('installation_id', installationId);
    } catch (_) {
      // Missing row — caller will re-register on next session.
    }
  }

  @override
  Future<void> cleanupStaleDevices(
    String userId,
    String currentInstallationId,
  ) async {
    // Devices not touched in the last 30 days are treated as orphans from
    // previous installations on the same physical device. Active second
    // devices stay above this threshold via heartbeat.
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    try {
      await _client
          .from('devices')
          .delete()
          .eq('user_id', userId)
          .neq('installation_id', currentInstallationId)
          .lt('last_update_date', cutoff.toIso8601String());
    } catch (e) {
      Logger().w('cleanupStaleDevices failed: $e');
    }
  }

  @override
  Future<void> clear(String userId) async {
    try {
      await _client
          .from('devices') //
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw ApiError(
        code: 0,
        message: '$e',
      );
    }
  }

  @override
  void onTokenRefresh(OnTokenRefresh onTokenRefresh) {
    _onTokenRefreshSubscription =
        _messaging.onTokenRefresh.listen((data) => onTokenRefresh(data));
  }

  @override
  void removeOnTokenRefreshListener() {
    _onTokenRefreshSubscription?.cancel();
  }

  
  Future<String?> getMobileAdvertiserId() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final isGranted = await Permission.appTrackingTransparency.isGranted;
        if (!isGranted) {
          return null;
        }
      }
      const platform = MethodChannel('kasy_kit/advertising_id');
      return platform.invokeMethod<String>('getAdvertisingId');
    } catch (e, trace) {
      Logger().e('Error getting mobile advertiser id: $e, $trace');
      return null;
    }
  }

  Future<String?> getAnonymousFbId() async {
    try {
      final facebookAppEvents = FacebookAppEvents();
      final anonymousFbId = await facebookAppEvents.getAnonymousId();
      return anonymousFbId;
    } catch (_) {
      return null;
    }
  }

  bool _isPrivateIp(String address) {
    if (address.startsWith('127.')) return true; // Loopback
    if (address.startsWith('169.254.')) return true; // Link-local
    if (address.startsWith('10.')) return true; // Private: 10.0.0.0/8
    if (address.startsWith('192.168.')) return true; // Private: 192.168.0.0/16
    if (address.startsWith('172.')) {
      final parts = address.split('.');
      if (parts.length >= 2) {
        final secondOctet = int.tryParse(parts[1]) ?? 0;
        if (secondOctet >= 16 && secondOctet <= 31) {
          return true; // Private: 172.16.0.0/12
        }
      }
    }
    return false;
  }

  bool _isGlobalUnicastIpv6(String address) {
    // Remove zone identifier if present (e.g., "2a01:cb15:...%30" -> "2a01:cb15:...")
    final cleanAddress = address.split('%').first.toLowerCase();
    if (cleanAddress.isEmpty) return false;
    // Global Unicast Addresses (GUA) are in the range 2000::/3
    // This means they start with 2000:: to 3fff:ffff:ffff:...
    // First hex digit should be 2 or 3
    final firstChar = cleanAddress[0];
    // Check if it starts with 2xxx: or 3xxx: (Global Unicast)
    // Also exclude link-local (fe80::) and loopback (::1) which are already filtered
    return (firstChar == '2' || firstChar == '3') && 
           !cleanAddress.startsWith('fe80:') &&
           cleanAddress != '::1';
  }

  Future<String?> getIpAddress() async {
    if (kIsWeb) return null;
    try {
      // First, try to find a public IP in network interfaces
      final interfaces = await io.NetworkInterface.list();
      String? publicIpv4;
      String? globalIpv6; // Global Unicast Address (GUA) - used for internet

      for (final element in interfaces) {
        for (final addr in element.addresses) {
          if (addr.isLoopback) continue;
          if (addr.type == io.InternetAddressType.IPv4) {
            if (!_isPrivateIp(addr.address) && !addr.isLinkLocal) {
              publicIpv4 = addr.address;
              break; // Prefer IPv4
            }
          } else if (addr.type == io.InternetAddressType.IPv6) {
            final cleanAddress = addr.address.split('%').first;
            // Skip link-local (fe80::) and loopback (::1)
            if (cleanAddress.startsWith('fe80:') || cleanAddress == '::1') {
              continue;
            }
            // Prioritize Global Unicast Addresses (GUA) - these are public internet addresses
            // GUAs are in 2000::/3 range (start with 2xxx: or 3xxx:)
            if (_isGlobalUnicastIpv6(cleanAddress)) {
              globalIpv6 = cleanAddress;
              break;
            } 
          }
        }
        if (publicIpv4 != null) break;
      }
      if (globalIpv6 != null) return globalIpv6;
      if (publicIpv4 != null) return publicIpv4;
      return null;
    } catch (e) {
      Logger().e('Error getting IP address: $e');
      return null;
    }
  }


  /// Fetches all device properties
  /// Returns a map with all device information
  @override
  Future<Map<String, String>> fetchDeviceProperties() async {
    // On web there is no native device layer (no NetworkInterface, no Platform):
    // return static values so the app works as a PWA without throwing at runtime.
    if (kIsWeb) {
      final webLocale = PlatformDispatcher.instance.locale.toLanguageTag().replaceAll('-', '_');
      return {
        'appLongVersion': '',
        'osVersion': 'web',
        'deviceModel': 'browser',
        'deviceLocale': webLocale,
        'timezone': '',
        'carrier': '',
        'screenWidth': '',
        'screenHeight': '',
        'screenDensity': '',
        'cpuCores': '',
        'storageSize': '',
        'freeStorage': '',
        'deviceTimezone': '',
        'mobileAdvertiserId': '',
        'anonymousFbId': '',
        'clientIpAddress': '',
      };
    }
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      final platformDispatcher = PlatformDispatcher.instance;
      final screenSize = platformDispatcher.views.first.physicalSize / platformDispatcher.views.first.devicePixelRatio;
      final devicePixelRatio = platformDispatcher.views.first.devicePixelRatio;
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      
      String appLongVersion = '';
      String osVersion = '';
      String deviceModel = '';
      String deviceLocale = 'en_US';
      String timezone = '';
      String carrier = '';
      String screenWidth = '';
      String screenHeight = '';
      String screenDensity = '';
      String cpuCores = '';
      String storageSize = '';
      String freeStorage = '';
      String deviceTimezone = '';
      String mobileAdvertiserId = '';
      String anonymousFbId = '';
      String ipAddress = '';

      mobileAdvertiserId = await getMobileAdvertiserId() ?? '';
      anonymousFbId = await getAnonymousFbId() ?? '';
      ipAddress = await getIpAddress() ?? '';

      // App version
      appLongVersion = packageInfo.version;
      if (packageInfo.buildNumber.isNotEmpty) {
        appLongVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      }

      // Device locale
      try {
        deviceLocale = Platform.localeName.replaceAll('-', '_');
      } catch (e) {
        deviceLocale = 'en_US';
      }

      // Timezone
      timezone = timezoneName.identifier;
      deviceTimezone = timezoneName.identifier;

      // Screen dimensions
      screenWidth = screenSize.width.toInt().toString();
      screenHeight = screenSize.height.toInt().toString();
      screenDensity = devicePixelRatio.toStringAsFixed(2);

      try {
        final processorCount = io.Platform.numberOfProcessors;
        cpuCores = processorCount.toString();
      } catch (_) {}

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        osVersion = androidInfo.version.release;
        deviceModel = androidInfo.model;
        
        // Storage (Android) TODO
        storageSize = '';
        freeStorage = '';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        osVersion = iosInfo.systemVersion;
        deviceModel = iosInfo.model;

        // TODO: Carrier and storage
        carrier = '';
        storageSize = '';
        freeStorage = '';
      }

      return {
        'appLongVersion': appLongVersion,
        'osVersion': osVersion,
        'deviceModel': deviceModel,
        'deviceLocale': deviceLocale,
        'timezone': timezone,
        'carrier': carrier,
        'screenWidth': screenWidth,
        'screenHeight': screenHeight,
        'screenDensity': screenDensity,
        'cpuCores': cpuCores,
        'storageSize': storageSize,
        'freeStorage': freeStorage,
        'deviceTimezone': deviceTimezone,
        'mobileAdvertiserId': mobileAdvertiserId,
        'anonymousFbId': anonymousFbId,
        'clientIpAddress': ipAddress,
      };
    } catch (e, trace) {
      Logger().e('Error fetching device properties: $e, $trace');
      // Return empty values on error
      return {
        'appLongVersion': '',
        'osVersion': '',
        'deviceModel': '',
        'deviceLocale': 'en_US',
        'timezone': '',
        'carrier': '',
        'screenWidth': '',
        'screenHeight': '',
        'screenDensity': '',
        'cpuCores': '',
        'storageSize': '',
        'freeStorage': '',
        'deviceTimezone': '',
        'mobileAdvertiserId': '',
        'anonymousFbId': '',
        'clientIpAddress': '',
      };
    }
  }
  
}
