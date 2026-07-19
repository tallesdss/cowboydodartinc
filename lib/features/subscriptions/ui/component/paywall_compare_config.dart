import 'package:cowboydodartinc/core/data/models/subscription.dart';

/// Developer knobs for the Compare paywall (multi-plan picker).
///
/// ```dart
/// static const String? monthlySkuId = '\$rc_monthly';
/// static const String? annualSkuId = '\$rc_annual';
/// static const DurationType defaultSelection = DurationType.year;
/// ```
abstract final class PaywallCompareConfig {
  static const String? monthlySkuId = null;
  static const String? annualSkuId = null;

  /// Pre-selected plan when the screen opens.
  static const DurationType defaultSelection = DurationType.year;

  /// Which duration gets the "best offer" badge when present.
  static const DurationType badgeDuration = DurationType.year;
}

SubscriptionProduct? _findBySku(List<SubscriptionProduct> offers, String? sku) {
  if (sku == null) {
    return null;
  }
  for (final offer in offers) {
    if (offer.skuId == sku) {
      return offer;
    }
  }
  return null;
}

SubscriptionProduct? _findByDuration(
  List<SubscriptionProduct> offers,
  DurationType type,
) {
  for (final offer in offers) {
    if (offer.durationType == type) {
      return offer;
    }
  }
  return null;
}

/// Orders offers for side-by-side display (monthly before annual when both exist).
List<SubscriptionProduct> orderPaywallCompareOffers(
  List<SubscriptionProduct> offers,
) {
  if (offers.isEmpty) {
    return const [];
  }

  final used = <String>{};
  final ordered = <SubscriptionProduct>[];

  void add(SubscriptionProduct? offer) {
    if (offer == null || used.contains(offer.skuId)) {
      return;
    }
    ordered.add(offer);
    used.add(offer.skuId);
  }

  add(_findBySku(offers, PaywallCompareConfig.monthlySkuId));
  add(_findBySku(offers, PaywallCompareConfig.annualSkuId));
  add(_findByDuration(offers, DurationType.month));
  add(_findByDuration(offers, DurationType.year));
  add(_findByDuration(offers, DurationType.week));
  add(_findByDuration(offers, DurationType.threeMonth));
  add(_findByDuration(offers, DurationType.sixMonth));
  add(_findByDuration(offers, DurationType.lifetime));

  for (final offer in offers) {
    add(offer);
  }

  return ordered;
}

/// Default selected offer on first load (annual when available).
SubscriptionProduct? resolvePaywallCompareDefaultOffer(
  List<SubscriptionProduct> offers,
) {
  if (offers.isEmpty) {
    return null;
  }

  final ordered = orderPaywallCompareOffers(offers);

  final skuAnnual = _findBySku(ordered, PaywallCompareConfig.annualSkuId);
  if (skuAnnual != null) {
    return skuAnnual;
  }

  final skuMonthly = _findBySku(ordered, PaywallCompareConfig.monthlySkuId);
  if (skuMonthly != null) {
    return skuMonthly;
  }

  final byDefault = _findByDuration(
    ordered,
    PaywallCompareConfig.defaultSelection,
  );
  if (byDefault != null) {
    return byDefault;
  }

  return ordered.first;
}

/// Savings vs paying monthly for 12 months, when both plans exist.
int? comparePlanSavingsPercent({
  required SubscriptionProduct? monthly,
  required SubscriptionProduct? annual,
}) {
  if (monthly == null || annual == null || monthly.price <= 0) {
    return null;
  }
  final annualAsMonthly = annual.price / 12;
  final saved = ((monthly.price - annualAsMonthly) / monthly.price * 100).round();
  if (saved <= 0) {
    return null;
  }
  return saved;
}

SubscriptionProduct? findCompareMonthlyOffer(List<SubscriptionProduct> offers) {
  return _findBySku(offers, PaywallCompareConfig.monthlySkuId) ??
      _findByDuration(offers, DurationType.month);
}

SubscriptionProduct? findCompareAnnualOffer(List<SubscriptionProduct> offers) {
  return _findBySku(offers, PaywallCompareConfig.annualSkuId) ??
      _findByDuration(offers, DurationType.year);
}
