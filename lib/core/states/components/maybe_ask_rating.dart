import 'package:cowboydodartinc/core/rating/api/rating_api.dart';
import 'package:cowboydodartinc/core/rating/widgets/review_popup.dart';
import 'package:cowboydodartinc/core/states/components/maybeshow_component.dart';
import 'package:cowboydodartinc/core/states/models/event_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Directly shows the native rating dialog
/// Caution : only use this if you are sure the user wants to rate the app
/// APple API only allows to show the dialog a limited number of times
class MaybeAskForRating implements MaybeShowWithRef {
  MaybeAskForRating();

  @override
  Future<bool> handle(WidgetRef ref, AppEvent event) async {
    if (event is! UserActionEvent) {
      return false;
    }
    if (kDebugMode) {
      Logger().i("Rating skipped : We skip asking for review in debug mode");
      return false;
    }
    await ref.read(ratingApiProvider).showRatingDialog();
    return false;
  }
}

/// CUstomize this to ask for a specific event for review
class MaybeAskForReview implements MaybeShowWithRef {
  MaybeAskForReview();

  @override
  Future<bool> handle(WidgetRef ref, AppEvent event) async {
    if (event is! UserActionEvent) {
      return false;
    }
    if (kDebugMode) {
      Logger().i("Review skipped : We skip asking for review in debug mode");
      return false;
    }
    Logger().d("🧐 maybe ask for review ${event.action}");
    await Future.delayed(const Duration(seconds: 1));
    if (!ref.context.mounted) {
      return false;
    }
    return showReviewDialog(ref.context, ref);
  }
}
