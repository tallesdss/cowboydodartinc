import 'package:cowboydodartinc/core/rating/api/rating_api.dart';

class RatingApiFake implements RatingApi {
  DateTime? _lastAskingDate;
  bool _hasRateApp = false;

  @override
  Future<void> saveHasRateApp() async {
    _hasRateApp = true;
  }

  @override
  Future<void> saveLastAskingDate() async {
    _lastAskingDate = DateTime.now();
  }

  @override
  Future<bool> hasRateApp() async {
    return _hasRateApp;
  }

  @override
  Future<DateTime?> lastAskingDate() async {
    return _lastAskingDate;
  }

  @override
  void reset() {
    _lastAskingDate = null;
    _hasRateApp = false;
  }

  @override
  Future<void> showRatingDialog() async {}

  @override
  Future<void> openStoreListing() async {}

  @override
  Future<bool> hasReviewApp() {
    return Future.value(false);
  }

  @override
  Future<DateTime?> lastReviewAskingDate() {
    return Future.value();
  }

  @override
  Future<void> saveHasReviewApp() {
    return Future.value();
  }

  @override
  Future<void> saveLastReviewAskingDate() {
    return Future.value();
  }
}
