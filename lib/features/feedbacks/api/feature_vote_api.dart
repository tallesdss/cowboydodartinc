import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowboydodartinc/core/data/api/base_api_exceptions.dart';
import 'package:cowboydodartinc/features/feedbacks/api/entities/feature_vote_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final featureVoteApiProvider = Provider<FeatureVoteApi>(
  (ref) => UserFeatureVoteApi(
    firestore: FirebaseFirestore.instance,
  ),
);

abstract class FeatureVoteApi {
  Future<List<UserFeatureVoteEntity>> getUserVotes(String userId);
  Future<UserFeatureVoteEntity> create(String userId, String featureId);
  Future<void> delete(String featureId, String voteId);
}

const _kFeatureVoteCollection = 'feature_votes';

class UserFeatureVoteApi implements FeatureVoteApi {
  final FirebaseFirestore _firestore;

  UserFeatureVoteApi({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<List<UserFeatureVoteEntity>> getUserVotes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_kFeatureVoteCollection)
          .where('user_uid', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) => UserFeatureVoteEntity.fromJson(doc.data())).toList();
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }

  @override
  Future<UserFeatureVoteEntity> create(String userId, String featureId) async {
    try {
      final docId = '${userId}_$featureId';
      final docRef = _firestore.collection(_kFeatureVoteCollection).doc(docId);
      final vote = UserFeatureVoteEntity(
        id: docId,
        creationDate: DateTime.now(),
        userId: userId,
        featureId: featureId,
      );
      await docRef.set(vote.toJson());
      return vote;
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }

  @override
  Future<void> delete(String featureId, String voteId) async {
    try {
      await _firestore.collection(_kFeatureVoteCollection).doc(voteId).delete();
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(
        code: 0,
        message: '$e: $stacktrace',
      );
    }
  }
}
