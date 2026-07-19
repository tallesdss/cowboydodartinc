import 'dart:typed_data';

import 'package:cowboydodartinc/core/data/api/base_api_exceptions.dart';
import 'package:cowboydodartinc/core/data/api/storage_api.dart';
import 'package:cowboydodartinc/core/data/entities/upload_result.dart';
import 'package:cowboydodartinc/core/data/entities/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userApiProvider = Provider<UserApi>(
  (ref) => UserApi(
    client: Supabase.instance.client,
    storageApi: ref.read(storageApiProvider),
  ),
);

class UserApi {
  final SupabaseClient _client;
  final StorageApi _storageApi;

  UserApi({
    required SupabaseClient client,
    required StorageApi storageApi,
  }) : _client = client,_storageApi = storageApi;

  Future<UserEntity?> get(String id) async {
    try {
      final res = await _client
          .from('users') //
          .select()
          .eq('id', id);
      if (res.isEmpty) {
        return null;
      }
      return UserEntity.fromJson(res.first);
    } catch (e, stacktrace) {
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }

  Stream<String?> watchRole(String id) {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((rows) => rows.isEmpty ? null : rows.first['role'] as String?);
  }

  Future<void> update(UserEntity user) async {
    try {
      final data = user.toJson()..removeWhere((_, v) => v == null);
      await _client
          .from('users') //
          .update(data)
          .eq('id', user.id!);
    } catch (e, stacktrace) {
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }

  Future<void> delete(String userId) async {
    try {
      await _client
          .from('users') //
          .delete()
          .eq('id', userId);
    } catch (e, stacktrace) {
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }

  /// Delete the current user account from auth.users.
  /// Uses an Edge Function because auth.admin.deleteUser requires service_role.
  /// When auth.users is deleted, public.users and all related data (devices,
  /// subscriptions, etc.) are removed via ON DELETE CASCADE.
  Future<void> deleteMe() async {
    try {
      final res = await _client.functions.invoke('delete-user-account');
      if (res.status != 200) {
        final msg = res.data is Map && res.data != null
            ? (res.data as Map)['error'] as String? ?? 'Error while deleting user'
            : 'Error while deleting user';
        throw ApiError(code: res.status, message: msg);
      }
    } on ApiError {
      rethrow;
    } catch (e, stacktrace) {
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }

  Future<void> create(UserEntity user) async {
    try {
      await _client
          .from('users') //
          .insert([user.toJson()]);
    } catch (e, stacktrace) {
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }

  Stream<UploadResult> updateAvatar(
    String userId,
    Uint8List data,
  ) async* {
    final task = _storageApi.uploadData(
      data,
      'users/$userId/avatar',
      'thumb.jpg',
      mimeType: 'image/jpg',
    );
    await for (final res in task) {
      if (res case UploadResultCompleted()) {
        await _client
            .from('users') //
            .update({'avatar_url': res.imagePublicUrl}) //
            .eq('id', userId);
      }
      yield res;
    }
  }

  Future<void> deleteAvatar(String userId) async {
    await _storageApi.deleteFile('users/$userId/avatar/thumb.jpg');
    await _client
        .from('users')
        .update({'avatar_url': null})
        .eq('id', userId);
  }

  Future<void> updateLocale(String userId, String locale)  {
    return _client
        .from('users') //
        .update({'locale': locale}) //
        .eq('id', userId);
  }
}
