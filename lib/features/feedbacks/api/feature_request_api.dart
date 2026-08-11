import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowboydodartinc/core/data/api/base_api_exceptions.dart';
import 'package:cowboydodartinc/features/feedbacks/api/entities/feature_request_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final featureRequestApiProvider = Provider<FeatureRequestApi>(
  (ref) => FirebaseFeatureRequestApi(
    firestore: FirebaseFirestore.instance,
  ),
);

const _kFeatureRequestCollection = 'feature_requests';

abstract class FeatureRequestApi {
  Future<List<FeatureRequestEntity>> getAllActive();
  Future<String> create({
    required String title,
    required String description,
  });
  Future<List<FeatureRequestEntity>> getAll();
  Future<void> setActive(String id, bool active);
  Future<void> updateTexts({
    required String id,
    required Map<String, String> title,
    required Map<String, String> description,
  });
}

class FirebaseFeatureRequestApi implements FeatureRequestApi {
  final FirebaseFirestore _firestore;

  FirebaseFeatureRequestApi({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<List<FeatureRequestEntity>> getAllActive() async {
    try {
      final res = await _firestore
          .collection(_kFeatureRequestCollection)
          .where('active', isEqualTo: true)
          .get();
      return res.docs.map((doc) => FeatureRequestEntity.fromJson(doc.data())).toList();
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  @override
  Future<String> create({
    required String title,
    required String description,
  }) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final multilingual = {'en': title, 'pt': title, 'es': title};
      final docRef = _firestore.collection(_kFeatureRequestCollection).doc();
      final data = {
        'id': docRef.id,
        'creation_date': now,
        'last_update_date': now,
        'title': multilingual,
        'description': {'en': description, 'pt': description, 'es': description},
        'votes': 0,
        'active': false,
      };
      await docRef.set(data);
      return docRef.id;
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  @override
  Future<List<FeatureRequestEntity>> getAll() async {
    try {
      final res = await _firestore
          .collection(_kFeatureRequestCollection)
          .orderBy('votes', descending: true)
          .get();
      return res.docs.map((doc) => FeatureRequestEntity.fromJson(doc.data())).toList();
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  @override
  Future<void> setActive(String id, bool active) async {
    try {
      await _firestore
          .collection(_kFeatureRequestCollection)
          .doc(id)
          .update({'active': active});
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  @override
  Future<void> updateTexts({
    required String id,
    required Map<String, String> title,
    required Map<String, String> description,
  }) async {
    try {
      await _firestore.collection(_kFeatureRequestCollection).doc(id).update({
        'title': title,
        'description': description,
        'last_update_date': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }
}
