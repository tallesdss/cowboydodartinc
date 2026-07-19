import 'package:cowboydodartinc/core/ads/ad_test_units.dart';
import 'package:cowboydodartinc/core/ads/ads_runtime.dart';
import 'package:cowboydodartinc/core/ads/ads_state.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/environments.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ads_provider.g.dart';

/// ---------------------------------------------------------------------------
/// AdMob (Google Mobile Ads) for the kit.
///
/// Supports the four AdMob formats: banner, interstitial, rewarded and
/// rewarded-interstitial. Rewarded formats wire Server-Side Verification (SSV)
/// automatically: the signed-in user's id is forwarded so AdMob calls your
/// backend to grant the reward securely (see `docs/ad_mobs.md`).
///
/// Ads are mobile-only. On web every call is a silent no-op (handled in
/// [ads_runtime.dart]).
///
/// Premium (active subscription) users don't see *auto-served* ads (banner +
/// interstitial). Rewarded formats stay available because the user explicitly
/// opts in to watch them in exchange for a reward.
///
/// ⚠ Before going live you must publish your app and create real ad unit ids in
/// the AdMob console. Until you set them, the kit uses Google's official test
/// ids in non-release builds so ads work while you develop. See the guide in
/// `docs/ad_mobs.md`.
/// ---------------------------------------------------------------------------
enum _AdFormat { banner, interstitial, rewarded, rewardedInterstitial }

@Riverpod(keepAlive: true)
class GoogleAdsNotifier extends _$GoogleAdsNotifier {
  final Logger _logger = Logger();

  Environment get _environment => ref.read(environmentProvider);

  /// Whether ads can run on this platform/build. Ads are mobile-only.
  bool get _adsSupported => !kIsWeb;

  /// Whether the current user is a premium subscriber (ad-free for auto-served
  /// ads). Returns false when the subscriptions module is absent.
  bool get isPremium =>
      ref.read(userStateNotifierProvider).subscription?.isActive ?? false;

  @override
  AdState build() => const AdState();

  /// Initializes the AdMob SDK. Call once at startup. No-op on web.
  Future<void> initialize() async {
    if (!_adsSupported) return;
    await initializeAdsRuntime();
  }

  /// The banner ad unit id to use right now, or null when a banner must not be
  /// shown (web, premium user, or no id configured for the current build).
  /// The banner ad unit id to use, or null when none should show. With
  /// [forceTest] (the in-app ads demo) always returns Google's test id and
  /// ignores premium, so the demo is safe to render even in production.
  String? resolveBannerAdUnitId({bool forceTest = false}) {
    if (!_adsSupported) return null;
    if (forceTest) return _resolveUnitId(_AdFormat.banner, forceTest: true);
    if (isPremium) return null;
    return _resolveUnitId(_AdFormat.banner);
  }

  String? get bannerAdUnitId => resolveBannerAdUnitId();

  /// Shows an interstitial only if at least [secondsSinceLastAd] elapsed since
  /// the last full-screen ad, to avoid spamming the user.
  Future<bool> showInterstitialIfElapsed({
    int secondsSinceLastAd = 50,
    OnAdEvent? onShow,
    OnAdEvent? onDismissed,
    OnAdEvent? onFailed,
  }) {
    if (state.lastAdShown != null &&
        state.timeSinceLastAd.inSeconds < secondsSinceLastAd) {
      return Future.value(false);
    }
    return showInterstitial(
      onShow: onShow,
      onDismissed: onDismissed,
      onFailed: onFailed,
    );
  }

  /// Shows an interstitial ad. Skipped for premium users. Pass [forceTestAd] to
  /// always serve a Google test ad and bypass the premium skip (used by the
  /// in-app ads demo so it's safe to tap in any build).
  Future<bool> showInterstitial({
    OnAdEvent? onShow,
    OnAdEvent? onDismissed,
    OnAdEvent? onFailed,
    bool forceTestAd = false,
  }) {
    if (!_adsSupported || (isPremium && !forceTestAd)) {
      onFailed?.call();
      return Future.value(false);
    }
    final String? adUnitId = _resolveUnitId(
      _AdFormat.interstitial,
      forceTest: forceTestAd,
    );
    if (adUnitId == null) {
      _logger.w('No interstitial ad unit configured');
      onFailed?.call();
      return Future.value(false);
    }
    return showInterstitialRuntime(
      adUnitId: adUnitId,
      onShow: () {
        _markShown();
        onShow?.call();
      },
      onDismissed: onDismissed,
      onFailed: onFailed,
    );
  }

