// ignore_for_file: invalid_annotation_target, constant_identifier_names

import 'package:cowboydodartinc/core/bottom_menu/active_tab_notifier.dart';
import 'package:cowboydodartinc/core/bottom_menu/bart_inner_navigation.dart';
import 'package:cowboydodartinc/features/notifications/api/entities/notifications_entity.dart';
import 'package:cowboydodartinc/features/notifications/api/local_notifier.dart';
import 'package:cowboydodartinc/features/notifications/repositories/notifications_repository.dart';
import 'package:cowboydodartinc/router.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
sealed class Notification with _$Notification {
  const Notification._();

  const factory Notification.withData({
    String? id,
    required String title,
    required String body,
    required DateTime createdAt,
    DateTime? readAt,
    String? imageUrl,
    @JsonKey(includeFromJson: false, includeToJson: false)
    LocalNotifier? notifier,
    @JsonKey(includeFromJson: false, includeToJson: false)
    NotificationSettings? notifierSettings,
    NotificationTypes? type,
    Map<String, dynamic>? data,
  }) = NotificationData;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  factory Notification.from(
    Map<String, dynamic> json, {
    String? id,
    Map<String, dynamic>? data,
    LocalNotifier? notifierApi,
    NotificationSettings? notifierSettings,
  }) => Notification.withData(
    id: id,
    title: json['title'] as String,
    body: json['body'] as String,
    imageUrl: json['image'] as String? ?? data?['imageUrl']?.toString(),
    type: data != null && data.containsKey('type')
        ? NotificationTypes.values.firstWhere(
            (e) => e.name == data['type'],
            orElse: () => NotificationTypes.OTHER,
          )
        : null,
    data: data,
    createdAt: DateTime.now(),
    notifier: notifierApi,
    notifierSettings: notifierSettings,
  );

  Future<void> show({NotificationSettings? settings}) async {
    if (notifier == null) {
      throw Exception(
        'You must provide a LocalNotifierApi to show a notification',
      );
    }
    if (notifierSettings != null) {
      await notifier!.show(notifierSettings!, this);
      return;
    } else if (settings != null) {
      await notifier!.show(settings, this);
      return;
    }
    throw Exception(
      'You must provide a NotificationSettings to show a notification',
    );
  }

  bool get seen => readAt != null;

  /// Whether tapping this notification leads somewhere: an external URL (LINK)
  /// or an internal deep-link route. When false the notification is purely
  /// informational; the body is shown in the list (up to
  /// [kNotificationListBodyMaxLines] lines) and the tile is not tappable.
  bool get hasDestination =>
      (type == NotificationTypes.LINK && data?.containsKey('url') == true) ||
      (data?.containsKey('route') == true);

  Future<void> onTap() async {
    // if the app is not ready, we store the notification in the pending notification handler
    if (navigatorKey.currentContext == null) {
      return;
    }

    // Open external URL
    if (type == NotificationTypes.LINK && data?.containsKey('url') == true) {
      try {
        launchUrl(Uri.parse(data!['url'] as String));
      } catch (e, s) {
        Logger().e("error $e");
        Sentry.captureException(e, stackTrace: s);
      }
      return;
    }
    // Navigate to an internal route sent in the notification data.
    // Example: data: {"route": "/premium"} → opens the premium page.
    if (data?.containsKey('route') == true) {
      await _goToNotificationRoute(data!['route'] as String);
      return;
    }
    // No deep-link: informational only. Body is shown in the list (up to
    // [kNotificationListBodyMaxLines] lines); nothing to open on tap.
    return;
  }

  /// Destinations that live inside the BottomMenu shell as top-level tabs.
  /// Settings drill-downs (`/reminder`, `/feedback`) are handled separately so
  /// the shell is not remounted and the back stack stays intact.
  static const _shellTabRoutes = {
    '/',
    '/notifications',
    '/settings',
    '/support',
  };

  /// Maps notification deep-link routes to settings inner segments.
  static const _settingsInnerNotificationRoutes = {
    '/reminder': 'reminder',
    '/feedback': 'feedback',
  };

