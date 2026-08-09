import 'package:cowboydodartinc/core/data/api/image.dart';
import 'package:cowboydodartinc/core/data/api/user_api.dart';
import 'package:cowboydodartinc/core/data/entities/upload_result.dart';
import 'package:cowboydodartinc/core/data/entities/user_entity.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/features/subscriptions/repositories/subscription_repository.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(
    userApi: ref.read(userApiProvider),
    subscriptionRepository: ref.read(subscriptionRepositoryProvider),
  ),
);

class UserRepository {
  final UserApi _userApi;
  final SubscriptionRepository _subscriptionRepository;


  UserRepository({
    required UserApi userApi,
    required SubscriptionRepository subscriptionRepository,
  }) : _subscriptionRepository = subscriptionRepository, _userApi = userApi;

  Future<User?> get(String id) async {
    var userEntity = await _userApi.get(id);
    if (userEntity == null) {
      return null;
    }
    try {
      // We set the user id to RevenueCat BEFORE getting the subscription
      // so that getEntitlements() in the RC fallback uses the correct user
      await _subscriptionRepository.initUser(id);
      // We get the subscription of the user and return it with the user
      final subscription = await _subscriptionRepository.get(id);
      // We update the user locale if it's different from the current locale
      userEntity = await _updateUserLocale(userEntity);
      // We return the user with the subscription
      final user = User.fromEntity(userEntity);
      return switch (user) {
        final AuthenticatedUserData value => value.copyWith(
          subscription: subscription,
        ),
        final AnonymousUserData value => value.copyWith(
          subscription: subscription,
        ),
        _ => null,
      };
    } catch (e) {
      // We catch the error to avoid blocking the user if the subscription is not available
      // On most case it's because you didn't yet setup the RevenueCat api key
      Logger().e('Error while getting subscription');
      // We return the user without the subscription
      return User.fromEntity(userEntity);
    }
  }

  /// Streams the user's role so a change made in the backend console (e.g.
  /// promoting someone to "admin") is picked up at runtime without a restart.
  /// Delegates to the backend-specific [UserApi].
  Stream<String?> watchRole(String id) => _userApi.watchRole(id);

  /// We updates the user avatar
  /// We convert the image to jpeg and resize it to 300px width
  /// and 80% quality to reduce the size of the image
  /// Most of the current phones makes pictures with a width of 3000px.
  /// That can take a lot of time and bandwidth to upload.
  /// We then upload the image
  Stream<UploadResult> saveAvatar({
    required String userId,
    required Uint8List data,
  }) async* {
    final jpgData = await compute(
      imgToJpeg,
      JpegParams(data: data, maxWidth: 450, quality: 80),
    );
    yield* _userApi.updateAvatar(
      userId,
      jpgData,
    );
  }

  Future<void> deleteAvatar({required String userId}) {
    return _userApi.deleteAvatar(userId);
  }

  /// Update the email and optionally the display name of a user in Firestore.
  /// Called after linking a social provider to an anonymous account so that the
  /// Firestore document reflects the authenticated identity.
  Future<void> updateProfile({
    required String userId,
    required String email,
    String? name,
    String? bio,
  }) async {
    final entity = UserEntity(id: userId, email: email, name: name, bio: bio);
    await _userApi.update(entity);
  }

  Future<User> setOnboarded(User user) async {
    final userCpy = switch(user) {
      final AuthenticatedUserData value => value.copyWith(onboarded: true),
      final AnonymousUserData value => value.copyWith(onboarded: true),
      _ => throw Exception('User not found'),
    };

    await _userApi.update(userCpy.toEntity());
    return userCpy;
  }

  /// Apple store and Google play stores requires you to be able to delete a user account on demand
  /// Here is the function to do it.
  Future<void> delete() async {
    await _userApi.deleteMe();
  }

  /// We update the user locale
  /// We update the locale in the user entity
  /// and in the database if it's different from the current locale
  /// We return the updated user entity
  /// -- Locale is not used within the User 
  /// -- The locale is only used for sending notifications to the user with the correct language
  /// -- on app we can use LocaleSettings.instance.currentLocale to get the current locale
  Future<UserEntity> _updateUserLocale(UserEntity userEntity) async {
    final currentLocale = LocaleSettings.instance.currentLocale;
    if (userEntity.locale == currentLocale.languageCode) {
      return userEntity;
    }
    await _userApi.updateLocale(userEntity.id!, currentLocale.languageCode);
    return userEntity.copyWith(locale: currentLocale.languageCode);
  }
}
