import 'package:bart/bart.dart';
import 'package:cowboydodartinc/core/bottom_menu/active_tab_notifier.dart';
import 'package:cowboydodartinc/core/bottom_menu/bart_inner_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression test for the notification → Settings sub-page → back flow.
///
/// Tapping a notification that deep-links to a Settings sub-page (Reminders /
/// Feedback) opens it as a Bart INNER route. Inner routes live under the
/// Settings tab (`/settings/reminder`) even when the user was on another tab, so
/// Bart points its own index at Settings on push. Going back must return the
/// shell to where the user came from (Notifications) and leave NOTHING pointing
/// at Settings.
///
/// The bug: the inner route's dispose fires AFTER the pop transition, when the
/// synchronous suppression bracket had already lifted, and ran a SECOND chrome
/// restore that defaulted to the parent `/settings` tab. That stranded Bart's
/// index on Settings, so the Settings tab looked "already selected" and tapping
/// it did nothing (only Home / Support stayed clickable).
void main() {
  List<BartMenuRoute> shellRoutes() => [
    BartMenuRoute.bottomBar(
      label: 'Home',
      icon: Icons.home,
      path: 'home',
      pageBuilder: (_, _, _) => const Text('HOME'),
    ),
    BartMenuRoute.bottomBar(
      label: 'Support',
      icon: Icons.help,
      path: 'support',
      pageBuilder: (_, _, _) => const Text('SUPPORT'),
    ),
    BartMenuRoute.bottomBar(
      label: 'Notifications',
      icon: Icons.notifications,
      path: 'notifications',
      pageBuilder: (_, _, _) => const Text('NOTIFICATIONS'),
    ),
    BartMenuRoute.bottomBar(
      label: 'Settings',
      icon: Icons.settings,
      path: 'settings',
      pageBuilder: (_, _, _) => const Text('SETTINGS'),
    ),
    BartMenuRoute.innerRoute(
      path: settingsInnerPath('reminder'),
      showBottomBar: false,
      pageBuilder: (_, _, _) => BartInnerRouteUrlSync(
        urlPath: settingsInnerPath('reminder'),
        parentTabPath: '/settings',
        child: const Text('REMINDER'),
      ),
    ),
  ];

  Widget buildShell() => MaterialApp(
    home: BartScaffold(
      routesBuilder: shellRoutes,
      navigationKey: kasyShellNavigatorKey,
      initialRoute: 'notifications',
      bottomBar: BartBottomBar.material3(),
      // Mirror BottomMenu._rememberActiveTab so we can assert the shell never
      // strands its remembered tab on Settings.
      onRouteChanged: (route) => activeTabRouteNotifier.value = route.path,
    ),
  );

  tearDown(() {
    // The inner-route helpers use app-lifetime globals; reset them between tests.
    activeTabRouteNotifier.value = null;
    consumeSettingsInnerReturnPath();
  });

  testWidgets(
    'notification → Reminder inner route → back returns to Notifications '
    'and leaves the Settings tab usable',
    (tester) async {
      activeTabRouteNotifier.value = 'notifications';
      await tester.pumpWidget(buildShell());
      await tester.pumpAndSettle();
      expect(find.text('NOTIFICATIONS'), findsOneWidget);

      // Tap a notification deep-linking to Reminders: the app records the return
      // path (Notifications) and pushes the inner route on the shell navigator.
      setSettingsInnerReturnPath('/notifications');
      pushSettingsInnerRoute(kasyShellNavigatorKey.currentContext!, 'reminder');
      await tester.pumpAndSettle();
      expect(find.text('REMINDER'), findsOneWidget);

      // Go back the way the Reminders sub-page does.
      popSettingsInnerRoute(tester.element(find.text('REMINDER')));
      await tester.pumpAndSettle();

      // Back on Notifications, and crucially nothing is left pointing at
      // Settings (the regression left the remembered tab on 'settings').
      expect(find.text('REMINDER'), findsNothing);
      expect(find.text('NOTIFICATIONS'), findsOneWidget);
      expect(activeTabRouteNotifier.value, 'notifications');
    },
  );
}
