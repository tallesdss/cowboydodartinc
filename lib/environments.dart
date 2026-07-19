// ignore_for_file: avoid_redundant_argument_values

import 'package:cowboydodartinc/core/config/app_env.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'environments.freezed.dart';

// URLs for terms of service and privacy policy
const kTermsUrl = '';
const kPrivacyUrl = '';


final environmentProvider = Provider<Environment>(
  (ref) => Environment.fromEnv(),
);

/// The environment of the app.
/// - dev: Development environment
/// - prod: Production environment
/// Feel free to add more environments with your custom properties if needed.
@freezed
sealed class Environment with _$Environment {
  const factory Environment.dev({
    // Name of the environment (dev, prod, ...) just for debug purpose
    required String name,

    /// Url of your backend API / or Supabase URL / or Firebase Functions region
    required String backendUrl,

    /// RevenueCat API key for Android
    /// (only if you want to use in-app purchases with RevenueCat)
    String? revenueCatAndroidApiKey,

    /// RevenueCat API key for iOS
    /// (only if you want to use in-app purchases with RevenueCat)
    String? revenueCatIOSApiKey,

    /// this is used to open the app store page of your app for reviews
    String? appStoreId,

    // ─── Ads (AdMob) ────────────────────────────────────────────────────────
    // Real ad unit ids, per platform and format. Leave null to fall back to
    // Google's test ids in non-release builds (see [AdTestUnitIds]); set the
    // real ids before shipping a release build. Only used if the ads module is
    // enabled.
    String? androidBannerAdUnitId,
    String? iOSBannerAdUnitId,
    String? androidInterstitialAdUnitId,
    String? iOSInterstitialAdUnitId,
    String? androidRewardedAdUnitId,
    String? iOSRewardedAdUnitId,
    String? androidRewardedInterstitialAdUnitId,
    String? iOSRewardedInterstitialAdUnitId,

    /// Environment variable to handle Mixpanel analytics
    /// You can get it from https://mixpanel.com
    String? mixpanelToken,

    /// The default authentication mode of the app (anonymous or authRequired)
    /// See [AuthenticationMode]
    required AuthenticationMode authenticationMode,
  }) = DevEnvironment;

  const factory Environment.prod({
    required String name,

    /// Url of your backend API / or Supabase URL / or Firebase Functions region
    required String backendUrl,

    /// RevenueCat API key for Android
    /// (only if you want to use in-app purchases with RevenueCat)
    String? revenueCatAndroidApiKey,

    /// RevenueCat API key for iOS
    /// (only if you want to use in-app purchases with RevenueCat)
    String? revenueCatIOSApiKey,

    // ─── Ads (AdMob) ────────────────────────────────────────────────────────
    // See the dev factory above for details. Set real ids for release builds.
    String? androidBannerAdUnitId,
    String? iOSBannerAdUnitId,
    String? androidInterstitialAdUnitId,
    String? iOSInterstitialAdUnitId,
    String? androidRewardedAdUnitId,
    String? iOSRewardedAdUnitId,
    String? androidRewardedInterstitialAdUnitId,
    String? iOSRewardedInterstitialAdUnitId,

    /// this is used to open the app store page of your app for reviews
    String? appStoreId,

    /// Sentry is an error reporting tool that will help you to track errors in production
    /// You can get it from https://sentry.io
    /// by default sentry will read the SENTRY_DSN environment variable except for web
    /// you can also setup it directly here. Prefer using environment variables
    String? sentryDsn,

    /// Environment variable to handle Mixpanel analytics
    /// You can get it from https://mixpanel.com
    String? mixpanelToken,

    /// The default authentication mode of the app (anonymous or authRequired)
    /// See [AuthenticationMode]
    required AuthenticationMode authenticationMode,
  }) = ProdEnvironment;

  const Environment._();

