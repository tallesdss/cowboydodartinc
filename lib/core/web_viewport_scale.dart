import 'package:cowboydodartinc/core/web_screen_width.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

/// Render scale applied to the app on web, on EVERY breakpoint (phone, tablet,
/// desktop).
///
/// Flutter web renders ~10% larger than an equivalent native/HTML app at the
/// browser's 100% zoom, at any width — so the whole web UI feels oversized.
/// `0.93` walks back ~7% so the web app reads close to the native baseline
/// without the user touching browser zoom — a gentle correction (a bit stronger
/// than the midpoint between full size and a total undo, but still short of
/// fully undoing the 10%) that takes the "oversized" edge off Flutter web
/// without making things feel small (0.90 fully undoes the 10% but reads small
/// on a monitor — one number to nudge). On desktop it also acts
/// as a cap: a
/// screen below the design target (high OS scale) reduces it further to pin the
/// layout (see [kWebViewportScaleTargetWidth]); phone/tablet take the flat cap
/// because those layouts reflow.
///
/// Two things are deliberately NOT scaled, both rendering at native 1.0:
/// - NATIVE itself — the mechanism is gated on [kIsWeb], so iOS/Android/macOS/
///   Windows render at 1.0 and keep respecting the user's system text-size
///   (accessibility).
/// - The in-app DEVICE PREVIEW — it simulates a native device, so it must show
///   the native 1.0 truth; the scale is skipped once the preview frame is up
///   (see main.dart, gated on `webDevicePreviewActiveNotifier`).
const double kWebViewportScale = 0.93;

/// Master on/off for the web render scale — the single knob.
///
/// `true` (default): the web app is rendered ~7% smaller than native via
/// [kWebViewportScale], correcting Flutter web's oversized feel on desktop while
/// native stays at true 1.0. This is a deliberate, web-only density correction
/// (the same technique `responsive_framework`'s autoScale productizes), applied
/// ON TOP OF an already-adaptive layout — not a substitute for it. We verified
/// nothing overflows/crops without it, so it is a density choice, not a crutch.
///
/// `false`: [WebViewportScale.wrap] becomes a true no-op everywhere and the web
/// app renders at native 1.0. There is no hidden coupling, so this one flag is
/// the entire on/off — flip it (or set [kWebViewportScale] to `1.0`) to opt out.
const bool kWebViewportScaleEnabled = true;

/// Design target width (logical px) the desktop shell is laid out against.
///
/// A display with high OS scaling (Windows at 125/150/175%, or a Mac in a scaled
/// "more space"/"larger text" mode) reports a smaller logical SCREEN width, so the
/// flat scale alone left the shell cramped/cropped (the user had to
/// Ctrl-minus). When the screen is below this target the scale drops further
/// (`screenWidth / kWebViewportScaleTargetWidth`) so the full design still fits.
/// Compared against the SCREEN width, not the window width — see
/// [webViewportEffectiveScale].
const double kWebViewportScaleTargetWidth = 1280;

/// Viewport width (logical px) where the desktop shell begins.
///
/// Below it the layout is mobile/tablet (web renders at natural 1.0); at and above
/// it the desktop scale applies. Uses the WINDOW width (the layout follows the
/// window). Tied to the responsive system's desktop breakpoint so they stay in sync.
const double kWebViewportScaleDesktopBreakpoint = 1024; // DeviceType.large.breakpoint

/// Effective web render scale (pure math, unit-testable — see
/// web_viewport_scale_test.dart).
///
/// [windowWidth] is the browser window width. [screenWidth] is the physical
/// screen width in logical px (null = unknown/native).
///
/// On tablet/phone web ([windowWidth] below [kWebViewportScaleDesktopBreakpoint])
/// it returns the flat [maxScale]: those layouts reflow, so they just take the
/// cap that undoes the ~10% web oversize.
///
/// On desktop it returns the flat [maxScale] cap and only drops BELOW it when the
/// SCREEN is small (high OS scale), via `screenWidth / kWebViewportScaleTargetWidth`.
/// Keying the compensation off the screen — not the window — is the whole point:
/// merely resizing the browser window narrower must not shrink the UI further (the
/// layout just reflows); the extra shrink happens only when the screen itself is
/// cramped. With [screenWidth] null it stays at the flat cap.
///
/// This is web-only semantics: native never reaches the scaling path (the
/// [WebViewportScale] widget short-circuits when not on web, via [kIsWeb]), and
/// the device preview is skipped too — both render at native 1.0.
double webViewportEffectiveScale(
  double windowWidth, {
  double? screenWidth,
  double maxScale = kWebViewportScale,
}) {
  // Desktop: keep the high-OS-scale compensation (drop below the cap only when
  // the SCREEN is small, so the full wide desktop design still fits).
  if (windowWidth >= kWebViewportScaleDesktopBreakpoint) {
    final double basis = screenWidth ?? double.infinity;
    return (basis / kWebViewportScaleTargetWidth).clamp(0.5, maxScale);
  }
  // Tablet & phone web: the same ~10% oversize applies, but these layouts reflow,
  // so they take the flat cap (no wide design to fit, no compensation needed).
  return maxScale;
}

/// Renders [child] uniformly scaled by [scale] on web (no-op elsewhere).
///
/// This is a *true* viewport scale, not a visual-only [Transform]: it enlarges
/// the logical [MediaQuery] size by `1/scale` and fits it back into the real
/// viewport with a [FittedBox], so layout, scrolling and hit-testing all stay
/// correct — exactly as if the browser were zoomed out, but baked into the app.
class WebViewportScale extends StatelessWidget {
  final Widget child;
  final double scale;

  const WebViewportScale({
    super.key,
    required this.child,
    this.scale = kWebViewportScale,
  });

  /// Wraps [child] on web when the scale is enabled; returns it untouched
  /// otherwise (every non-web platform, and whenever [kWebViewportScaleEnabled]
  /// is `false`). With the scale off this is a real pass-through — no FittedBox,
  /// no MediaQuery rewrite — so the web app is byte-for-byte native size.
  static Widget wrap(Widget child) => (kIsWeb && kWebViewportScaleEnabled)
      ? WebViewportScale(child: child)
      : child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || scale == 1.0) return child;
    final MediaQueryData mq = MediaQuery.of(context);
    final double effectiveScale = webViewportEffectiveScale(
      mq.size.width,
      screenWidth: currentScreenWidth(),
      maxScale: scale,
    );
    if (effectiveScale == 1.0) return child;
    final Size logicalSize = Size(
      mq.size.width / effectiveScale,
      mq.size.height / effectiveScale,
    );
    return MediaQuery(
      data: mq.copyWith(size: logicalSize),
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: logicalSize.width,
          height: logicalSize.height,
          child: child,
        ),
      ),
    );
  }
}
