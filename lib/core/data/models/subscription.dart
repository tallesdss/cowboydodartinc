import 'package:cowboydodartinc/core/data/models/entitlement.dart';
import 'package:cowboydodartinc/features/subscriptions/api/entities/subscription_entity.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';

abstract class SubscriptionProduct {
  /// Unique identifier of the product in the store
  String get skuId;

  /// Unique identifier
  String get id;

  /// Description of the subscription from your app
  String get description;

  /// Label of the subscription from the package in revenue cat
  String get label;

  /// Price of the subscription
  double get price;

  /// Duration of the subscription
  Duration get duration;

  /// Promotion of the subscription (configure it in the revenue cat offering json)
  String? get promotion;

  /// Formatted price with duration from the user locale
  String formattedPrice(BuildContext context);

  /// Duration type of the subscription (week, month, year, ...)
  DurationType get durationType;

  /// Title of the offer
  String? get title;

  /// Trial days of the offer
  int? get trialDays;

  /// Features textes of the offer
  List<String>? get features;

  /// Price of the subscription in string
  String get priceString;

  String get currency;

  /// Shows the price per month (only if the duration is not monthly)
  String pricePerMonth(BuildContext context);

  /// Shows the price per year (only if the duration is not yearly)
  String? pricePerYear(BuildContext context);
}

enum DurationType { week, month, threeMonth, sixMonth, year, lifetime }

@freezed
sealed class Subscription with _$Subscription {
  const factory Subscription.active({
    SubscriptionProduct? activeOffer,
    List<Entitlement>? entitlements,
    SubscriptionStore? store,
  }) = SubscriptionStateData;

  const factory Subscription.inactive({
    required int hoursBetweenTwoRequests,
    DateTime? lastAskingDate,
  }) = SubscriptionInactiveStateData;

  const factory Subscription.loading() = SubscriptionStateLoading;

  const Subscription._();

  factory Subscription.fromEntity(
    SubscriptionEntity? entity,
    DateTime? lastAskingDate, {
    int hoursBetweenTwoRequests = 24,
  }) {
    if (entity == null ||
        (entity.periodEndDate != null &&
            entity.periodEndDate!.isBefore(DateTime.now()))) {
      return Subscription.inactive(
        hoursBetweenTwoRequests: hoursBetweenTwoRequests,
        lastAskingDate: lastAskingDate,
      );
    }
    return Subscription.active(store: entity.store);
  }

  bool get canPurchase => switch (this) {
    SubscriptionStateData() => false,
    SubscriptionInactiveStateData() => true,
    SubscriptionStateLoading() => false,
  };

  bool get isActive => switch (this) {
    SubscriptionStateData() => true,
    SubscriptionInactiveStateData() => false,
    SubscriptionStateLoading() => false,
  };

  /// Where the active subscription was purchased (its origin), if known.
  SubscriptionStore? get store => switch (this) {
    SubscriptionStateData(:final store) => store,
    SubscriptionInactiveStateData() => null,
    SubscriptionStateLoading() => null,
  };

  bool get isInTrial => switch (this) {
    SubscriptionStateData(:final entitlements) =>
      entitlements?.firstOrNull?.isInTrial == true,
    SubscriptionInactiveStateData() => false,
    SubscriptionStateLoading() => false,
  };

  bool get hasRenewal => switch (this) {
    SubscriptionStateData(:final entitlements) =>
      entitlements?.firstOrNull?.willRenew == true,
    SubscriptionInactiveStateData() => false,
    SubscriptionStateLoading() => false,
  };

  bool get isLifetime => switch (this) {
    SubscriptionStateData(:final activeOffer) =>
      activeOffer?.durationType == DurationType.lifetime,
    SubscriptionInactiveStateData() => false,
    SubscriptionStateLoading() => false,
  };

  bool get shouldAskForSubscription {
    final now = DateTime.now();
    final (lastAskingDate, hoursBetweenTwoRequests) = switch (this) {
      SubscriptionStateData() => (null, null),
      SubscriptionInactiveStateData(
        :final lastAskingDate,
        :final hoursBetweenTwoRequests,
      ) =>
        (lastAskingDate, hoursBetweenTwoRequests),
      SubscriptionStateLoading() => (null, null),
    };
    if (lastAskingDate == null) {
      return true;
    }
    final diff = now.difference(lastAskingDate);
    return diff.inHours >= hoursBetweenTwoRequests!;
  }
}
