import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String _kEnvFromDefine = String.fromEnvironment(
  'ENV',
  defaultValue: 'dev',
);
const String _kBackendUrlFromDefine = String.fromEnvironment(
  'BACKEND_URL',
);
const String _kSupabaseTokenFromDefine = String.fromEnvironment(
  'SUPABASE_TOKEN',
);
const String _kRcAndroidApiKeyFromDefine = String.fromEnvironment(
  'RC_ANDROID_API_KEY',
);
const String _kRcIosApiKeyFromDefine = String.fromEnvironment(
  'RC_IOS_API_KEY',
);
const String _kRcTestKeyFromDefine = String.fromEnvironment(
  'RC_TEST_KEY',
);
const String _kRcIosProdKeyFromDefine = String.fromEnvironment(
  'RC_IOS_PROD_KEY',
);
const String _kRcAndroidProdKeyFromDefine = String.fromEnvironment(
  'RC_ANDROID_PROD_KEY',
);
const String _kMixpanelTokenFromDefine = String.fromEnvironment(
  'MIXPANEL_TOKEN',
);
const String _kSentryDsnFromDefine = String.fromEnvironment(
  'SENTRY_DSN',
);
const String _kAppStoreIdFromDefine = String.fromEnvironment(
  'APP_STORE_ID',
);
const String _kAiChatEndpointFromDefine = String.fromEnvironment(
  'AI_CHAT_ENDPOINT',
);
const String _kAdmobAndroidBannerFromDefine = String.fromEnvironment(
  'ADMOB_ANDROID_BANNER',
);
const String _kAdmobIosBannerFromDefine = String.fromEnvironment(
  'ADMOB_IOS_BANNER',
);
const String _kAdmobAndroidInterstitialFromDefine = String.fromEnvironment(
  'ADMOB_ANDROID_INTERSTITIAL',
);
const String _kAdmobIosInterstitialFromDefine = String.fromEnvironment(
  'ADMOB_IOS_INTERSTITIAL',
);
const String _kAdmobAndroidRewardedFromDefine = String.fromEnvironment(
  'ADMOB_ANDROID_REWARDED',
);
const String _kAdmobIosRewardedFromDefine = String.fromEnvironment(
  'ADMOB_IOS_REWARDED',
);
const String _kAdmobAndroidRewardedInterstitialFromDefine =
    String.fromEnvironment('ADMOB_ANDROID_REWARDED_INTERSTITIAL');
const String _kAdmobIosRewardedInterstitialFromDefine = String.fromEnvironment(
  'ADMOB_IOS_REWARDED_INTERSTITIAL',
);

// ignore: avoid_classes_with_only_static_members
class AppEnv {
  static bool _isLoaded = false;

  static Future<void> load() async {
    if (_isLoaded) return;
    try {
      await dotenv.load();
    } catch (_) {
      // `.env` is optional: fallback to --dart-define works in all commands.
    }
    _isLoaded = true;
  }

  static String get env => _resolve(
    key: 'ENV',
    dartDefineValue: _kEnvFromDefine,
    defaultValue: 'dev',
  );

  static String get backendUrl =>
      _resolve(key: 'BACKEND_URL', dartDefineValue: _kBackendUrlFromDefine);

  static String get supabaseToken => _resolve(
    key: 'SUPABASE_TOKEN',
    dartDefineValue: _kSupabaseTokenFromDefine,
  );

  /// RevenueCat "Test Store" public key (`test_…`). Works only against the
  /// RevenueCat fake store (simulator/emulator); the native SDK rejects it in
  /// release builds.
  static String get rcTestKey =>
      _resolve(key: 'RC_TEST_KEY', dartDefineValue: _kRcTestKeyFromDefine);

  /// RevenueCat production/sandbox iOS key (`appl_…`) — the App Store key used
  /// on physical devices, TestFlight and production.
  static String get rcIosProdKey => _resolve(
    key: 'RC_IOS_PROD_KEY',
    dartDefineValue: _kRcIosProdKeyFromDefine,
  );

  /// RevenueCat production/sandbox Android key (`goog_…`) — the Play Store key
  /// used on physical devices, internal testing and production.
  static String get rcAndroidProdKey => _resolve(
    key: 'RC_ANDROID_PROD_KEY',
    dartDefineValue: _kRcAndroidProdKeyFromDefine,
  );

  /// Effective RevenueCat key for Android, resolved for the current build.
  static String get rcAndroidApiKey => _resolveRcKey(
    explicit: _resolve(
      key: 'RC_ANDROID_API_KEY',
      dartDefineValue: _kRcAndroidApiKeyFromDefine,
    ),
    prodKey: rcAndroidProdKey,
  );

