import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

// When set, the web device preview owns the page/browser-chrome background:
// every [syncWebBackgroundColor] call uses THIS brightness instead of the one
// passed in (the app theme). That way the preview's own light/dark toggle drives
// the page behind the device frame — and the hot-restart flash — no matter what
// ThemeMode the app is in. Null = no preview active, the app theme drives as
// usual.
Brightness? _override;

void setWebBackgroundOverride(Brightness? brightness) {
  _override = brightness;
}

void syncWebBackgroundColor(Brightness brightness) {
  final bool dark = (_override ?? brightness) == Brightness.dark;
  // iOS Safari tints its status bar / address bar with the page's background
  // colour once the Flutter canvas covers the viewport (it ignores the
  // theme-color meta there). It samples whichever element fills the top of the
  // viewport — the flutter-view host, not just <body> — so we paint <html>,
  // <body> AND the Flutter host chain with `surface` (the app bar colour). That
  // way the Safari bars match the app bar with no seam, no matter which element
  // Safari reads. The app's own canvas draws over these, so the page background
  // colour only ever shows in the browser chrome.
  final String chromeColor = dark ? '#18181B' : '#FFFFFF';

  // Keep the <html data-theme> attribute (set pre-boot by the index.html script)
  // in sync, so a later reload / hot restart paints the splash + Safari chrome
  // with the theme currently chosen in the app.
  final html = web.document.documentElement as web.HTMLElement?;
  html?.setAttribute('data-theme', dark ? 'dark' : 'light');
  html?.style.setProperty('background-color', chromeColor);
  web.document.body?.style.setProperty('background-color', chromeColor);

  final views = web.document.querySelectorAll(
    'flutter-view, flt-glass-pane, flt-scene-host',
  );
  for (var i = 0; i < views.length; i++) {
    (views.item(i) as web.HTMLElement?)
        ?.style
        .setProperty('background-color', chromeColor);
  }
}
