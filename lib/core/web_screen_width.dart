/// Reads the physical screen width (logical/CSS px) so the desktop web scale can
/// compensate for high OS display scaling WITHOUT reacting to mere window resize.
///
/// The browser window width (what the layout uses) changes whenever the user
/// drags the window narrower — using it to decide the scale made the whole UI
/// shrink unnecessarily. The *screen* width, on the other hand, only shrinks when
/// the OS display scale goes up (Windows 150%, Mac scaled modes), which is exactly
/// when the compensation is actually wanted.
///
/// Both implementations expose `currentScreenWidth()`; it returns null off the web
/// (where the scaling path is never reached anyway).
library;

export 'web_screen_width_io.dart'
    if (dart.library.js_interop) 'web_screen_width_web.dart';
