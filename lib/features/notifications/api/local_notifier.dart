import 'dart:convert';

import 'package:cowboydodartinc/core/initializer/onstart_service.dart';
import 'package:cowboydodartinc/features/notifications/providers/models/notification.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest_all.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
import 'package:universal_html/js.dart';
import 'package:universal_io/io.dart';

final localNotifierProvider = Provider<LocalNotifier>((ref) {
  return LocalNotifier(
    notificationManager: FlutterLocalNotificationsPlugin(),
  );
});

const kAppName = 'cowboydodartinc';

final notificationsSettingsProvider = Provider<NotificationSettings>((ref) => defaultNotificationSettings);

final defaultNotificationSettings = NotificationSettings(
  notificationManager: FlutterLocalNotificationsPlugin(),
  androidChannel: const AndroidNotificationChannel(
    // channel id - you can use different channels for different purposes (News, Messages, etc)
    kAppName,
    // app id
    kAppName,
    // this is the description of the channel that will be shown in the Android notification settings
    description: 'general $kAppName channel',
    importance: Importance.max,
  ),
);

/// Firebase shows automatically notifications when the app is in background
/// But when the app is in foreground, you have to show the notification yourself on iOS
/// Also with this you can schedule notifications
/// For more informations check the documentation: https://pub.dev/packages/flutter_local_notifications
///
/// As we don't rely on mocks we wrapped the flutter_local_notifications plugin for our needs
class LocalNotifier {
  final FlutterLocalNotificationsPlugin _notificationManager;

  TimezoneInfo? _currentTimeZone;

  LocalNotifier({
    required FlutterLocalNotificationsPlugin notificationManager,
  }) : _notificationManager = notificationManager;

  Future<void> show(NotificationSettings settings, Notification message) async {
    if (kIsWeb) {
      context.callMethod("showNotification", [
        message.title,
        message.body,
      ]);
      return;
    }

    AndroidNotificationDetails? androidWithImage;
    if (message.imageUrl != null) {
      try {
        final bytes = await _downloadImageBytes(message.imageUrl!);
        final bitmap = ByteArrayAndroidBitmap(bytes);
        androidWithImage = AndroidNotificationDetails(
          settings.androidChannel.id,
          settings.androidChannel.name,
          importance: settings.androidChannel.importance,
          priority: Priority.high,
          channelDescription: settings.androidChannel.description ?? '',
          styleInformation: BigPictureStyleInformation(
            bitmap,
            largeIcon: bitmap,
          ),
        );
      } catch (_) {
        // Image download failed — fall through to plain notification below.
      }
    }
    final androidDetails = androidWithImage ??
        AndroidNotificationDetails(
          settings.androidChannel.id,
          settings.androidChannel.name,
          importance: settings.androidChannel.importance,
          priority: Priority.high,
          channelDescription: settings.androidChannel.description ?? '',
        );

    DarwinNotificationDetails? iosDetails;
    File? iosTempFile;
    if (message.imageUrl != null) {
      try {
        // Keep the file on disk: the iOS UNNotificationAttachment only reads it
        // while show() runs. Deleting it before show() makes iOS reject the
        // whole notification, so it never appears. Clean up after show() below.
        iosTempFile = await _downloadImageToTemp(message.imageUrl!);
        iosDetails = DarwinNotificationDetails(
          attachments: [DarwinNotificationAttachment(iosTempFile.path)],
        );
      } catch (_) {
        // Image download failed — show notification without image rather than
        // silently dropping it.
      }
    }

    try {
      await _notificationManager.show(
        id: message.hashCode,
        title: message.title,
        body: message.body,
        payload: jsonEncode(message.toJson()),
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
      );
    } catch (_) {
      // If showing with the attachment failed for any reason, retry without the
      // image so the notification still reaches the user.
      await _notificationManager.show(
        id: message.hashCode,
        title: message.title,
        body: message.body,
        payload: jsonEncode(message.toJson()),
        notificationDetails: NotificationDetails(android: androidDetails),
      );
    } finally {
      // iOS has copied the attachment by now; remove our temp file.
      try {
        iosTempFile?.deleteSync();
      } catch (_) {}
    }
  }

