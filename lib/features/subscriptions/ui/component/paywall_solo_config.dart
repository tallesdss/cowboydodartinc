import 'package:cowboydodartinc/core/data/models/subscription.dart';

/// Developer knobs for the Solo paywall featured plan.
///
/// Solo shows one plan. By default it follows the store list order. Override when
/// you want a specific package (e.g. monthly instead of annual):
///
/// ```dart
/// static const String? featuredSkuId = '\$rc_monthly';
/// // or
/// static const DurationType? preferredDuration = DurationType.month;
/// ```
abstract final class PaywallSoloConfig {
  /// RevenueCat package id or Stripe price id. Takes priority over
  /// [preferredDuration]. Null → fall through to duration or first offer.
  static const String? featuredSkuId = null;

  /// Billing period to pick when [featuredSkuId] is null or not found.
  /// Null → first offer returned by the store.
  static const DurationType? preferredDuration = null;
}

/// Resolves which offer the Solo paywall should highlight and purchase.
SubscriptionProduct? resolvePaywallSoloFeaturedOffer(
  List<SubscriptionProduct> offers,
) {
  if (offers.isEmpty) {
    return null;
  }

  const sku = PaywallSoloConfig.featuredSkuId;
  if (sku != null) {
    for (final offer in offers) {
      if (offer.skuId == sku) {
        return offer;
      }
    }
  }

  const preferred = PaywallSoloConfig.preferredDuration;
  if (preferred != null) {
    for (final offer in offers) {
      if (offer.durationType == preferred) {
        return offer;
      }
    }
  }

  return offers.first;
}
