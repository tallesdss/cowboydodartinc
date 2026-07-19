/// Provider-agnostic subscription entitlement (an access right granted to the
/// user by an active subscription).
///
/// This decouples the subscription core from any specific payment SDK:
/// RevenueCat's `EntitlementInfo` (mobile) and a Stripe subscription (web) both
/// map to this kit-owned type. That way a web-only app using the Stripe module
/// compiles and runs without the `purchases_flutter` package.
class Entitlement {
  /// Entitlement identifier (e.g. `premium`).
  final String identifier;

  /// Whether the entitlement is currently active.
  final bool isActive;

  /// Whether the subscription is currently in a free-trial period.
  final bool isInTrial;

  /// Whether the subscription is set to auto-renew.
  final bool willRenew;

  /// Store product id backing this entitlement, when known.
  final String? productId;

  /// When the entitlement expires, when known.
  final DateTime? expirationDate;

  const Entitlement({
    required this.identifier,
    this.isActive = true,
    this.isInTrial = false,
    this.willRenew = false,
    this.productId,
    this.expirationDate,
  });
}
