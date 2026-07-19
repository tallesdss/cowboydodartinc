import 'package:web/web.dart' as web;

/// The screen width in logical (CSS) px. This shrinks when the OS display scale
/// goes up (Windows 150%, Mac scaled modes) but does NOT change when the user
/// merely resizes the browser window — exactly the signal the desktop scale
/// compensation needs. Returns null if the value is unavailable (0/invalid).
double? currentScreenWidth() {
  final int width = web.window.screen.width;
  return width > 0 ? width.toDouble() : null;
}
