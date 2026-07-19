import 'package:cowboydodartinc/core/config/features.dart';
import 'package:cowboydodartinc/environments.dart';
import 'package:cowboydodartinc/features/subscriptions/api/inapp_subscription_api.dart';
import 'package:cowboydodartinc/features/subscriptions/api/stripe_backend_api.dart';
import 'package:cowboydodartinc/features/subscriptions/api/stripe_payment_api.dart';
import 'package:cowboydodartinc/features/subscriptions/api/subscription_payment_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selects the subscription payment provider per platform × enabled feature:
/// - web  + Stripe module  -> [StripePaymentApi]
/// - mobile + RevenueCat   -> [RevenueCatPaymentApi]
///
/// The CLI regenerates this file to match the modules a project enabled, so a
/// web-only Stripe app never references RevenueCat (and vice-versa).
final inAppSubscriptionApiProvider = Provider<SubscriptionPaymentApi>((ref) {
  if (kIsWeb && withStripe) {
    return StripePaymentApi(backend: ref.read(stripeBackendApiProvider));
  }
  return RevenueCatPaymentApi(environment: ref.read(environmentProvider));
});
