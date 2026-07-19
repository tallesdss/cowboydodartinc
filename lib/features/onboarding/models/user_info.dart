import 'package:cowboydodartinc/features/onboarding/api/entities/user_info_entity.dart';

enum UserInfoKeys {
  gender,
  age,
}

enum Gender {
  male,
  female,
  none,
}

enum AgeRange {
  age18_30,
  age31_40,
  age41_50,
  age51_60,
  none,
}

abstract class UserInfoDetail<T> {
  final T value;

  UserInfoDetail(this.value);

  

  UserInfoEntity toEntity(String userId);
}

/// ======================================
/// user age info
/// ======================================
class UserAgeInfo extends UserInfoDetail<AgeRange> {
  UserAgeInfo(super.value);

  factory UserAgeInfo.fromEntity(UserInfoEntity entity) {
    final value = AgeRange.values.firstWhere(
      (element) => element.name == entity.value,
      orElse: () => AgeRange.none,
    );
    return UserAgeInfo(value);
  }

  factory UserAgeInfo.fromString(String value) {
    final range = AgeRange.values.firstWhere(
      (element) => element.name == value,
      orElse: () => AgeRange.none,
    );
    return UserAgeInfo(range);
  }

  
  
  @override
  UserInfoEntity toEntity(String userId) => UserInfoEntity(
        key: UserInfoKeys.age.name,
        value: value.name,
        userId: userId,
      );
}

/// ======================================
/// user gender info
/// ======================================
class UserGenderInfo extends UserInfoDetail<Gender> {
  UserGenderInfo(super.value);

  factory UserGenderInfo.fromEntity(UserInfoEntity entity) {
    final value = Gender.values.firstWhere(
      (element) => element.name == entity.value,
      orElse: () => Gender.none,
    );
    return UserGenderInfo(value);
  }

  factory UserGenderInfo.fromString(String value) {
    final gender = Gender.values.firstWhere(
      (element) => element.name == value,
      orElse: () => Gender.none,
    );
    return UserGenderInfo(gender);
  }

  
  
  @override
  UserInfoEntity toEntity(String userId) => UserInfoEntity(
        key: UserInfoKeys.gender.name,
        value: value.name,
        userId: userId,
      );
}
