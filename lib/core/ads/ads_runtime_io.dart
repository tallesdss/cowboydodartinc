import 'dart:async';

import 'package:cowboydodartinc/core/ads/ads_types.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

/// Mobile (Android/iOS) implementation of the ad runtime. Imports the
/// `google_mobile_ads` SDK; never compiled into the web build (see
/// [ads_runtime.dart]).
final Logger _logger = Logger();

/// Initializes the AdMob SDK. Safe to call more than once.
Future<void> initializeAdsRuntime() async {
  await MobileAds.instance.initialize();
}

/// Loads and shows an interstitial. Resolves `true` once it was shown and
/// dismissed, `false` if it failed to load or show.
Future<bool> showInterstitialRuntime({
  required String adUnitId,
  OnAdEvent? onShow,
  OnAdEvent? onDismissed,
  OnAdEvent? onFailed,
}) {
  final Completer<bool> completer = Completer<bool>();
  void finish(bool value) {
    if (!completer.isCompleted) completer.complete(value);
  }

  InterstitialAd.load(
    adUnitId: adUnitId,
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (_) => onShow?.call(),
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            ad.dispose();
            onDismissed?.call();
            finish(true);
          },
          onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
            ad.dispose();
            _logger.w('Interstitial failed to show: $error');
            onFailed?.call();
            finish(false);
          },
        );
        ad.show();
      },
      onAdFailedToLoad: (LoadAdError error) {
        _logger.w('Interstitial failed to load: $error');
        onFailed?.call();
        finish(false);
      },
    ),
  );

  return completer.future;
}

/// Loads and shows a rewarded ad. Wires Server-Side Verification (SSV) when a
/// [userId] (and/or [customData]) is provided, so AdMob calls your backend to
/// grant the reward securely. Resolves `true` if the user earned the reward.
Future<bool> showRewardedRuntime({
  required String adUnitId,
  required OnAdRewarded onReward,
  String? userId,
  String? customData,
  OnAdEvent? onShow,
  OnAdEvent? onDismissed,
  OnAdEvent? onFailed,
}) {
  final Completer<bool> completer = Completer<bool>();
  bool earned = false;
  void finish(bool value) {
    if (!completer.isCompleted) completer.complete(value);
  }

  RewardedAd.load(
    adUnitId: adUnitId,
    request: const AdRequest(),
    rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: (RewardedAd ad) {
        if (userId != null || customData != null) {
          ad.setServerSideOptions(
            ServerSideVerificationOptions(userId: userId, customData: customData),
          );
        }
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (_) => onShow?.call(),
          onAdDismissedFullScreenContent: (RewardedAd ad) {
            ad.dispose();
            onDismissed?.call();
            finish(earned);
          },
          onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
            ad.dispose();
            _logger.w('Rewarded failed to show: $error');
            onFailed?.call();
            finish(false);
          },
        );
        ad.show(
          onUserEarnedReward: (_, RewardItem reward) {
            earned = true;
            onReward(AdReward(amount: reward.amount, type: reward.type));
          },
        );
      },
      onAdFailedToLoad: (LoadAdError error) {
        _logger.w('Rewarded failed to load: $error');
        onFailed?.call();
        finish(false);
      },
    ),
  );

  return completer.future;
}

/// Loads and shows a rewarded-interstitial ad (a full-screen ad that can also
/// grant a reward). Same SSV behaviour as [showRewardedRuntime].
Future<bool> showRewardedInterstitialRuntime({
  required String adUnitId,
  required OnAdRewarded onReward,
  String? userId,
  String? customData,
  OnAdEvent? onShow,
  OnAdEvent? onDismissed,
  OnAdEvent? onFailed,
}) {
  final Completer<bool> completer = Completer<bool>();
  bool earned = false;
  void finish(bool value) {
    if (!completer.isCompleted) completer.complete(value);
  }

  RewardedInterstitialAd.load(
    adUnitId: adUnitId,
    request: const AdRequest(),
    rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
      onAdLoaded: (RewardedInterstitialAd ad) {
        if (userId != null || customData != null) {
          ad.setServerSideOptions(
            ServerSideVerificationOptions(userId: userId, customData: customData),
          );
        }
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (_) => onShow?.call(),
          onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
            ad.dispose();
            onDismissed?.call();
            finish(earned);
          },
          onAdFailedToShowFullScreenContent:
              (RewardedInterstitialAd ad, AdError error) {
            ad.dispose();
            _logger.w('Rewarded interstitial failed to show: $error');
            onFailed?.call();
            finish(false);
          },
        );
        ad.show(
          onUserEarnedReward: (_, RewardItem reward) {
            earned = true;
            onReward(AdReward(amount: reward.amount, type: reward.type));
          },
        );
      },
      onAdFailedToLoad: (LoadAdError error) {
        _logger.w('Rewarded interstitial failed to load: $error');
        onFailed?.call();
        finish(false);
      },
    ),
  );

  return completer.future;
}
