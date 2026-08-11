import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowboydodartinc/core/data/api/base_api_exceptions.dart';
import 'package:cowboydodartinc/features/onboarding/api/entities/user_info_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final userInfosApiProvider = Provider(
  (ref) => UserInfosApi(
    firestore: FirebaseFirestore.instance,
  ),
);

const _kUserInfosCollection = 'user_infos';

class UserInfosApi {
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  UserInfosApi({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  Future<List<UserInfoEntity>> getAll(String userId) async {
    try {
      final res = await _firestore
          .collection(_kUserInfosCollection)
          .where('user_id', isEqualTo: userId)
          .get();
      return res.docs.map((e) => UserInfoEntity.fromJson(e.data())).toList();
    } catch (e) {
      _logger.e(e);
      throw ApiError(
        code: 0,
        message: '$e',
      );
    }
  }

  Future<UserInfoEntity?> getByKey(String userId, String key) async {
    try {
      final res = await _firestore
          .collection(_kUserInfosCollection)
          .where('user_id', isEqualTo: userId)
          .where('info_key', isEqualTo: key)
          .get();
      if (res.docs.isEmpty) {
        return null;
      }
      return UserInfoEntity.fromJson(res.docs.first.data());
    } catch (e) {
      _logger.e(e);
      throw ApiError(
        code: 0,
        message: '$e',
      );
    }
  }

  Future<void> create(String userId, UserInfoEntity info) async {
    try {
      final docId = info.id ?? _firestore.collection(_kUserInfosCollection).doc().id;
      final data = info.toJson()..['id'] = docId;
      await _firestore.collection(_kUserInfosCollection).doc(docId).set(data);
    } catch (e) {
      _logger.e(e);
      throw ApiError(
        code: 0,
        message: '$e',
      );
    }
  }

  Future<void> update(String userId, UserInfoEntity info) async {
    try {
      await _firestore
          .collection(_kUserInfosCollection)
          .doc(info.id)
          .update(info.toJson()..remove('id'));
    } catch (e) {
      _logger.e(e);
      throw ApiError(
        code: 0,
        message: '$e',
      );
    }
  }
}
