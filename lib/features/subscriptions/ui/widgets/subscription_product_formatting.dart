import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

extension SubscriptionProductFormatting on SubscriptionProduct {
  /// Compact billing-period suffix for price pills (e.g. `/month`, `/ano`).
  /// Derived from [durationType], not hardcoded per paywall.
  String pricePeriodSuffix(BuildContext context) {
    final premium = Translations.of(context).premium;
    return switch (durationType) {
      DurationType.week => premium.price_per_week,
      DurationType.month => premium.price_per_month,
      DurationType.threeMonth => premium.price_per_three_month,
      DurationType.sixMonth => premium.price_per_six_month,
      DurationType.year => premium.price_per_year,
      DurationType.lifetime => premium.price_one_time,
    };
  }
}