  /// Returns whether [location] matches a route registered in GoRouter.
  static bool _isKnownRoute(String location) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      return false;
    }
    final RouteMatchList matchList = GoRouter.of(
      context,
    ).configuration.findMatch(Uri.parse(location));
    return matchList.matches.isNotEmpty && matchList.error == null;
  }

  /// Navigates to a route opened from a notification tap.
  ///
  /// Shell destinations replace the stack (bottom nav / sidebar is the way back).
  /// Stand-alone pages (e.g. /premium, /post/:id) open on top of Home so back
  /// returns into the app — a synthetic back stack — instead of doing nothing
  /// because the screen was opened "out of nowhere". Unknown routes fall back
  /// to the notifications list.
  Future<void> _goToNotificationRoute(String route) async {
    final context = navigatorKey.currentContext!;
    if (!_isKnownRoute(route)) {
      Logger().w('Unknown notification route "$route", falling back to /notifications');
      context.go('/notifications');
      return;
    }
    final String? settingsInnerSegment = _settingsInnerNotificationRoutes[route];
    if (settingsInnerSegment != null) {
      _openSettingsInnerFromNotification(settingsInnerSegment);
      return;
    }
    if (_shellTabRoutes.contains(route)) {
      _openShellTabFromNotification(route);
      return;
    }
    await _openStandaloneFromNotification(route);
  }

  /// Switches a bottom-bar tab in place (no GoRouter remount).
  void _openShellTabFromNotification(String route) {
    final BuildContext context = navigatorKey.currentContext!;
    if (kasyShellNavigatorKey.currentContext != null &&
        _isBottomMenuShellActive(context)) {
      navigateShellTabInPlace(route);
      return;
    }
    context.go(route);
  }

  /// Opens a full-screen route (e.g. /premium) on the root navigator.
  Future<void> _openStandaloneFromNotification(String route) async {
    final BuildContext context = navigatorKey.currentContext!;
    if (kasyShellNavigatorKey.currentContext != null &&
        _isBottomMenuShellActive(context)) {
      await context.push(route);
      restoreShellAfterStandaloneRoute();
      return;
    }
    context.go('/');
    await Future<void>.delayed(Duration.zero);
    final BuildContext? root = navigatorKey.currentContext;
    if (root == null || !root.mounted) {
      return;
    }
    await root.push(route);
    restoreShellAfterStandaloneRoute();
  }

  /// Opens Reminders / Feedback from a notification without remounting the shell.
  ///
  /// When the user was browsing the notifications list, back returns there.
  /// Cold-start taps (push) land on Home first, then stack the inner route.
  void _openSettingsInnerFromNotification(String segment) {
    final BuildContext context = navigatorKey.currentContext!;
    if (peekSettingsInnerReturnPath() == null) {
      setSettingsInnerReturnPath(_settingsInnerReturnPathFor(context));
    }
    if (isSettingsInnerRouteVisible(segment)) {
      return;
    }
    final BuildContext? shellContext = kasyShellNavigatorKey.currentContext;
    if (shellContext != null && _isBottomMenuShellActive(context)) {
      pushSettingsInnerRoute(shellContext, segment);
      return;
    }
    final String landingPath =
        peekSettingsInnerReturnPath() ?? _settingsInnerReturnPathFor(context);
    context.go(landingPath);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? nested = kasyShellNavigatorKey.currentContext;
      if (nested == null || !nested.mounted) {
        return;
      }
      if (isSettingsInnerRouteVisible(segment)) {
        return;
      }
      pushSettingsInnerRoute(nested, segment);
    });
  }

  bool _isBottomMenuShellActive(BuildContext context) {
    final String location = GoRouter.of(context).state.matchedLocation;
    return location == '/' ||
        location == '/notifications' ||
        location == '/settings' ||
        location == '/support' ||
        location.startsWith('/settings/');
  }

  String _settingsInnerReturnPathFor(BuildContext context) {
    final String? activeTab = activeTabRouteNotifier.value;
    if (activeTab == 'notifications') {
      return '/notifications';
    }
    final String location = GoRouter.of(context).state.matchedLocation;
    if (location == '/notifications') {
      return '/notifications';
    }
    return '/';
  }
}

sealed class NotificationPermission {
  /// ask for permission if needed
  Future<void> maybeAsk() async {
    final permission = this;
    switch (permission) {
      case NotificationPermissionWaiting():
        await permission.ask();
      case NotificationPermissionDenied():
        await permission.ask();
      case NotificationPermissionPermanentlyDenied():
        await permission.openSettings();
      case NotificationPermissionGranted():
        await permission.ensureSetup();
    }
  }
}

/// we asked for permission and it was granted
class NotificationPermissionGranted extends NotificationPermission {
  final NotificationSettings? _notificationSettings;
  final NotificationsRepository? _repository;

  NotificationPermissionGranted({
    NotificationSettings? notificationSettings,
    NotificationsRepository? repository,
  }) : _notificationSettings = notificationSettings,
       _repository = repository;

  /// Re-initializes notifications when already granted, or opens settings when
  /// permission was granted but notifications were disabled in system settings.
  Future<void> ensureSetup() async {
    final NotificationSettings? settings = _notificationSettings;
    final NotificationsRepository? repository = _repository;
    if (settings == null || repository == null) {
      return;
    }
    final bool enabled = await settings.areNotificationsEnabled();
    if (enabled) {
      await repository.init();
      return;
    }
    await openAppSettings();
  }
}

/// we asked for permission and it was denied (but can still be asked again)
class NotificationPermissionDenied extends NotificationPermission {
  final NotificationSettings? _notificationSettings;
  final NotificationsRepository? _repository;

  NotificationPermissionDenied({
    NotificationSettings? notificationSettings,
    NotificationsRepository? repository,
  }) : _repository = repository,
       _notificationSettings = notificationSettings;

  Future<void> ask() async {
    if (_notificationSettings == null) {
      throw Exception("NotificationsApi is null");
    }
    await _notificationSettings.askPermission();
    await _repository?.init();
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}

/// User denied the permission and the OS will not show the native prompt again.
/// The only way back is the system settings of the app.
class NotificationPermissionPermanentlyDenied extends NotificationPermission {
  Future<void> openSettings() async {
    await openAppSettings();
  }
}

/// we never asked for permission
class NotificationPermissionWaiting extends NotificationPermission {
  final NotificationSettings? _notificationSettings;
  final NotificationsRepository? _repository;

  NotificationPermissionWaiting({
    NotificationSettings? notificationSettings,
    NotificationsRepository? repository,
  }) : _notificationSettings = notificationSettings,
       _repository = repository;

  Future<void> ask() async {
    if (_notificationSettings == null) {
      throw Exception("NotificationsApi is null");
    }
    await _notificationSettings.askPermission();
    await _repository?.init();
  }
}
