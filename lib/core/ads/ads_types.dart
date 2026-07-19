import 'package:flutter/foundation.dart';

/// Shared, platform-agnostic ad types.
///
/// These live in their own file (with no `google_mobile_ads` import) so both
/// the mobile runtime and the web no-op stub can depend on them without pulling
/// the mobile-only SDK into the web build. See [ads_runtime.dart].
/// Generic ad lifecycle callback (shown, dismissed, failed to show/load).
typedef OnAdEvent = void Function();

/// Called when the user earns a reward from a rewarded ad format.
typedef OnAdRewarded = void Function(AdReward reward);

/// The reward granted by a rewarded (or rewarded-interstitial) ad.
///
/// Mirrors AdMob's `RewardItem`. The grant is also delivered to your backend
/// through Server-Side Verification (SSV) when configured, so never hand out
/// anything valuable from the client callback alone, treat it as a hint.
@immutable
class AdReward {
  const AdReward({required this.amount, required this.type});

  /// How many units of the reward (e.g. 10 coins).
  final num amount;

  /// The reward type label configured in the AdMob console (e.g. "coins").
  final String type;

  @override
  String toString() => 'AdReward(amount: $amount, type: $type)';
}

/// Banner sizes exposed by the kit, mapped to the native `AdSize` on mobile.
/// Ignored on web, where banners never render.
enum KasyAdBannerSize {
  banner,
  largeBanner,
  mediumRectangle,
  fullBanner,
  leaderboard,
}
