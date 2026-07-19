import 'dart:async';

import 'package:cowboydodartinc/core/states/events_dispatcher.dart';
import 'package:cowboydodartinc/core/states/models/event_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEventsDispatcher', () {
    late AppEventsDispatcher dispatcher;

    setUp(() {
      dispatcher = AppEventsDispatcher();
    });

    tearDown(() {
      dispatcher.dispose();
    });

    group('publish', () {
      test('no listeners, publish event => event is added to history', () {
        final event = NavigationEvent.create('/home');

        dispatcher.publish(event);

        expect(dispatcher.history, contains(event));
      });

      test(
        'listener subscribed, publish event => listener receives event',
        () async {
          final event = NavigationEvent.create('/home');
          final receivedEvents = <AppEvent>[];

          dispatcher.stream.listen(receivedEvents.add);
          dispatcher.publish(event);

          await Future<void>.delayed(Duration.zero);
          expect(receivedEvents, [event]);
        },
      );

      test(
        'multiple listeners subscribed, publish event => all listeners receive event',
        () async {
          final event = UserActionEvent.create('button_click');
          final receivedEvents1 = <AppEvent>[];
          final receivedEvents2 = <AppEvent>[];

          dispatcher.stream.listen(receivedEvents1.add);
          dispatcher.stream.listen(receivedEvents2.add);
          dispatcher.publish(event);

          await Future<void>.delayed(Duration.zero);
          expect(receivedEvents1, [event]);
          expect(receivedEvents2, [event]);
        },
      );
    });

    group('on<T>', () {
      test(
        'mixed events published, listen to NavigationEvent => only NavigationEvent received',
        () async {
          final navEvent = NavigationEvent.create('/settings');
          final actionEvent = UserActionEvent.create('tap');
          final receivedEvents = <NavigationEvent>[];

          dispatcher.on<NavigationEvent>().listen(receivedEvents.add);
          dispatcher.publish(navEvent);
          dispatcher.publish(actionEvent);

          await Future<void>.delayed(Duration.zero);
          expect(receivedEvents, [navEvent]);
          expect(receivedEvents.length, 1);
        },
      );

      test(
        'mixed events published, listen to UserActionEvent => only UserActionEvent received',
        () async {
          final navEvent = NavigationEvent.create('/profile');
          final actionEvent1 = UserActionEvent.create('swipe');
          final actionEvent2 = UserActionEvent.create('scroll');
          final receivedEvents = <UserActionEvent>[];

          dispatcher.on<UserActionEvent>().listen(receivedEvents.add);
          dispatcher.publish(navEvent);
          dispatcher.publish(actionEvent1);
          dispatcher.publish(actionEvent2);

          await Future<void>.delayed(Duration.zero);
          expect(receivedEvents, [actionEvent1, actionEvent2]);
        },
      );
    });

    group('history', () {
      test(
        'multiple events published => history contains all events in order',
        () {
          final event1 = NavigationEvent.create('/page1');
          final event2 = UserActionEvent.create('click');
          final event3 = NavigationEvent.create('/page2');

          dispatcher.publish(event1);
          dispatcher.publish(event2);
          dispatcher.publish(event3);

          expect(dispatcher.history, [event1, event2, event3]);
        },
      );

      test(
        'history is read-only => modifying returned list does not affect internal history',
        () {
          final event = NavigationEvent.create('/home');
          dispatcher.publish(event);

          final historyCopy = dispatcher.history;
          expect(
            () => historyCopy.add(NavigationEvent.create('/other')),
            throwsUnsupportedError,
          );
        },
      );
    });

    group('maxHistorySize', () {
      test('history exceeds maxHistorySize => oldest events are removed', () {
        final smallDispatcher = AppEventsDispatcher(maxHistorySize: 3);
        addTearDown(smallDispatcher.dispose);

        final event1 = NavigationEvent.create('/page1');
        final event2 = NavigationEvent.create('/page2');
        final event3 = NavigationEvent.create('/page3');
        final event4 = NavigationEvent.create('/page4');

        smallDispatcher.publish(event1);
        smallDispatcher.publish(event2);
        smallDispatcher.publish(event3);
        smallDispatcher.publish(event4);

        expect(smallDispatcher.history.length, 3);
        expect(smallDispatcher.history, [event2, event3, event4]);
        expect(smallDispatcher.history, isNot(contains(event1)));
      });
    });

    group('lastEventOf<T>', () {
      test(
        'mixed events in history, call lastEventOf<NavigationEvent> => returns last NavigationEvent',
        () {
          final navEvent1 = NavigationEvent.create('/page1');
          final actionEvent = UserActionEvent.create('click');
          final navEvent2 = NavigationEvent.create('/page2');
          final actionEvent2 = UserActionEvent.create('scroll');

          dispatcher.publish(navEvent1);
          dispatcher.publish(actionEvent);
          dispatcher.publish(navEvent2);
          dispatcher.publish(actionEvent2);

          final lastNav = dispatcher.lastEventOf<NavigationEvent>();
          expect(lastNav, navEvent2);
        },
      );

      test('no events of requested type in history => returns null', () {
        final actionEvent = UserActionEvent.create('tap');
        dispatcher.publish(actionEvent);

        final lastNav = dispatcher.lastEventOf<NavigationEvent>();
        expect(lastNav, isNull);
      });

      test('empty history, call lastEventOf => returns null', () {
        final lastEvent = dispatcher.lastEventOf<AppEvent>();
        expect(lastEvent, isNull);
      });
    });

    group('eventsOf<T>', () {
      test(
        'mixed events in history, call eventsOf<UserActionEvent> => returns all UserActionEvents',
        () {
          final navEvent = NavigationEvent.create('/home');
          final actionEvent1 = UserActionEvent.create('click');
          final actionEvent2 = UserActionEvent.create('swipe');

          dispatcher.publish(navEvent);
          dispatcher.publish(actionEvent1);
          dispatcher.publish(actionEvent2);

          final userActions = dispatcher.eventsOf<UserActionEvent>();
          expect(userActions, [actionEvent1, actionEvent2]);
        },
      );

      test('no events of requested type => returns empty list', () {
        final navEvent = NavigationEvent.create('/settings');
        dispatcher.publish(navEvent);

        final userActions = dispatcher.eventsOf<UserActionEvent>();
        expect(userActions, isEmpty);
      });
    });

    group('dispose', () {
      test('dispatcher disposed => history is cleared', () {
        final event = NavigationEvent.create('/home');
        dispatcher.publish(event);
        expect(dispatcher.history, isNotEmpty);

        dispatcher.dispose();

        expect(dispatcher.history, isEmpty);
      });

      test('dispatcher disposed => stream is closed', () async {
        final completer = Completer<void>();
        dispatcher.stream.listen((_) {}, onDone: completer.complete);

        dispatcher.dispose();

        await expectLater(completer.future, completes);
      });
    });

    group('broadcast stream behavior', () {
      test(
        'late subscriber joins, publish event => late subscriber receives new events',
        () async {
          // First subscriber
          final earlyEvents = <AppEvent>[];
          dispatcher.stream.listen(earlyEvents.add);

          final event1 = NavigationEvent.create('/page1');
          dispatcher.publish(event1);

          await Future<void>.delayed(Duration.zero);
          expect(earlyEvents, [event1]);

          // Late subscriber joins after first event
          final lateEvents = <AppEvent>[];
          dispatcher.stream.listen(lateEvents.add);

          final event2 = NavigationEvent.create('/page2');
          dispatcher.publish(event2);

          await Future<void>.delayed(Duration.zero);
          // Both subscribers receive new events
          expect(earlyEvents, [event1, event2]);
          expect(lateEvents, [event2]);
        },
      );

      test('late subscriber can access history for missed events', () {
        final event1 = NavigationEvent.create('/page1');
        final event2 = UserActionEvent.create('click');
        dispatcher.publish(event1);
        dispatcher.publish(event2);

        // Late subscriber joins - can access history
        expect(dispatcher.history, [event1, event2]);
        expect(dispatcher.lastEventOf<NavigationEvent>(), event1);
      });
    });
  });
}
