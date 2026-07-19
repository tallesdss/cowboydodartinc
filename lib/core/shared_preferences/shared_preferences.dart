import 'package:cowboydodartinc/core/initializer/onstart_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferencesBuilder>(
  (ref) => SharedPreferencesBuilder(),
);

class SharedPreferencesBuilder implements OnStartService {
  SharedPreferences? _sharedPreferences;

  @override
  Future<void> init() async {
    if (_sharedPreferences != null) {
      return;
    }
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_sharedPreferences == null) {
      throw Exception('SharedPreferences not loaded');
    }
    return _sharedPreferences!;
  }

  /// Save the latest seen update version
  Future<void> setLastSeenUpdateVersion(String version) async {
    await prefs.setString('last_seen_update_version', version);
  }

  /// Get the latest seen update version
  String? getLastSeenUpdateVersion() {
    return prefs.getString('last_seen_update_version');
  }

  /// Save the user's preferred locale language code (e.g. 'en', 'pt', 'es')
  Future<void> setAppLocale(String languageCode) async {
    await prefs.setString('app_locale', languageCode);
  }

  /// Get the saved locale language code, or null if none saved
  String? getAppLocale() {
    return prefs.getString('app_locale');
  }

  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    await prefs.setBool('haptic_feedback_enabled', enabled);
  }

  bool getHapticFeedbackEnabled() {
    return prefs.getBool('haptic_feedback_enabled') ?? true;
  }

  /// Whether the top app bar and bottom menu hide while scrolling down and come
  /// back on scroll up / at the top. Defaults to on.
  Future<void> setHideChromeOnScroll(bool enabled) async {
    await prefs.setBool('hide_chrome_on_scroll', enabled);
  }

  /// Null when the user has never set it — the caller applies the configured
  /// default ([kHideChromeOnScrollDefault]).
  bool? getHideChromeOnScroll() {
    return prefs.getBool('hide_chrome_on_scroll');
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await prefs.setBool('biometric_enabled', enabled);
  }

  bool getBiometricEnabled() {
    return prefs.getBool('biometric_enabled') ?? false;
  }

  /// Whether the user has already been through the one-time onboarding intro.
  ///
  /// Persisted locally so onboarding shows only once per install. Crucially it
  /// survives logout (logout clears the account identity, not the fact that the
  /// user has already seen the intro), so after signing out the user lands on
  /// the sign-in screen instead of being dragged through onboarding again.
  Future<void> setOnboardingCompleted(bool completed) async {
    await prefs.setBool('onboarding_completed', completed);
  }

  bool getOnboardingCompleted() {
    return prefs.getBool('onboarding_completed') ?? false;
  }

  /// How many times the user dismissed the ATT soft prompt without accepting.
  /// Used to back off and eventually stop asking. See [MaybeShowAttPermission].
  int getAttSoftDismissCount() {
    return prefs.getInt('att_soft_dismiss_count') ?? 0;
  }

  Future<void> setAttSoftDismissCount(int count) async {
    await prefs.setInt('att_soft_dismiss_count', count);
  }

  DateTime? getAttSoftLastAskedAt() {
    final millis = prefs.getInt('att_soft_last_asked_at');
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> setAttSoftLastAskedAt(DateTime when) async {
    await prefs.setInt('att_soft_last_asked_at', when.millisecondsSinceEpoch);
  }

  /// Whether we've already fired the one-time native push-permission prompt the
  /// first time the user opened the notifications screen. iOS only ever shows
  /// the native prompt once, so we must never auto-fire it more than once.
  bool getPushAutoRequested() {
    return prefs.getBool('push_auto_requested') ?? false;
  }

  Future<void> setPushAutoRequested(bool value) async {
    await prefs.setBool('push_auto_requested', value);
  }
}
