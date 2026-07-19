import 'package:cowboydodartinc/core/states/translations.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/toast/toast_service.dart';
import 'package:cowboydodartinc/features/feedbacks/models/feature_requests.dart';
import 'package:cowboydodartinc/features/feedbacks/models/feedback_state.dart';
import 'package:cowboydodartinc/features/feedbacks/repositories/feature_request_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_page_notifier.g.dart';

@Riverpod()
class FeedbackPageNotifier extends _$FeedbackPageNotifier {
  bool _isVoting = false;

  @override
  Future<FeedbackPageState> build() async {
    final featureRequestRepository = ref.read(featureRequestRepositoryProvider);
    final userId = ref.read(userStateNotifierProvider).user.idOrNull;

    final userVotes = userId != null
        ? await featureRequestRepository.getUserVotes(userId)
        : <FeatureRequestVote>[];
    final features = await featureRequestRepository.getActiveFeatureRequests();
    features.sort((a, b) => b.votes.compareTo(a.votes));

    return FeedbackPageState(
      featureRequests: features,
      userVotes: userVotes,
    );
  }

  Future<void> vote(FeatureRequest featureRequest) async {
    if (_isVoting) return;
    _isVoting = true;
    final translations = ref.read(translationsProvider).feature_requests;

    if (state.value!.hasVoted(featureRequest)) {
      await _unVote(featureRequest);
      _isVoting = false;
      return;
    }

    final oldState = state.value!;
    final featureRequestRepository = ref.read(featureRequestRepositoryProvider);
    final userState = ref.read(userStateNotifierProvider);

    try {
      final userId = userState.user.idOrNull;
      if (userId == null) return;

      // Optimistic update: count +1 AND mark as voted immediately so
      // hasVoted returns true right away (prevents inverted toggle).
      final optimisticVote = FeatureRequestVote(
        id: '_optimistic',
        featureId: featureRequest.id,
      );
      var newState = state.value!
          .addVote(featureRequest, 1)
          .copyWith(
            userVotes: [...state.value!.userVotes, optimisticVote],
          );
      state = AsyncData(newState);

      final userVote = await featureRequestRepository.vote(
        userId,
        featureRequest,
      );
      // Replace optimistic entry with real vote from server.
      newState = newState.copyWith(userVotes: [
        ...newState.userVotes.where((v) => v.id != '_optimistic'),
        userVote,
      ]);
      state = AsyncData(newState);
      ref.read(toastProvider).success(
            title: translations.vote_success.title,
            text: translations.vote_success.description,
          );
    } catch (e) {
      state = AsyncData(oldState);
      ref.read(toastProvider).error(
            title: translations.vote_error.title,
            text: translations.vote_error.description,
          );
    } finally {
      _isVoting = false;
    }
  }

  Future<void> _unVote(FeatureRequest featureRequest) async {
    final oldState = state.value!;
    final featureRequestRepository = ref.read(featureRequestRepositoryProvider);
    final userState = ref.read(userStateNotifierProvider);

    try {
      final userId = userState.user.idOrNull;
      if (userId == null) return;
      final voteToDelete = oldState.userVotes
          .where((e) => e.featureId == featureRequest.id)
          .firstOrNull;
      if (voteToDelete == null) return;

      var newState = oldState.addVote(featureRequest, -1);
      newState = newState.copyWith(userVotes: [
        ...newState.userVotes.where((e) => e.featureId != featureRequest.id),
      ]);
      state = AsyncData(newState);

      // If the vote was only optimistic (never reached the server), skip delete.
      if (voteToDelete.id == '_optimistic') return;
      await featureRequestRepository.removeVote(userId, voteToDelete);
    } catch (e) {
      debugPrint('Error while unvoting: $e');
      state = AsyncData(oldState);
    }
  }

  Future<void> createFeatureSuggestion({
    required String title,
    required String description,
  }) async {
    final userId = ref.read(userStateNotifierProvider).user.idOrNull;
    if (userId == null) return;
    if (title.isEmpty || description.isEmpty) {
      final tr = ref.read(translationsProvider).feature_requests.add_feature;
      ref.read(toastProvider).error(
            title: tr.error_title,
            text: tr.error_required,
          );
      return;
    }
    if (description.length < 40) {
      final tr = ref.read(translationsProvider).feature_requests.add_feature;
      ref.read(toastProvider).error(
            title: tr.error_title,
            text: tr.error_too_short,
          );
      return;
    }
    final featureRequestRepository = ref.read(featureRequestRepositoryProvider);
    await featureRequestRepository.createNewFeatureSuggestion(
      userId: userId,
      title: title,
      description: description,
    );
  }
}
