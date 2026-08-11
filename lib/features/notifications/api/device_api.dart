import 'dart:async';
import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:universal_io/io.dart';

abstract class DeviceApi {
  Future<DeviceEntity> get();

  Future<DeviceEntity> register(String userId, DeviceEntity device);

  Future<DeviceEntity> update(String userId, DeviceEntity device);

  Future<void> unregister(String userId, String deviceId);

  Future<void> touch(String userId, String installationId);

  Future<void> cleanupStaleDevices(String userId, String currentInstallationId);

  void onTokenRefresh(OnTokenRefresh onTokenRefresh);

  void removeOnTokenRefreshListener();

  Future<Map<String, String>> fetchDeviceProperties();

  Future<void> clear(String userId);
}

typedef OnTokenRefresh = void Function(String token);

final deviceApiProvider = Provider<DeviceApi>(
  (ref) => FirebaseDeviceApi(
    firestore: FirebaseFirestore.instance,
    messaging: FirebaseMessaging.instance,
    installations: FirebaseInstallations.instance,
  ),
);

class FirebaseDeviceApi implements DeviceApi {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final FirebaseInstallations _installations;
  StreamSubscription? _onTokenRefreshSubscription;

  FirebaseDeviceApi({
    required FirebaseFirestore firestore,
    required FirebaseMessaging messaging,
    required FirebaseInstallations installations,
  })  : _firestore = firestore,
        _messaging = messaging,
        _installations = installations;

  @override
  Future<DeviceEntity> get() async {
    try {
      final installationId = await _installations.getId();
      if (defaultTargetPlatform == TargetPlatform.iOS && !kIsWeb) {
        for (int i = 0; i < 10; i++) {
          final apns = await _messaging.getAPNSToken();
          if (apns != null) break;
          await Future.delayed(const Duration(seconds: 1));
        }
      }
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
      final docId = '${userId}_${device.installationId}';
      await _firestore.collection('devices').doc(docId).set(deviceCpy.toJson());
      return deviceCpy;
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
      final docId = '${userId}_${device.installationId}';
      await _firestore.collection('devices').doc(docId).update(device.toJson());
      return device;
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
      final docId = '${userId}_$installationId';
      await _firestore.collection('devices').doc(docId).delete();
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
      final docId = '${userId}_$installationId';
      await _firestore
          .collection('devices')
          .doc(docId)
          .update({'last_update_date': DateTime.now().toIso8601String()});
    } catch (_) {
      // Ignore
    }
  }

  @override
  Future<void> cleanupStaleDevices(
    String userId,
    String currentInstallationId,
  ) async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    try {
      final snapshot = await _firestore
          .collection('devices')
          .where('user_id', isEqualTo: userId)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final instId = data['installation_id'] as String?;
        final lastUpdateStr = data['last_update_date'] as String?;
        if (instId != currentInstallationId && lastUpdateStr != null) {
          final lastUpdate = DateTime.tryParse(lastUpdateStr);
          if (lastUpdate != null && lastUpdate.isBefore(cutoff)) {
            batch.delete(doc.reference);
          }
        }
      }
      await batch.commit();
    } catch (e) {
      Logger().w('cleanupStaleDevices failed: $e');
    }
  }

  @override
  Future<void> clear(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('devices')
          .where('user_id', isEqualTo: userId)
          .get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
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

  @override
  Future<Map<String, String>> fetchDeviceProperties() async {
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

      appLongVersion = packageInfo.version;
      if (packageInfo.buildNumber.isNotEmpty) {
        appLongVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      }

      try {
        deviceLocale = Platform.localeName.replaceAll('-', '_');
      } catch (e) {
        deviceLocale = 'en_US';
      }

      timezone = timezoneName.identifier;
      deviceTimezone = timezoneName.identifier;

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
        storageSize = '';
        freeStorage = '';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        osVersion = iosInfo.systemVersion;
        deviceModel = iosInfo.model;
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
    if (address.startsWith('127.')) return true;
    if (address.startsWith('169.254.')) return true;
    if (address.startsWith('10.')) return true;
    if (address.startsWith('192.168.')) return true;
    if (address.startsWith('172.')) {
      final parts = address.split('.');
      if (parts.length >= 2) {
        final secondOctet = int.tryParse(parts[1]) ?? 0;
        if (secondOctet >= 16 && secondOctet <= 31) {
          return true;
        }
      }
    }
    return false;
  }

  bool _isGlobalUnicastIpv6(String address) {
    final cleanAddress = address.split('%').first.toLowerCase();
    if (cleanAddress.isEmpty) return false;
    final firstChar = cleanAddress[0];
    return (firstChar == '2' || firstChar == '3') && 
           !cleanAddress.startsWith('fe80:') &&
           cleanAddress != '::1';
  }

  Future<String?> getIpAddress() async {
    if (kIsWeb) return null;
    try {
      final interfaces = await io.NetworkInterface.list();
      String? publicIpv4;
      String? globalIpv6;

      for (final element in interfaces) {
        for (final addr in element.addresses) {
          if (addr.isLoopback) continue;
          if (addr.type == io.InternetAddressType.IPv4) {
            if (!_isPrivateIp(addr.address) && !addr.isLinkLocal) {
              publicIpv4 = addr.address;
              break;
            }
          } else if (addr.type == io.InternetAddressType.IPv6) {
            final cleanAddress = addr.address.split('%').first;
            if (cleanAddress.startsWith('fe80:') || cleanAddress == '::1') {
              continue;
            }
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
}
