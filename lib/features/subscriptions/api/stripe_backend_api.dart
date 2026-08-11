import 'package:cloud_functions/cloud_functions.dart';
import 'package:cowboydodartinc/features/subscriptions/api/stripe_product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stripeBackendApiProvider = Provider<StripeBackendApi>(
  (ref) => StripeBackendApi(functions: FirebaseFunctions.instance),
);

/// Talks to the Stripe backend (Firebase Cloud Functions). The user identity is
/// taken server-side from the verified JWT — never trusted from the client.
class StripeBackendApi {
  final FirebaseFunctions _functions;

  StripeBackendApi({required FirebaseFunctions functions}) : _functions = functions;

  /// Active recurring prices, mapped to paywall offers.
  Future<List<StripeProduct>> listPrices() async {
    try {
      final callable = _functions.httpsCallable('stripe-list-prices');
      final res = await callable.call();
      final list = (res.data as List).cast<dynamic>();
      return list
          .map((e) => StripeProduct.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      // Retorna lista vazia em vez de quebrar a inicialização do app caso a API não responda
      return [];
    }
  }

  /// Create a hosted Checkout session for [priceId] and return its URL.
  Future<String> createCheckoutSession({
    required String priceId,
    String? successUrl,
    String? cancelUrl,
    String? locale,
    bool? allowPromoCodes,
  }) async {
    final callable = _functions.httpsCallable('stripe-create-checkout-session');
    final res = await callable.call({
      'priceId': priceId,
      if (successUrl != null) 'successUrl': successUrl,
      if (cancelUrl != null) 'cancelUrl': cancelUrl,
      if (locale != null) 'locale': locale,
      if (allowPromoCodes != null) 'allowPromoCodes': allowPromoCodes,
    });
    return (res.data as Map)['url'] as String;
  }

  /// Create a Customer Portal session (manage / cancel) and return its URL.
  /// Pass [planSwitching] = true to auto-configure the portal with
  /// upgrade/downgrade support (no manual Stripe dashboard setup needed).
  Future<String> createPortalSession({
    String? returnUrl,
    bool? planSwitching,
  }) async {
    final callable = _functions.httpsCallable('stripe-create-portal-session');
    final res = await callable.call({
      if (returnUrl != null) 'returnUrl': returnUrl,
      if (planSwitching != null) 'planSwitching': planSwitching,
    });
    return (res.data as Map)['url'] as String;
  }
}
