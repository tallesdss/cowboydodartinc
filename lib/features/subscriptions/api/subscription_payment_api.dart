import 'package:cowboydodartinc/core/data/models/entitlement.dart';
import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/features/subscriptions/api/entities/subscription_entity.dart';

/// Provider-agnostic contract for a subscription payment provider.
///
/// Implemented by `RevenueCatPaymentApi` (mobile: App Store / Play Store) and
/// `StripePaymentApi` (web). The repository depends on this interface only, so
/// the right provider is injected per platform and a project can ship either,
/// both, or (web-only) just Stripe — without pulling the other's SDK.
abstract interface class SubscriptionPaymentApi {
  /// Configure the provider SDK (no-op on platforms it does not support).
  Future<void> init();

  /// Associate the current app user with the provider.
  Future<void> initUser(String userId);

  /// Dissociate the current user from the provider.
  Future<void> disconnectUser();

  /// Available offers shown on the paywall.
  Future<List<SubscriptionProduct>> getOffers(String? offerId);

  /// Start the purchase flow for [product].
  ///
  /// Throws [UserCancelledPurchaseException] when the user cancels.
  Future<void> purchaseProduct(SubscriptionProduct product);

  /// Open the management/cancellation flow for a subscription whose origin is
  /// [origin] (where it was purchased). Implementations only open external
  /// management when allowed on the current platform.
  Future<void> unsubscribe(SubscriptionStore? origin);

  /// Restore / re-sync previous purchases.
  Future<void> restorePurchase();

  /// Currently active entitlements (access rights).
  Future<List<Entitlement>> getPermissions();

  /// Currently active entitlements, or null when none can be determined.
  Future<List<Entitlement>?> getEntitlements();

  /// Resolve a [SubscriptionProduct] from a store product id.
  Future<SubscriptionProduct?> getFromProductId(String productId);

  /// iOS-only: present the offer-code redemption sheet.
  Future<void> presentCodeRedemptionSheet();
}

/// Thrown when the user cancels a purchase flow.
class UserCancelledPurchaseException implements Exception {
  UserCancelledPurchaseException();
}

/// Thrown by [StripePaymentApi.purchaseProduct] on web after the hosted
/// Checkout URL is opened in a new browser tab. The purchase is NOT complete —
/// the caller must poll for subscription activation (via webhook) instead of
/// treating the returned Future as payment confirmation.
class PendingWebCheckoutException implements Exception {
  PendingWebCheckoutException();
}
