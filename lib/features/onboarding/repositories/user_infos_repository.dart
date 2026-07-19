import 'package:cowboydodartinc/features/onboarding/api/user_infos_api.dart';
import 'package:cowboydodartinc/features/onboarding/models/user_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userInfosRepositoryProvider = Provider<UserInfosRepository>(
  (ref) => UserInfosRepository(
    userInfosApi: ref.read(userInfosApiProvider),
  ),
);

class UserInfosRepository {
  final UserInfosApi _userInfosApi;

  UserInfosRepository({
    required UserInfosApi userInfosApi,
  }) : _userInfosApi = userInfosApi;

  Future<void> save(String userId, UserInfoDetail info) async {
    
    final entity = info.toEntity(userId);
    final alreadyExistingInfo =
        await _userInfosApi.getByKey(userId, entity.key);
    if (alreadyExistingInfo != null) {
      return _userInfosApi.update(userId, entity.copyWith(id: alreadyExistingInfo.id));
    }

    return _userInfosApi.create(userId, entity);
  }
}
