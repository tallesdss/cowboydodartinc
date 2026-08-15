import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowboydodartinc/core/data/api/base_api_exceptions.dart';
import 'package:cowboydodartinc/core/data/api/storage_api.dart';
import 'package:cowboydodartinc/core/data/entities/upload_result.dart';
import 'package:cowboydodartinc/core/data/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userApiProvider = Provider<UserApi>(
  (ref) => UserApi(
    firestore: FirebaseFirestore.instance,
    storageApi: ref.read(storageApiProvider),
  ),
);

class UserApi {
  final FirebaseFirestore _firestore;
  final StorageApi _storageApi;

  UserApi({
    required FirebaseFirestore firestore,
    required StorageApi storageApi,
  }) : _firestore = firestore,_storageApi = storageApi;

  Future<UserEntity?> get(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (!doc.exists) {
        return null;
      }
      return UserEntity.fromJson(doc.data()!);
    } catch (e, stacktrace) {
      Logger().e('Error fetching user $id: $e', stackTrace: stacktrace);
      return null;
    }
  }

  Stream<String?> watchRole(String id) {
    return _firestore
        .collection('users')
        .doc(id)
        .snapshots()
        .map((snapshot) => snapshot.data()?['role'] as String?);
  }

  Future<void> update(UserEntity user) async {
    try {
      final data = user.toJson()..removeWhere((_, v) => v == null);
      await _firestore.collection('users').doc(user.id).update(data);
    } catch (e, stacktrace) {
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }

  Future<void> delete(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e, stacktrace) {
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }

  /// Delete the current user account from auth and database.
  Future<void> deleteMe() async {
    try {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        await delete(userId);
        await user.delete();
      }
    } catch (e, stacktrace) {
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }

  Future<void> create(UserEntity user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
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
        await _firestore
            .collection('users')
            .doc(userId)
            .update({'avatar_url': res.imagePublicUrl});
      }
      yield res;
    }
  }

  Future<void> deleteAvatar(String userId) async {
    await _storageApi.deleteFile('users/$userId/avatar/thumb.jpg');
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'avatar_url': null});
  }

  Future<void> updateLocale(String userId, String locale)  {
    return _firestore
        .collection('users')
        .doc(userId)
        .update({'locale': locale});
  }
}
