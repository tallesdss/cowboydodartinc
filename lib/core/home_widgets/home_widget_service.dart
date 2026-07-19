import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:cowboydodartinc/core/home_widgets/home_widget_background_task.dart';
import 'package:cowboydodartinc/core/home_widgets/home_widget_mywidget_service.dart';
import 'package:cowboydodartinc/core/initializer/onstart_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:logger/logger.dart';

final homeWidgetsManagerProvider = Provider<HomeWidgetsManager>(
  (ref) => HomeWidgetsManager(ref),
);

const String appGroupId = 'group.com.cowboydodartinc.app';

/// Manager for all home widgets
/// -> Don't modify this file
/// ------------------------------------------------------------
/// will be used to initialize the home widgets and set the app group id
/// Register the background task for the home widgets
class HomeWidgetsManager implements OnStartService {
  HomeWidgetsManager(this._ref);

  final Ref _ref;

  @override
  Future<void> init() async {
    if (kIsWeb) return;
    try {
      // Must be set BEFORE any saveWidgetData call, otherwise the data lands
      // in the default UserDefaults suite and the native widget extension
      // (which reads from the app group) sees nothing.
      await HomeWidget.setAppGroupId(appGroupId);

      // Read the widget notifier so its user-state listener attaches —
      // future state changes (login/logout, subscription) auto-refresh
      // the widget without waiting for the 15-min background tick.
      final myWidget = _ref.read(myWidgetHomeWidgetProvider.notifier);
      // Push initial data so the widget renders something on first install
      // instead of staying blank until the background task fires.
      // Fire-and-forget: we do NOT await here because update() may do a
      // network call (RevenueCat) that could stall app startup and even
      // prevent BackgroundFetch from being configured. setAppGroupId has
      // already completed, so it is safe to fire it off now.
      unawaited(myWidget.update());

      final status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.ANY,
        ),
        (String taskId) async {
          final res = await homeWidgetCallbackDispatcher();
          BackgroundFetch.finish(taskId);
          return res;
        },
      );
      Logger().i('🔄 - Home widgets manager initialized with status: $status');
      await BackgroundFetch.start();
    } catch (e, s) {
      Logger().e('⚠️  Could not initialize home widgets: $e $s');
    }
  }
}

abstract class UpdatableHomeWidget {
  Future<void> update();
}
