// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

@freezed
sealed class UserEntity with _$UserEntity {
  const factory UserEntity({
    @JsonKey(includeIfNull: false) String? id,
    @JsonKey(name: 'creation_date') DateTime? creationDate,
    @JsonKey(name: 'last_update_date') DateTime? lastUpdateDate,
    String? email,
    String? name,
    String? bio,
    @JsonKey(name: 'avatar_url') String? avatarPath,
    bool? onboarded,
    String? locale,
    // Access-control role. null/absent = normal user; "admin" unlocks the admin
    // console's server data. Server-only: the `users` guard trigger blocks the
    // client from writing it (set it from the Supabase dashboard / SQL editor).
    String? role,
  }) = UserEntityData;

  const UserEntity._();

  factory UserEntity.fromJson(Map<String, Object?> json) =>
      _$UserEntityFromJson(json);
}

class Credentials {
  // this is the user id (Supabase user UUID)
  final String id;
  // session access token — used internally for session tracking
  // Supabase manages token refresh automatically via SupabaseClient
  final String? token;

  Credentials({
    required this.id,
    required this.token,
  });

  factory Credentials.fromJson(Map<String, Object?> json) {
    if (!json.containsKey('id')) {
      throw Exception('Invalid credentials: id is required');
    }
    return Credentials(
      id: json['id']! as String,
      token: json['token'] as String?,
    );
  }
}
