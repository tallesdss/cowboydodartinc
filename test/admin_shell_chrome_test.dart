import 'package:cowboydodartinc/components/kasy_app_bar.dart';
import 'package:cowboydodartinc/components/kasy_sidebar.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/states/models/user_state.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_page.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_routes.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_utils.dart';

/// Mirrors the real admin shell: every section (top-level AND the "Ferramentas"
/// sub-screens) is its own branch, so they all share the same chrome and a
/// persistent rail. Branch order/paths match [adminSections] so the shell's
/// currentIndex lines up; the branch bodies are placeholders so the test stays
/// focused on the chrome (sidebar + header), not on each page's providers.
GoRouter _adminTestRouter(String initial) => GoRouter(
  initialLocation: initial,
  routes: [
    GoRoute(path: '/', builder: (_, _) => const SizedBox()),
    StatefulShellRoute.indexedStack(
      builder: (c, s, shell) => AdminShell(navigationShell: shell),
      branches: [
        for (final section in adminSections())
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: section.path,
                builder: (_, _) =>
                    Center(child: Text('section-${section.id.name}')),
              ),
            ],
          ),
      ],
    ),
  ],
);

UserState _adminUser() => UserState(
  user: User.authenticated(
    id: '1',
    email: 'admin@email.com',
    name: 'Admin',
    onboarded: true,
    role: 'admin',
    creationDate: DateTime.now(),
  ),
);

/// The desktop application bar is a [KasyAppBar.application] — same class as the
/// page bar, told apart by [KasyAppBar.isApplication].
final Finder _applicationBar = find.byWidgetPredicate(
  (Widget w) => w is KasyAppBar && w.isApplication,
);

void main() {
  testWidgets(
    'admin section (desktop) renders the real KasySidebar + application bar',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpPage(
        userState: _adminUser(),
        routerConfig: _adminTestRouter('/admin'),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // The console uses the app's real chrome components, not a bespoke copy.
      expect(find.byType(KasySidebar), findsOneWidget);
      expect(_applicationBar, findsOneWidget);
      expect(find.text('section-overview'), findsOneWidget);
    },
  );

  testWidgets(
    'a Ferramentas sub-screen (desktop) is a real section: same rail + header, '
    'submenu open',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpPage(
        userState: _adminUser(),
        routerConfig: _adminTestRouter(adminRouteSendPush),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Tools sub-screens get the SAME chrome as every other section now (the
      // whole point of this change): the persistent rail AND the application bar.
      expect(find.byType(KasySidebar), findsOneWidget);
      expect(_applicationBar, findsOneWidget);
      expect(find.text('section-sendPush'), findsOneWidget);

      // The rail shows the "Ferramentas" group, auto-expanded because one of its
      // children (Send push) is the active screen.
      expect(find.text(t.admin_console.tabs.tools), findsOneWidget);
      expect(
        find.text(t.home.features_page.send_push_title),
        findsWidgets,
      );
    },
  );
}
