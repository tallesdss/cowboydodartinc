import 'package:flutter/foundation.dart';

/// Google's official sample ("test") ad unit ids, per platform and format.
///
/// These are safe to ship and use during development: they always return
/// Google's test creatives and never generate revenue or AdMob policy strikes.
/// The kit falls back to them in non-release builds when no real id is set, so
/// ads work out-of-the-box while you build. ALWAYS configure your real unit ids
/// (via `.env` or `kasy configure`) before shipping a release build, real ids
/// are never used until you set them.
///
/// Source: https://developers.google.com/admob/flutter/test-ads
class AdTestUnitIds {
  const AdTestUnitIds._();

  static String? _byPlatform({required String android, required String ios}) =>
      switch (defaultTargetPlatform) {
        TargetPlatform.android => android,
        TargetPlatform.iOS => ios,
        _ => null,
      };

  static String? get banner => _byPlatform(
    android: 'ca-app-pub-3940256099942544/6300978111',
    ios: 'ca-app-pub-3940256099942544/2934735716',
  );

  static String? get interstitial => _byPlatform(
    android: 'ca-app-pub-3940256099942544/1033173712',
    ios: 'ca-app-pub-3940256099942544/4411468910',
  );

  static String? get rewarded => _byPlatform(
    android: 'ca-app-pub-3940256099942544/5224354917',
    ios: 'ca-app-pub-3940256099942544/1712485313',
  );

  static String? get rewardedInterstitial => _byPlatform(
    android: 'ca-app-pub-3940256099942544/5354046379',
    ios: 'ca-app-pub-3940256099942544/6978759866',
  );
}
