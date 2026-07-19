import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Debug-only memory of the last visited route.
///
/// A hot **restart** (`R`) during development tears down all in-memory state, so
/// the router boots back at its initial location and you lose the screen you
/// were working on. That hurts most on screens reached with an imperative
/// `push` (e.g. `/components/...`, `/admin/...`): the URL alone can't restore
/// them, and on native there is no URL at all. This remembers the last location
/// in [SharedPreferences] and replays it on the next boot.
///
/// Opening the admin console from Settings uses a separate fixed entry point
/// ([resolveAdminEntryLocation] in `admin_page.dart`), not this memory.
///
/// No-op in release builds: shipped apps always cold-start at `/` and let the
/// auth redirect decide where the user belongs, never resuming onto a stale
/// deep link.
class DevRouteMemory {
  DevRouteMemory._();

  static const String _key = 'dev.last_route';
  static SharedPreferences? _prefs;

  /// Wire up the already-loaded preferences. Call once from `main()`.
  static void attach(SharedPreferences prefs) {
    if (kDebugMode) _prefs = prefs;
  }

  /// The true last location to resume into, or `null` if there is none.
  ///
  /// This is the authority for the resume, on purpose: on web the browser
  /// address bar drifts out of sync with imperative `push`/pop navigation, so
  /// trusting it would resume onto a stale screen. The persisted value comes
  /// from the router's in-memory configuration, which stays correct.
  static String? get lastLocation {
    if (!kDebugMode) return null;
    final String? saved = _prefs?.getString(_key);
    return (saved == null || saved.isEmpty) ? null : saved;
  }

  /// Remember [location] as the place to resume on the next boot.
  static void save(String location) {
    if (!kDebugMode) return;
    _prefs?.setString(_key, location);
  }
}
