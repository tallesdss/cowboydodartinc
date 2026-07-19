import 'package:bart/bart.dart';
import 'package:bart/bart/router_delegate.dart';
import 'package:cowboydodartinc/core/bottom_menu/active_tab_notifier.dart';
import 'package:cowboydodartinc/core/bottom_menu/bart_inner_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression: Admin → `/settings` → tap Home → rebuild must not re-pin the
/// bottom-bar highlight on Settings.
///
/// Bart's [MenuRouter] constructor re-snaps `indexNotifier` to `initialRoute`
/// on every scaffold rebuild. GoRouter keeps mounting the shell with
/// `initialRoute: 'settings'` after Admin's back-to-app. If a rebuild still
/// passes that stale entry while the nested navigator already shows Home, the
/// pill marks Config on top of the Home feed.
///
/// BottomMenu's fix: after the first frame, pass the *live* tab from
/// [activeTabRouteNotifier] as `initialRoute`. This test locks that contract
/// at the Bart layer (same snap the shell relies on).
void main() {
  List<BartMenuRoute> shellRoutes() => [
    BartMenuRoute.bottomBar(
      label: 'Home',
      icon: Icons.home,
      path: 'home',
      pageBuilder: (_, _, _) => const Text('HOME'),
    ),
    BartMenuRoute.bottomBar(
      label: 'Settings',
      icon: Icons.settings,
      path: 'settings',
      pageBuilder: (_, _, _) => const Text('SETTINGS'),
    ),
  ];

  Widget buildShell(String? initialRoute) => MaterialApp(
    home: BartScaffold(
      routesBuilder: shellRoutes,
      navigationKey: kasyShellNavigatorKey,
      initialRoute: initialRoute,
      bottomBar: BartBottomBar.material3(),
      onRouteChanged: (route) => activeTabRouteNotifier.value = route.path,
    ),
  );

  tearDown(() {
    activeTabRouteNotifier.value = null;
  });

  testWidgets(
    'rebuild with the live remembered tab keeps Home highlighted after '
    'leaving a Settings GoRouter entry',
    (tester) async {
      activeTabRouteNotifier.value = 'settings';
      await tester.pumpWidget(buildShell('settings'));
      await tester.pumpAndSettle();
      expect(find.text('SETTINGS'), findsOneWidget);

      // Switch tabs the way the bottom bar does (nested navigator only;
      // GoRouter would still say /settings).
      rememberActiveTab('home');
      Navigator.of(
        kasyShellNavigatorKey.currentContext!,
      ).pushReplacementNamed('home');
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
      expect(activeTabRouteNotifier.value, 'home');

      // Pre-fix bug: rebuild still passing the GoRouter entry ('settings')
      // while content is Home. Assert the FIXED contract instead: pass the live
      // tab so MenuRouter's constructor snap stays aligned.
      await tester.pumpWidget(buildShell(activeTabRouteNotifier.value));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
      expect(activeTabRouteNotifier.value, 'home');
      final MenuRouter router = MenuRouter.of(
        kasyShellNavigatorKey.currentContext!,
      );
      expect(router.indexNotifier.value, 0);
    },
  );

  testWidgets(
    'rebuild that still passes a stale Settings initialRoute re-pins the '
    'highlight (Bart behaviour BottomMenu must not reproduce)',
    (tester) async {
      activeTabRouteNotifier.value = 'settings';
      await tester.pumpWidget(buildShell('settings'));
      await tester.pumpAndSettle();

      rememberActiveTab('home');
      Navigator.of(
        kasyShellNavigatorKey.currentContext!,
      ).pushReplacementNamed('home');
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);

      // Stale GoRouter entry on rebuild: content stays Home, highlight snaps
      // back to Settings. This is the Bart footgun; keep it documented.
      await tester.pumpWidget(buildShell('settings'));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
      final MenuRouter router = MenuRouter.of(
        kasyShellNavigatorKey.currentContext!,
      );
      expect(router.indexNotifier.value, 1);
    },
  );
}
