import 'package:cowboydodartinc/core/data/models/subscription.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat-backed [SubscriptionProduct] (mobile: App Store / Play Store).
///
/// Lives in its own file (not in `subscription.dart`) so the subscription core
/// stays free of `purchases_flutter`. Only compiled when the RevenueCat module
/// is enabled.
class RevenueCatProduct implements SubscriptionProduct {
  final Offering revenueCatOffer;
  final Package revenueCatPackage;

  RevenueCatProduct({
    required this.revenueCatOffer,
    required this.revenueCatPackage,
  });

  @override
  String get skuId => revenueCatPackage.identifier;

  @override
  String get id => revenueCatOffer.identifier;

  @override
  String get description => revenueCatOffer.serverDescription;

  @override
  String get label =>
      revenueCatPackage.presentedOfferingContext.offeringIdentifier;

  @override
  double get price => revenueCatPackage.storeProduct.price;

  @override
  String get currency => revenueCatPackage.storeProduct.currencyCode;

  @override
  int? get trialDays {
    final introductory = revenueCatPackage.storeProduct.introductoryPrice;
    if (introductory == null) {
      return null;
    }
    if (introductory.price == 0) {
      final unit = introductory.periodUnit;
      switch (unit) {
        case PeriodUnit.day:
          return introductory.periodNumberOfUnits;
        case PeriodUnit.week:
          return introductory.periodNumberOfUnits * 7;
        case PeriodUnit.month:
          return introductory.periodNumberOfUnits * 30;
        case PeriodUnit.year:
          return introductory.periodNumberOfUnits * 365;
        default:
          return null;
      }
    }
    return null;
  }

  @override
  String? get promotion {
    if (revenueCatOffer.metadata["promotions"] == null) {
      return null;
    }
    final data =
        revenueCatOffer.metadata["promotions"]! as Map<Object?, Object?>;
    final locale = LocaleSettings.currentLocale.languageCode;
    final id = skuId;
    if (data.containsKey(id)) {
      final promotion = data[id]! as Map<Object?, Object?>;
      return promotion[locale]! as String;
    }
    return null;
  }

  @override
  String? get title {
    return revenueCatPackage.storeProduct.title;
  }

  @override
  List<String>? get features {
    final locale = LocaleSettings.currentLocale.languageCode;
    if (revenueCatOffer.metadata[locale] == null) {
      return null;
    }
    final data = revenueCatOffer.metadata[locale]! as Map<Object?, Object?>;
    final featuerObj = data["features"]! as List<Object?>;
    return featuerObj.map((e) => e! as String).toList();
  }

  @override
  String get priceString {
    return revenueCatPackage.storeProduct.priceString;
  }

  @override
  Duration get duration =>
      switch (revenueCatPackage.storeProduct.subscriptionPeriod) {
        'P1W' => const Duration(days: 7),
        'P1M' => const Duration(days: 30),
        'P3M' => const Duration(days: 90),
        'P6M' => const Duration(days: 180),
        'P1Y' => const Duration(days: 365),
        _ => Duration.zero,
      };

  @override
  DurationType get durationType {
    final durationCpy = duration;
    if (durationCpy.inDays == 7) {
      return DurationType.week;
    } else if (durationCpy.inDays == 30) {
      return DurationType.month;
    } else if (durationCpy.inDays == 90) {
      return DurationType.threeMonth;
    } else if (durationCpy.inDays == 180) {
      return DurationType.sixMonth;
    } else if (durationCpy.inDays == 365) {
      return DurationType.year;
    }
    return DurationType.lifetime;
  }

  @override
  String formattedPrice(BuildContext context) {
    final translatedDuration = switch (durationType) {
      DurationType.week => Translations.of(context).premium.duration_weekly,
      DurationType.year => Translations.of(context).premium.duration_annual,
      DurationType.month => Translations.of(context).premium.duration_monthly,
      DurationType.lifetime => Translations.of(
        context,
      ).premium.duration_lifetime,
      _ => "",
    };
    return "${revenueCatPackage.storeProduct.priceString} $translatedDuration";
  }

  @override
  String pricePerMonth(BuildContext context) {
    final translatedDuration = Translations.of(
      context,
    ).premium.duration_monthly;
    if (durationType == DurationType.lifetime) {
      return revenueCatPackage.storeProduct.priceString;
    }
    final pricePerMonth = switch (durationType) {
      DurationType.year => price / 12,
      DurationType.threeMonth => price / 3,
      DurationType.sixMonth => price / 6,
      DurationType.week => (price * 4) / 12,
      _ => 1,
    };
    final pricePerMonthString = pricePerMonth.toStringAsFixed(2);
    final money = revenueCatPackage.storeProduct.currencyCode;
    if (money == "USD") {
      return "\$$pricePerMonthString/$translatedDuration";
    } else if (money == "EUR") {
      return "$pricePerMonthString/$translatedDuration";
    }
    return "$pricePerMonthString $money/$translatedDuration";
  }

  @override
  String? pricePerYear(BuildContext context) {
    final translatedDuration = Translations.of(context).premium.duration_annual;
    if (durationType == DurationType.lifetime) {
      return revenueCatPackage.storeProduct.priceString;
    }
    final pricePerMonth = switch (durationType) {
      DurationType.year => price,
      DurationType.threeMonth => price * 4,
      DurationType.sixMonth => price * 2,
      DurationType.week => (price * 4) * 12,
      _ => 1,
    };
    final pricePerMonthString = pricePerMonth.toStringAsFixed(2);
    final money = revenueCatPackage.storeProduct.currencyCode;
    if (money == "USD") {
      return "\$$pricePerMonthString/$translatedDuration";
    } else if (money == "EUR") {
      return "$pricePerMonthString/$translatedDuration";
    }
    return "$pricePerMonthString $money/$translatedDuration";
  }
}