  factory Environment.fromEnv() {
    final String environmentInput = AppEnv.env;
    switch (environmentInput) {
      case 'dev':
        return Environment.dev(
          name: 'dev',
          backendUrl: AppEnv.backendUrl,
          appStoreId: '',
          revenueCatAndroidApiKey: AppEnv.rcAndroidApiKey,
          revenueCatIOSApiKey: AppEnv.rcIosApiKey,
          androidBannerAdUnitId: AppEnv.admobAndroidBanner,
          iOSBannerAdUnitId: AppEnv.admobIosBanner,
          androidInterstitialAdUnitId: AppEnv.admobAndroidInterstitial,
          iOSInterstitialAdUnitId: AppEnv.admobIosInterstitial,
          androidRewardedAdUnitId: AppEnv.admobAndroidRewarded,
          iOSRewardedAdUnitId: AppEnv.admobIosRewarded,
          androidRewardedInterstitialAdUnitId:
              AppEnv.admobAndroidRewardedInterstitial,
          iOSRewardedInterstitialAdUnitId: AppEnv.admobIosRewardedInterstitial,
          mixpanelToken: AppEnv.mixpanelToken,
          authenticationMode: AuthenticationMode.anonymous,
        );
      case 'prod':
        return Environment.prod(
          name: 'production',
          backendUrl: AppEnv.backendUrl,
          appStoreId: AppEnv.appStoreId,
          revenueCatAndroidApiKey: AppEnv.rcAndroidApiKey,
          revenueCatIOSApiKey: AppEnv.rcIosApiKey,
          androidBannerAdUnitId: AppEnv.admobAndroidBanner,
          iOSBannerAdUnitId: AppEnv.admobIosBanner,
          androidInterstitialAdUnitId: AppEnv.admobAndroidInterstitial,
          iOSInterstitialAdUnitId: AppEnv.admobIosInterstitial,
          androidRewardedAdUnitId: AppEnv.admobAndroidRewarded,
          iOSRewardedAdUnitId: AppEnv.admobIosRewarded,
          androidRewardedInterstitialAdUnitId:
              AppEnv.admobAndroidRewardedInterstitial,
          iOSRewardedInterstitialAdUnitId: AppEnv.admobIosRewardedInterstitial,
          sentryDsn: AppEnv.sentryDsn,
          mixpanelToken: AppEnv.mixpanelToken,
          authenticationMode: AuthenticationMode.anonymous,
        );
      default:
        throw Exception('Unknown environment $environmentInput');
    }
  }

  bool get isRevenueCatConfigured => switch (defaultTargetPlatform) {
    TargetPlatform.iOS =>
      revenueCatIOSApiKey != null && revenueCatIOSApiKey!.isNotEmpty,
    TargetPlatform.android =>
      revenueCatAndroidApiKey != null && revenueCatAndroidApiKey!.isNotEmpty,
    // RevenueCat is mobile-only; web/desktop are never RevenueCat-configured.
    _ => false,
  };

  // ─── Ads (AdMob) ──────────────────────────────────────────────────────────
  // The ad unit id for the current platform, per format. Ads are mobile-only,
  // so web/desktop always resolve to null. Returns the empty string when no id
  // is configured for the platform (callers treat empty as "not set").
  String? _adUnitFor({required String? android, required String? ios}) =>
      switch (defaultTargetPlatform) {
        TargetPlatform.android => android,
        TargetPlatform.iOS => ios,
        _ => null,
      };

  String? get bannerAdUnitId =>
      _adUnitFor(android: androidBannerAdUnitId, ios: iOSBannerAdUnitId);

  String? get interstitialAdUnitId => _adUnitFor(
    android: androidInterstitialAdUnitId,
    ios: iOSInterstitialAdUnitId,
  );

  String? get rewardedAdUnitId =>
      _adUnitFor(android: androidRewardedAdUnitId, ios: iOSRewardedAdUnitId);

  String? get rewardedInterstitialAdUnitId => _adUnitFor(
    android: androidRewardedInterstitialAdUnitId,
    ios: iOSRewardedInterstitialAdUnitId,
  );

  /// True when at least one real ad unit id is configured for the current
  /// platform (i.e. the app is ready to serve real ads, not just test ids).
  bool get isAdsConfigured => [
    bannerAdUnitId,
    interstitialAdUnitId,
    rewardedAdUnitId,
    rewardedInterstitialAdUnitId,
  ].any((String? id) => id != null && id.isNotEmpty);
}

/// This callback is called when the app is launched.
typedef OnEnvCallback = Future<void> Function();
