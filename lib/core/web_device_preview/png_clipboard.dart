/// Exports a device-preview screenshot PNG to the clipboard (web), with a
/// download fallback.
///
/// The real implementation uses web-only APIs (`dart:js_interop` + `package:web`)
/// which do NOT compile on the Dart VM / native. Those are isolated in
/// `png_clipboard_web.dart` and pulled in ONLY on web via a conditional import;
/// everywhere else the no-op stub (`png_clipboard_io.dart`) is used. This keeps
/// `flutter test` (VM compile) and native builds green — the web-only code never
/// reaches them.
library;

export 'png_clipboard_io.dart'
    if (dart.library.js_interop) 'png_clipboard_web.dart';
export 'png_export_result.dart';
