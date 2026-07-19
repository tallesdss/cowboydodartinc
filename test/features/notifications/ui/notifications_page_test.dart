import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/states/models/user_state.dart';
import 'package:cowboydodartinc/features/notifications/ui/components/notification_tile.dart';
import 'package:cowboydodartinc/features/notifications/ui/notifications_page.dart';
import 'package:cowboydodartinc/features/notifications/ui/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_utils.dart';

void main() {
  UserState authenticatedUser() => UserState(
    user: User.authenticated(
      id: '1',
      email: 'user@email.com',
      name: 'user name',
      onboarded: true,
      creationDate: DateTime.now().subtract(const Duration(days: 4)),
    ),
  );

  /// The notifications provider delays its first fetch by 500ms (skeleton
  /// window) — advance the clock past it before settling.
  Future<void> settlePastSkeleton(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  group('NotificationsPage — rendering', () {
    testWidgets('renders title and notification tiles', (tester) async {
      await tester.pumpPage(
        userState: authenticatedUser(),
        home: NotificationsPage(),
      );
      await settlePastSkeleton(tester);

      expect(find.byType(NotificationsPage), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(NotificationTile), findsAtLeastNWidgets(3));
    });
  });

  group('NotificationsPage — auto-read behavior', () {
    testWidgets(
      'after 3s on screen, all notifications are marked as read',
      (tester) async {
        await tester.pumpPage(
          userState: authenticatedUser(),
          home: NotificationsPage(),
        );
        // Auto-read fires at 3000ms — give it a little headroom.
        await tester.pump(const Duration(milliseconds: 3100));
        await tester.pumpAndSettle();

        final tiles = tester
            .widgetList<NotificationTileComponent>(
              find.byType(NotificationTileComponent),
            )
            .toList();
        expect(tiles, isNotEmpty);
        for (final tile in tiles) {
          expect(
            tile.notification.readAt,
            isNotNull,
            reason: 'All notifications should be read after auto-read fires',
          );
        }
      },
    );
  });

  group('NotificationsPage — delete all', () {
    testWidgets(
      'delete all button shows, opens confirm dialog, and clears the list',
      (tester) async {
        await tester.pumpPage(
          userState: authenticatedUser(),
          home: NotificationsPage(),
        );
        await settlePastSkeleton(tester);

        // Button is visible when there are notifications.
        final deleteAllButton = find.byKey(const Key('delete_all_button'));
        expect(deleteAllButton, findsOneWidget);

        await tester.tap(deleteAllButton);
        await tester.pumpAndSettle();

        // Confirm dialog appears with destructive action.
        expect(find.text('Delete all notifications?'), findsOneWidget);
        expect(find.text('Yes, delete'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);

        await tester.tap(find.text('Yes, delete'));
        await tester.pumpAndSettle();

        // After deletion, no notification tiles remain.
        expect(find.byType(NotificationTileComponent), findsNothing);
      },
    );

    testWidgets('cancel on confirm dialog keeps notifications intact',
        (tester) async {
      await tester.pumpPage(
        userState: authenticatedUser(),
        home: NotificationsPage(),
      );
      await settlePastSkeleton(tester);

      final countBefore = tester
          .widgetList<NotificationTileComponent>(
            find.byType(NotificationTileComponent),
          )
          .length;
      expect(countBefore, greaterThan(0));

      await tester.tap(find.byKey(const Key('delete_all_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final countAfter = tester
          .widgetList<NotificationTileComponent>(
            find.byType(NotificationTileComponent),
          )
          .length;
      expect(countAfter, countBefore);
    });
  });

  group('NotificationsPage — swipe to delete', () {
    testWidgets(
      'each tile is wrapped in a Dismissible configured for left-swipe',
      (tester) async {
        await tester.pumpPage(
          userState: authenticatedUser(),
          home: NotificationsPage(),
        );
        await settlePastSkeleton(tester);

        final dismissibles = tester
            .widgetList<Dismissible>(find.byType(Dismissible))
            .toList();
        expect(dismissibles, isNotEmpty);
        for (final d in dismissibles) {
          expect(d.direction, DismissDirection.endToStart);
          expect(d.background, isNotNull);
        }
      },
    );
  });
}
