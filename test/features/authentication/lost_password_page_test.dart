import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/features/authentication/ui/recover_password_page.dart';
import 'package:cowboydodartinc/features/authentication/ui/widgets/recover_password_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../test_utils.dart';

void main() {
  Future<void> beforeTest(WidgetTester tester) async {
    await tester.pumpPage(
      routerConfig: GoRouter(
        initialLocation: '/recover_password',
        routes: [
          GoRoute(
            name: 'home',
            path: '/',
            builder: (context, state) => const PageFake(Colors.blueAccent),
          ),
          GoRoute(
            name: 'recover_password',
            path: '/recover_password',
            builder: (context, state) => const RecoverPasswordPage(),
          ),
        ],
      ),
    );
  }

  testWidgets(
    'Recover password page => should display email input and submit button',
    (tester) async {
      await beforeTest(tester);

      expect(find.byType(KasyTextField), findsOneWidget);
      expect(find.byType(KasyButton), findsOneWidget);
    },
  );

  testWidgets(
    'fill valid email then send => should show recover password sent page',
    (tester) async {
      await beforeTest(tester);
      const email = 'bruce@wayne.com';

      final emailInputFinder = find.byKey(const Key('email_input'));
      final sendButtonFinder = find.byKey(const Key('recover_button'));

      await tester.enterText(emailInputFinder, email);
      await tester.pump();
      await tester.tap(sendButtonFinder);
      // recover_provider fakes a 1500ms delay after the API call. With
      // disableAnimations on (pumpPage), pumpAndSettle no longer advances
      // time via looping spinners — pump the delay explicitly.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.byType(RecoverPasswordSent), findsOneWidget);
    },
  );
}
