/// Web implementation: synchronous boot-time access to the device-preview
/// state so the very first frame after a hot restart is already correct (no
/// async gap where the app flashes full-screen in its own theme).
///
/// The page-background decision (the colour that shows behind the frame and
/// during the hot-restart flash) is stored under [previewChromeKey] in a small,
/// SELF-OWNED format we control (`dark` / `light` / `off`) — deliberately NOT
/// reading shared_preferences' internal encoding, so a future change to that
/// package can't silently flip the flash back to the wrong colour. The device
/// indices below still read the shared_preferences keys (cosmetic only: at worst
/// a one-frame device swap, never a wrong colour), via [bootPrefInt].
library;

import 'package:web/web.dart' as web;

/// Self-owned key (NOT prefixed `flutter.`) holding the resolved chrome
/// decision. Read by BOTH this file and the pre-boot script in web/index.html;
/// written only by [writePreviewChrome]. Values: 'dark' | 'light' | 'off'.
/// Absent means a fresh debug session (preview defaults ON, light canvas).
const String previewChromeKey = 'kasy.web_preview_chrome';

String? readPreviewChrome() => web.window.localStorage.getItem(previewChromeKey);

void writePreviewChrome(String value) =>
    web.window.localStorage.setItem(previewChromeKey, value);

int? bootPrefInt(String key) {
  // shared_preferences stores under a `flutter.` prefix; ints as a decimal
  // string. Device indices are cosmetic, so this best-effort decode is fine.
  final raw = web.window.localStorage.getItem('flutter.$key');
  return raw == null ? null : int.tryParse(raw);
}
