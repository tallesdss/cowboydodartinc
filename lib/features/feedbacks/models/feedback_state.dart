import 'package:cowboydodartinc/features/feedbacks/models/feature_requests.dart';

class FeedbackPageState {
  List<FeatureRequestVote> userVotes;
  List<FeatureRequest> featureRequests;

  FeedbackPageState({
    required this.featureRequests,
    required this.userVotes,
  });

  FeedbackPageState copyWith({
    List<FeatureRequest>? featureRequests,
    List<FeatureRequestVote>? userVotes,
  }) {
    return FeedbackPageState(
      featureRequests: featureRequests ?? this.featureRequests,
      userVotes: userVotes ?? this.userVotes,
    );
  }

  FeedbackPageState addVote(FeatureRequest feature, int vote) {
    final index =
        featureRequests.indexWhere((element) => element.id == feature.id);
    if (index == -1) {
      return this;
    }
    final newFeature = featureRequests[index].copyWith(
      votes: (feature.votes + vote).clamp(0, double.maxFinite.toInt()),
    );
    final newFeatureRequests = List<FeatureRequest>.from(featureRequests);
    newFeatureRequests[index] = newFeature;
    return copyWith(featureRequests: newFeatureRequests);
  }

  bool hasVoted(FeatureRequest feature) {
    return userVotes.any((element) => element.featureId == feature.id);
  }

  bool canVote() {
    return userVotes.isEmpty;
  }
}