  /// Shows a rewarded ad. Available to all users (including premium) since the
  /// user opts in to earn the reward. The reward is also verified server-side
  /// (SSV) when a backend endpoint is configured.
  Future<bool> showRewarded({
    required OnAdRewarded onReward,
    String? customData,
    OnAdEvent? onShow,
    OnAdEvent? onDismissed,
    OnAdEvent? onFailed,
    bool forceTestAd = false,
  }) {
    if (!_adsSupported) {
      onFailed?.call();
      return Future.value(false);
    }
    final String? adUnitId = _resolveUnitId(
      _AdFormat.rewarded,
      forceTest: forceTestAd,
    );
    if (adUnitId == null) {
      _logger.w('No rewarded ad unit configured');
      onFailed?.call();
      return Future.value(false);
    }
    return showRewardedRuntime(
      adUnitId: adUnitId,
      onReward: onReward,
      userId: _currentUserId,
      customData: customData,
      onShow: () {
        _markShown();
        onShow?.call();
      },
      onDismissed: onDismissed,
      onFailed: onFailed,
    );
  }

  /// Shows a rewarded-interstitial ad. Same audience and SSV behaviour as
  /// [showRewarded].
  Future<bool> showRewardedInterstitial({
    required OnAdRewarded onReward,
    String? customData,
    OnAdEvent? onShow,
    OnAdEvent? onDismissed,
    OnAdEvent? onFailed,
    bool forceTestAd = false,
  }) {
    if (!_adsSupported) {
      onFailed?.call();
      return Future.value(false);
    }
    final String? adUnitId = _resolveUnitId(
      _AdFormat.rewardedInterstitial,
      forceTest: forceTestAd,
    );
    if (adUnitId == null) {
      _logger.w('No rewarded interstitial ad unit configured');
      onFailed?.call();
      return Future.value(false);
    }
    return showRewardedInterstitialRuntime(
      adUnitId: adUnitId,
      onReward: onReward,
      userId: _currentUserId,
      customData: customData,
      onShow: () {
        _markShown();
        onShow?.call();
      },
      onDismissed: onDismissed,
      onFailed: onFailed,
    );
  }

  String? get _currentUserId =>
      ref.read(userStateNotifierProvider).user.idOrNull;

  void _markShown() => state = state.copyWith(lastAdShown: DateTime.now());

  /// Google's official test ad unit id for [format].
  String? _testUnitId(_AdFormat format) => switch (format) {
    _AdFormat.banner => AdTestUnitIds.banner,
    _AdFormat.interstitial => AdTestUnitIds.interstitial,
    _AdFormat.rewarded => AdTestUnitIds.rewarded,
    _AdFormat.rewardedInterstitial => AdTestUnitIds.rewardedInterstitial,
  };

  /// Resolves the effective ad unit id for [format]. With [forceTest] (the
  /// in-app ads demo) always returns Google's test id, ignoring env and build,
  /// so the demo is safe to tap even in production. Otherwise: the real id from
  /// the environment, or Google's test id in non-release builds, or null.
  String? _resolveUnitId(_AdFormat format, {bool forceTest = false}) {
    if (forceTest) return _testUnitId(format);
    final String? configured = switch (format) {
      _AdFormat.banner => _environment.bannerAdUnitId,
      _AdFormat.interstitial => _environment.interstitialAdUnitId,
      _AdFormat.rewarded => _environment.rewardedAdUnitId,
      _AdFormat.rewardedInterstitial =>
        _environment.rewardedInterstitialAdUnitId,
    };
    if (configured != null && configured.isNotEmpty) return configured;
    // No real id set: fall back to Google test ids while developing; never show
    // test ads in a release build.
    if (kReleaseMode) return null;
    return _testUnitId(format);
  }
}
