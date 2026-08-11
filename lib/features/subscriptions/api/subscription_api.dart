import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowboydodartinc/core/data/api/base_api_exceptions.dart';
import 'package:cowboydodartinc/features/subscriptions/api/entities/subscription_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final subscriptionApiProvider = Provider(
  (ref) => SubscriptionApi(
    firestore: FirebaseFirestore.instance,
  ),
);

/// Subscription API
/// Your backend should handle a webhook from the payment provider
/// to update the subscription status
/// Don't save the subscription status in the app,
/// always do this from a webhook call between you backend and the payment provider
class SubscriptionApi {
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  SubscriptionApi({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  Future<SubscriptionEntity?> get(String userId) async {
    try {
      final doc = await _firestore.collection('subscriptions').doc(userId).get();
      if (!doc.exists) {
        final query = await _firestore
            .collection('subscriptions')
            .where('user_id', isEqualTo: userId)
            .get();
        if (query.docs.isEmpty) {
          return null;
        }
        return SubscriptionEntity.fromJson(query.docs.first.data());
      }
      return SubscriptionEntity.fromJson(doc.data()!);
    } catch (e) {
      _logger.e(e);
      throw ApiError(
        code: 0,
        message: '$e',
      );
    }
  }
}
