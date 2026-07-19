import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Regression test for the Features/Components navigation.
///
/// These detail screens are TOP-LEVEL go_router routes (siblings of the home
/// shell, not children of it), so pushing them renders full-screen on the root
/// navigator: the bottom bar is gone while the detail is open, and it returns
/// intact when the user pops back to the tab.
void main() {
  testWidgets('a top-level route opens full-screen over the bottom bar, '
      'and the bar returns on pop', (tester) async {
    final router = GoRouter(
      routes: [
        // Home shell — owns the bottom bar (like BottomMenu).
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            bottomNavigationBar: const Text('MENU'),
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/features'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        // Detail screen — sibling of '/', so it renders on the root navigator.
        GoRoute(
          path: '/features',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('DETAIL')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    // Home tab: bottom bar visible, no detail.
    expect(find.text('MENU'), findsOneWidget);
    expect(find.text('DETAIL'), findsNothing);

    // Open Features.
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('DETAIL'), findsOneWidget);
    expect(find.text('MENU'), findsNothing); // covered — no bottom bar here

    // Back: the bottom bar is intact.
    Navigator.of(tester.element(find.text('DETAIL'))).maybePop();
    await tester.pumpAndSettle();
    expect(find.text('DETAIL'), findsNothing);
    expect(find.text('MENU'), findsOneWidget);
  });
}
