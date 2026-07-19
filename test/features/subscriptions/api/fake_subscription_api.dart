import 'package:cowboydodartinc/features/subscriptions/api/entities/subscription_entity.dart';
import 'package:cowboydodartinc/features/subscriptions/api/subscription_api.dart';

class SubscriptionApiFake implements SubscriptionApi {
  SubscriptionEntity? currentFake;

  @override
  Future<SubscriptionEntity?> get(String userId) {
    return Future(() => currentFake);
  }
}
