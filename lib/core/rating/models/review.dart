import 'package:cowboydodartinc/core/rating/api/rating_api.dart';
import 'package:flutter/material.dart';

class ReviewSettings {
  /// delay before asking for the first time
  final Duration delayBeforeAsking;

  /// delay before asking again
  final Duration delayBeforeAskingAgain;

  /// max delay to ask for a review. If provded and the app is installed for more than this delay, we will not ask for a review
  final Duration? maxDelay;

  ReviewSettings({
    required this.delayBeforeAsking,
    required this.delayBeforeAskingAgain,
    this.maxDelay,
  });
}

class Review {
  final RatingApi _ratingApi;
  final ReviewSettings settings;
  final DateTime? lastAskingDate;
  final DateTime userCreationDate;
  final DateTime _current;
  final bool hasReviewApp;

  Review({
    required this.settings,
    required RatingApi ratingApi,
    required this.lastAskingDate,
    required this.userCreationDate,
    required this.hasReviewApp,
    DateTime? current,
  })  : _ratingApi = ratingApi,
        _current = current ?? DateTime.now();

  bool shouldAsk() {
    if (hasReviewApp) {
      debugPrint("👉 [Review] hasReviewApp");
      return false;
    }
    final appInstallDiff = _current.difference(userCreationDate);
    if (settings.maxDelay != null && appInstallDiff > settings.maxDelay!) {
      debugPrint(
          "👉 [Review] appInstallDiff > maxDelay (${settings.maxDelay})");
      return false;
    }
    if (appInstallDiff < settings.delayBeforeAsking) {
      debugPrint("👉 [Review] appInstallDiff < delayBeforeAsking (${settings.delayBeforeAsking})");
      return false;
    }
    if (lastAskingDate == null) {
      return true;
    }
    final lastAskingDiff = _current.difference(lastAskingDate!);
    debugPrint("👉 [Review] lastAskingDiff ($lastAskingDiff)");
    return lastAskingDiff > settings.delayBeforeAskingAgain;
  }

  Future<void> review() async {
    await _ratingApi.saveHasReviewApp();
    return _ratingApi.openStoreListing();
  }

  Future<void> delay() async {
    await _ratingApi.saveLastReviewAskingDate();
  }
}
