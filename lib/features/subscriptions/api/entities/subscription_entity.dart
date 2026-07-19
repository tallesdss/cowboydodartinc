// ignore_for_file: invalid_annotation_target, constant_identifier_names



import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_entity.freezed.dart';
part 'subscription_entity.g.dart';

enum SubscriptionStatus {
  ACTIVE,
  PAUSED,
  EXPIRED,
  LIFETIME,
  CANCELLED,
}

/// Where the subscription was purchased (its origin). `STRIPE` means it was
/// bought on the web via Stripe. Used to route the user to the correct
/// management flow regardless of the device they are currently on.
enum SubscriptionStore {
  PLAY_STORE,
  APPLE_STORE,
  EARLY_BIRD,
  STRIPE,
  unknown,
}


@freezed
sealed class SubscriptionEntity with _$SubscriptionEntity {
  const factory SubscriptionEntity({
    @JsonKey(includeIfNull: false) String? id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'offer_id') String? offerId,
    @JsonKey(name: 'sku_id') required String skuId,
    @JsonKey(name: 'creation_date') DateTime? creationDate,
    @JsonKey(name: 'last_update_date') DateTime? lastUpdateDate,
    @JsonKey(name: 'period_end_date') DateTime? periodEndDate,
    @JsonKey(name: 'trial_end') DateTime? trialEnd,
    @JsonKey(name: 'status') required SubscriptionStatus status,
    @JsonKey(name: 'store', unknownEnumValue: SubscriptionStore.unknown)
    SubscriptionStore? store,
  }) = SubscriptionEntityData;

  factory SubscriptionEntity.fromJson(Map<String, Object?> json) =>
      _$SubscriptionEntityFromJson(json);
}

