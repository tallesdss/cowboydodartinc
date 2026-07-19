/// Synchronous read of the device-preview prefs at boot.
///
/// The real implementation uses web-only APIs (`package:web`) that do NOT
/// compile on the Dart VM / native, so it lives in `boot_prefs_web.dart` and is
/// pulled in ONLY on web via a conditional import; everywhere else the no-op
/// stub (`boot_prefs_io.dart`) is used. This keeps `flutter test` (VM compile)
/// and native builds green — the web-only code never reaches them.
///
/// Why synchronous: on a hot restart the global notifiers reset and the normal
/// (async) prefs load leaves a few-frame gap where the preview is OFF, so the
/// app paints full-screen in its own theme — a white/black flash that ignores
/// the preview's own canvas theme. Reading localStorage synchronously in
/// `initState` lets the first frame render the device frame already correct.
library;

export 'boot_prefs_io.dart' if (dart.library.js_interop) 'boot_prefs_web.dart';