  Future<Uint8List> _downloadImageBytes(String url) async {
    final response = await Dio().get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  Future<File> _downloadImageToTemp(String url) async {
    final bytes = await _downloadImageBytes(url);
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/notif_img_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Setup the time zone for the notifications
  /// Returns the current time in the user's time zone
  Future<String> _setupTimeZones() async {
    if (_currentTimeZone == null) {
      tz.initializeTimeZones();
      _currentTimeZone = await FlutterTimezone.getLocalTimezone();
    }
    return _currentTimeZone?.identifier ?? '';
  }

  ////////////////////////
  /// Scheduling
  ////////////////////////

  Future<void> scheduleDailyAt({
    required int notificationId,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    if (kIsWeb) return;
    await _notificationManager.cancel(id: notificationId);

    final currentTimeZone = await _setupTimeZones();
    final now = tz.TZDateTime.now(tz.getLocation(currentTimeZone));
    final scheduledDate = tz.TZDateTime(
      tz.getLocation(currentTimeZone),
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    const androidDetails = AndroidNotificationDetails(
      kAppName,
      kAppName,
      importance: Importance.max,
    );
    const iosDetails = DarwinNotificationDetails(
      threadIdentifier: kAppName,
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notificationManager.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleWeekly({
    required String title,
    required String body,
    required int dayOfWeekIndex,
    required int hour,
    required int minute,
    String? payload,
    int notificationId = 0,
  }) async {
    if (kIsWeb) return;
    await _notificationManager.cancel(id: notificationId);

    final currentTimeZone = await _setupTimeZones();
    final now = tz.TZDateTime.now(tz.getLocation(currentTimeZone));
    final scheduledDate = tz.TZDateTime(
      tz.getLocation(currentTimeZone),
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    final daysUntilNext = (dayOfWeekIndex - scheduledDate.weekday) % 7;
    final nextScheduledDate = scheduledDate.add(Duration(days: daysUntilNext));

    const androidDetails = AndroidNotificationDetails(
      kAppName,
      kAppName,
      importance: Importance.max,
    );
    const iosDetails = DarwinNotificationDetails(
      threadIdentifier: kAppName,
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notificationManager.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: nextScheduledDate,
      notificationDetails: platformChannelSpecifics,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleAt({
    required String title,
    required String body,
    required DateTime date,
    String? payload,
    int notificationId = 0,
  }) async {
    if (kIsWeb) return;
    await _notificationManager.cancel(id: notificationId);
    
    final currentTimeZone = await _setupTimeZones();
    final scheduledDate = tz.TZDateTime.from(
      date,
      tz.getLocation(currentTimeZone),
    );

    const androidDetails = AndroidNotificationDetails(
      kAppName,
      kAppName,
      importance: Importance.max,
    );
    const iosDetails = DarwinNotificationDetails(
      threadIdentifier: kAppName,
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notificationManager.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
  
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _notificationManager.cancelAll();
  }

  Future<void> cancel(int notificationId) async {
    if (kIsWeb) return;
    await _notificationManager.cancel(id: notificationId);
  }

  Future<List<PendingNotificationRequest>> listPendingNotifications() async {
    if (kIsWeb) return [];
    return await _notificationManager.pendingNotificationRequests();
  }
  
}

/// This is the settings for the notifications
/// You could have this directly in LocalNotifier but it's better to separate the concerns
/// So now you can send different notifications with different settings
/// [init] method will be called automatically by the [Initializer] class
class NotificationSettings implements OnStartService {
  final FlutterLocalNotificationsPlugin _notificationManager;
  final AndroidNotificationChannel androidChannel;

  NotificationSettings({
    required FlutterLocalNotificationsPlugin notificationManager,
    required this.androidChannel,
  }) : _notificationManager = notificationManager;

  @override
  Future<void> init() async {
    if (kIsWeb) return;
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    // we don't want to request permissions for iOS directly
    // we ask it nicely during the onboarding process
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    _notificationManager.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (payload) => redirectToPayload(payload),
    );
    await _notificationManager
        .resolvePlatformSpecificImplementation //
        <AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<bool> askPermission() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final result = await _notificationManager
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    } else if (Platform.isIOS) {
      final result = await _notificationManager
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    throw 'Platform not supported';
  }

  /// Whether notifications are actually enabled at the OS level.
  /// Differs from [Permission.notification.status] when the user granted
  /// permission before but later disabled notifications in system settings.
  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final bool? enabled = await _notificationManager
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return enabled ?? false;
    }
    if (Platform.isIOS) {
      final options = await _notificationManager
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return options?.isEnabled ?? false;
    }
    return false;
  }

  Future<void> redirectToPayload(
    NotificationResponse notificationResponse,
  ) async {
    if (notificationResponse.payload == null) {
      return;
    }
    if (notificationResponse.payload!.isEmpty == true) {
      Logger().i("Payload is empty");
      return;
    }
    try {
      final json = jsonDecode(notificationResponse.payload!) as Map<String, dynamic>;
      final notification = Notification.fromJson(json);
      await notification.onTap();
    } catch (e, s) {
      Logger().e("--> json : ${notificationResponse.payload}");
      Logger().e("error $e, $s");
      Sentry.captureException(e, stackTrace: s);
    }
  }
}
