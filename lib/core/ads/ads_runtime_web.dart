import 'package:cowboydodartinc/core/ads/ads_types.dart';

/// Web no-op implementation of the ad runtime.
///
/// AdMob (`google_mobile_ads`) is mobile-only, so on web every call is a silent
/// no-op: initialization does nothing and the show* helpers report "not shown"
/// (and invoke [onFailed] so callers can run their fallback). The public surface
/// matches [ads_runtime_io.dart] exactly. See [ads_runtime.dart].
Future<void> initializeAdsRuntime() async {}

Future<bool> showInterstitialRuntime({
  required String adUnitId,
  OnAdEvent? onShow,
  OnAdEvent? onDismissed,
  OnAdEvent? onFailed,
}) async {
  onFailed?.call();
  return false;
}

Future<bool> showRewardedRuntime({
  required String adUnitId,
  required OnAdRewarded onReward,
  String? userId,
  String? customData,
  OnAdEvent? onShow,
  OnAdEvent? onDismissed,
  OnAdEvent? onFailed,
}) async {
  onFailed?.call();
  return false;
}

Future<bool> showRewardedInterstitialRuntime({
  required String adUnitId,
  required OnAdRewarded onReward,
  String? userId,
  String? customData,
  OnAdEvent? onShow,
  OnAdEvent? onDismissed,
  OnAdEvent? onFailed,
}) async {
  onFailed?.call();
  return false;
}
