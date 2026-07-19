import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/rating/api/rating_api.dart';
import 'package:cowboydodartinc/core/rating/models/rating.dart';
import 'package:cowboydodartinc/core/rating/models/review.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Configurable via --dart-define=RATING_DELAY_DAYS=5 (default: 3)
const int _kRatingDelayDays = int.fromEnvironment('RATING_DELAY_DAYS', defaultValue: 3);
// Configurable via --dart-define=RATING_DELAY_AGAIN_DAYS=14 (default: 7)
const int _kRatingDelayAgainDays = int.fromEnvironment('RATING_DELAY_AGAIN_DAYS', defaultValue: 7);

final ratingRepositoryProvider = Provider<RatingRepository>(
  (ref) => RatingRepository(ratingApi: ref.watch(ratingApiProvider)),
);

class RatingRepository {
  final RatingApi _ratingApi;

  RatingRepository({required RatingApi ratingApi}) : _ratingApi = ratingApi;

  Future<Rating> get(User user) async {
    final lastAskingDate = await _ratingApi.lastAskingDate();
    final hasRateApp = await _ratingApi.hasRateApp();
    final creationDate = switch (user) {
      AuthenticatedUserData(:final creationDate) => creationDate,
      AnonymousUserData(:final creationDate) => creationDate,
      _ => null,
    };
    return Rating(
      ratingApi: _ratingApi,
      settings: RatingSettings(
        delayBeforeAsking: const Duration(days: _kRatingDelayDays),
        delayBeforeAskingAgain: const Duration(days: _kRatingDelayAgainDays),
      ),
      lastAskingDate: lastAskingDate,
      userCreationDate: creationDate,
      hasRateApp: hasRateApp,
    );
  }

  /// we will delay the next asking date according to the settings
  Future<void> delay() async {
    await _ratingApi.saveLastAskingDate();
  }

  // we don't really knows if user actually left a comment and rate our app
  // so we will consider that he did it
  // (it's because Apple and google don't want us to know if user rate our app)
  Future<void> rate() async {
    await _ratingApi.saveHasRateApp();
  }

  Future<Review> getReview(User user) async {
    final lastAskingDate = await _ratingApi.lastReviewAskingDate();
    final hasRateApp = await _ratingApi.hasReviewApp();
    final creationDate = switch (user) {
      AuthenticatedUserData(:final creationDate) => creationDate,
      AnonymousUserData(:final creationDate) => creationDate,
      _ => null,
    };
    if (creationDate == null) {
      throw Exception("User creation date is null");
    }
    return Review(
      ratingApi: _ratingApi,
      settings: ReviewSettings(
        delayBeforeAsking: const Duration(days: 3),
        delayBeforeAskingAgain: const Duration(days: 11),
      ),
      lastAskingDate: lastAskingDate,
      userCreationDate: creationDate,
      hasReviewApp: hasRateApp,
    );
  }
}
