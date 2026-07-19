import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Stripe-backed [SubscriptionProduct] (web). Built from a Stripe Price returned
/// by the `stripe-list-prices` backend function, so the existing paywall UI
/// renders it exactly like a RevenueCat product — no UI changes needed.
class StripeProduct implements SubscriptionProduct {
  /// Stripe Price id (`price_...`) — used as the sku and to start checkout.
  final String priceId;

  /// Stripe Product id (`prod_...`).
  final String productId;

  /// Stripe Product name.
  final String productName;

  final String _description;

  /// Amount in the currency's minor unit (e.g. cents).
  final int unitAmount;

  final String _currency;

  /// Recurring interval reported by Stripe: `day` | `week` | `month` | `year`.
  final String interval;

  /// Recurring interval count (e.g. 3 months).
  final int intervalCount;

  final int? _trialDays;

  final List<String>? _features;

  StripeProduct({
    required this.priceId,
    required this.productId,
    required this.productName,
    required String description,
    required this.unitAmount,
    required String currency,
    required this.interval,
    this.intervalCount = 1,
    int? trialDays,
    List<String>? features,
  })  : _description = description,
        _currency = currency,
        _trialDays = trialDays,
        _features = features;

  factory StripeProduct.fromJson(Map<String, dynamic> json) => StripeProduct(
    priceId: json['priceId'] as String,
    productId: (json['productId'] ?? '') as String,
    productName: (json['productName'] ?? '') as String,
    description: (json['description'] ?? '') as String,
    unitAmount: (json['unitAmount'] as num?)?.toInt() ?? 0,
    currency: (json['currency'] ?? 'usd') as String,
    interval: (json['interval'] ?? 'month') as String,
    intervalCount: (json['intervalCount'] as num?)?.toInt() ?? 1,
    trialDays: (json['trialDays'] as num?)?.toInt(),
    features: (json['features'] as List?)?.map((e) => e.toString()).toList(),
  );

  @override
  String get skuId => priceId;

  @override
  String get id => productId;

  @override
  String get description => _description;

  @override
  String get label => productName;

  @override
  double get price => unitAmount / 100.0;

  @override
  String get currency => _currency.toUpperCase();

  @override
  int? get trialDays => _trialDays;

  @override
  String? get promotion => null;

  @override
  String? get title => productName;

  @override
  List<String>? get features => _features;

  @override
  String get priceString => _formatMoney(price);

  @override
  Duration get duration => switch (durationType) {
    DurationType.week => const Duration(days: 7),
    DurationType.month => const Duration(days: 30),
    DurationType.threeMonth => const Duration(days: 90),
    DurationType.sixMonth => const Duration(days: 180),
    DurationType.year => const Duration(days: 365),
    DurationType.lifetime => Duration.zero,
  };

  @override
  DurationType get durationType {
    switch (interval) {
      case 'week':
        return DurationType.week;
      case 'year':
        return DurationType.year;
      case 'month':
        if (intervalCount == 3) return DurationType.threeMonth;
        if (intervalCount == 6) return DurationType.sixMonth;
        if (intervalCount >= 12) return DurationType.year;
        return DurationType.month;
      default:
        return DurationType.month;
    }
  }

  String _formatMoney(double value, {String? locale}) =>
      NumberFormat.simpleCurrency(locale: locale, name: _currency.toUpperCase())
          .format(value);

  @override
  String formattedPrice(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final translatedDuration = switch (durationType) {
      DurationType.week => Translations.of(context).premium.duration_weekly,
      DurationType.year => Translations.of(context).premium.duration_annual,
      DurationType.month => Translations.of(context).premium.duration_monthly,
      DurationType.lifetime => Translations.of(
        context,
      ).premium.duration_lifetime,
      _ => "",
    };
    return "${_formatMoney(price, locale: locale)} $translatedDuration";
  }

  @override
  String pricePerMonth(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final translatedDuration = Translations.of(
      context,
    ).premium.duration_monthly;
    if (durationType == DurationType.lifetime) {
      return _formatMoney(price, locale: locale);
    }
    final monthly = switch (durationType) {
      DurationType.year => price / 12,
      DurationType.threeMonth => price / 3,
      DurationType.sixMonth => price / 6,
      DurationType.week => (price * 4) / 12,
      _ => price,
    };
    return "${_formatMoney(monthly, locale: locale)}/$translatedDuration";
  }

  @override
  String? pricePerYear(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final translatedDuration = Translations.of(context).premium.duration_annual;
    if (durationType == DurationType.lifetime) {
      return _formatMoney(price, locale: locale);
    }
    final yearly = switch (durationType) {
      DurationType.year => price,
      DurationType.threeMonth => price * 4,
      DurationType.sixMonth => price * 2,
      DurationType.week => (price * 4) * 12,
      _ => price * 12,
    };
    return "${_formatMoney(yearly, locale: locale)}/$translatedDuration";
  }
}