  /// Effective RevenueCat key for iOS, resolved for the current build.
  static String get rcIosApiKey => _resolveRcKey(
    explicit: _resolve(
      key: 'RC_IOS_API_KEY',
      dartDefineValue: _kRcIosApiKeyFromDefine,
    ),
    prodKey: rcIosProdKey,
  );

  static String get mixpanelToken => _resolve(
    key: 'MIXPANEL_TOKEN',
    dartDefineValue: _kMixpanelTokenFromDefine,
  );

  static String get sentryDsn =>
      _resolve(key: 'SENTRY_DSN', dartDefineValue: _kSentryDsnFromDefine);

  static String get appStoreId =>
      _resolve(key: 'APP_STORE_ID', dartDefineValue: _kAppStoreIdFromDefine);

  static String get aiChatEndpoint => _resolve(
    key: 'AI_CHAT_ENDPOINT',
    dartDefineValue: _kAiChatEndpointFromDefine,
  );

  // ─── Ads (AdMob) ad unit ids, per platform and format ─────────────────────
  static String get admobAndroidBanner => _resolve(
    key: 'ADMOB_ANDROID_BANNER',
    dartDefineValue: _kAdmobAndroidBannerFromDefine,
  );

  static String get admobIosBanner => _resolve(
    key: 'ADMOB_IOS_BANNER',
    dartDefineValue: _kAdmobIosBannerFromDefine,
  );

  static String get admobAndroidInterstitial => _resolve(
    key: 'ADMOB_ANDROID_INTERSTITIAL',
    dartDefineValue: _kAdmobAndroidInterstitialFromDefine,
  );

  static String get admobIosInterstitial => _resolve(
    key: 'ADMOB_IOS_INTERSTITIAL',
    dartDefineValue: _kAdmobIosInterstitialFromDefine,
  );

  static String get admobAndroidRewarded => _resolve(
    key: 'ADMOB_ANDROID_REWARDED',
    dartDefineValue: _kAdmobAndroidRewardedFromDefine,
  );

  static String get admobIosRewarded => _resolve(
    key: 'ADMOB_IOS_REWARDED',
    dartDefineValue: _kAdmobIosRewardedFromDefine,
  );

  static String get admobAndroidRewardedInterstitial => _resolve(
    key: 'ADMOB_ANDROID_REWARDED_INTERSTITIAL',
    dartDefineValue: _kAdmobAndroidRewardedInterstitialFromDefine,
  );

  static String get admobIosRewardedInterstitial => _resolve(
    key: 'ADMOB_IOS_REWARDED_INTERSTITIAL',
    dartDefineValue: _kAdmobIosRewardedInterstitialFromDefine,
  );

  static String _resolve({
    required String key,
    required String dartDefineValue,
    String defaultValue = '',
  }) {
    final String? fromDotEnv = dotenv.isInitialized ? dotenv.env[key] : null;
    if (fromDotEnv != null && fromDotEnv.isNotEmpty) return fromDotEnv;
    if (dartDefineValue.isNotEmpty) return dartDefineValue;
    return defaultValue;
  }

  /// Resolve the RevenueCat key that actually works for the current build.
  ///
  /// A Test Store key (`test_…`) only works against RevenueCat's fake store
  /// (simulator/emulator); the native SDK refuses it in release builds and the
  /// paywall comes up empty. So:
  ///
  ///   - Release builds (TestFlight / App Store / Play Store) always use the
  ///     production key (`appl_…` / `goog_…`), read from the bundled `.env`
  ///     (`RC_IOS_PROD_KEY` / `RC_ANDROID_PROD_KEY`). Because `.env` ships as an
  ///     asset, this holds no matter how the IPA/AAB was built (`kasy ios
  ///     release`, Xcode archive, Codemagic, `flutter build …`). An explicit
  ///     non-test key (injected by `kasy run` on a device, or by Codemagic
  ///     variable groups) still wins.
  ///   - Debug builds honor whatever `kasy run` injected (`test_` for
  ///     simulators, the prod key for physical devices) and fall back to the
  ///     Test Store key.
  static String _resolveRcKey({
    required String explicit,
    required String prodKey,
  }) {
    final bool explicitIsTest = explicit.startsWith('test_');
    if (kReleaseMode) {
      if (explicit.isNotEmpty && !explicitIsTest) return explicit;
      if (prodKey.isNotEmpty) return prodKey;
      return explicit;
    }
    if (explicit.isNotEmpty) return explicit;
    final String test = rcTestKey;
    if (test.isNotEmpty) return test;
    return prodKey;
  }
}
