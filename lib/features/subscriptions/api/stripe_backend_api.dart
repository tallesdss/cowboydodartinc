import 'package:cowboydodartinc/features/subscriptions/api/stripe_product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final stripeBackendApiProvider = Provider<StripeBackendApi>(
  (ref) => StripeBackendApi(client: Supabase.instance.client),
);

/// Talks to the Stripe backend (Supabase Edge Functions). The user identity is
/// taken server-side from the verified JWT — never trusted from the client.
/// This file replaces the Firebase version so the rest of the Stripe client
/// code stays backend-agnostic.
class StripeBackendApi {
  final SupabaseClient _client;

  StripeBackendApi({required SupabaseClient client}) : _client = client;

  /// Active recurring prices, mapped to paywall offers.
  Future<List<StripeProduct>> listPrices() async {
    final res = await _client.functions.invoke('stripe-list-prices');
    final list = (res.data as List).cast<dynamic>();
    return list
        .map((e) => StripeProduct.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Create a hosted Checkout session for [priceId] and return its URL.
  Future<String> createCheckoutSession({
    required String priceId,
    String? successUrl,
    String? cancelUrl,
    String? locale,
    bool? allowPromoCodes,
  }) async {
    final res = await _client.functions.invoke(
      'stripe-create-checkout-session',
      body: {
        'priceId': priceId,
        if (successUrl != null) 'successUrl': successUrl,
        if (cancelUrl != null) 'cancelUrl': cancelUrl,
        if (locale != null) 'locale': locale,
        if (allowPromoCodes != null) 'allowPromoCodes': allowPromoCodes,
      },
    );
    return (res.data as Map)['url'] as String;
  }

  /// Create a Customer Portal session (manage / cancel) and return its URL.
  /// Pass [planSwitching] = true to auto-configure the portal with
  /// upgrade/downgrade support (no manual Stripe dashboard setup needed).
  Future<String> createPortalSession({
    String? returnUrl,
    bool? planSwitching,
  }) async {
    final res = await _client.functions.invoke(
      'stripe-create-portal-session',
      body: {
        if (returnUrl != null) 'returnUrl': returnUrl,
        if (planSwitching != null) 'planSwitching': planSwitching,
      },
    );
    return (res.data as Map)['url'] as String;
  }
}
