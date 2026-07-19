import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:flutter_test/flutter_test.dart';

/// Example unit test for the Subscription model.
/// Run with: flutter test test/core/data/models/subscription_test.dart
void main() {
  group('Subscription', () {
    test('Subscription.loading() creates loading state', () {
      const sub = Subscription.loading();
      expect(sub.isActive, isFalse);
      expect(sub.canPurchase, isFalse);
    });

    test('Subscription.inactive() creates inactive state', () {
      const sub = Subscription.inactive(hoursBetweenTwoRequests: 24);
      expect(sub.isActive, isFalse);
      expect(sub.canPurchase, isTrue);
    });

    test('Subscription.active() creates active state', () {
      const sub = Subscription.active();
      expect(sub.isActive, isTrue);
      expect(sub.canPurchase, isFalse);
    });

    test('inactive with lastAskingDate in past should ask for subscription', () {
      final sub = Subscription.inactive(
        hoursBetweenTwoRequests: 24,
        lastAskingDate: DateTime.now().subtract(const Duration(hours: 25)),
      );
      expect(sub.shouldAskForSubscription, isTrue);
    });

    test('inactive with recent lastAskingDate should not ask', () {
      final sub = Subscription.inactive(
        hoursBetweenTwoRequests: 24,
        lastAskingDate: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(sub.shouldAskForSubscription, isFalse);
    });
  });
}
