import 'package:cowboydodartinc/core/web_viewport_scale.dart';
import 'package:flutter_test/flutter_test.dart';

/// Locks the web scaling behaviour so a future change to the constants or the
/// formula can't silently regress it. Two headline rules:
/// - the flat cap applies on EVERY web breakpoint (phone/tablet/desktop) so the
///   whole web app matches native, with no size jump at the desktop breakpoint;
/// - the desktop high-OS-scale compensation must key off the SCREEN width, NOT
///   the window width — merely resizing the browser window must not shrink the
///   UI further; the extra shrink happens only when the screen itself is small.
void main() {
  group('webViewportEffectiveScale', () {
    test('flat cap applies on tablet/phone web too (no jump at the breakpoint)',
        () {
      // Below the desktop breakpoint the scale is the flat cap (not 1.0): the
      // same ~10% web oversize is corrected, and there is no size jump when the
      // window crosses the desktop breakpoint. Compensation is desktop-only, so
      // the screen width is ignored here.
      expect(webViewportEffectiveScale(375), kWebViewportScale); // phone
      expect(webViewportEffectiveScale(900), kWebViewportScale); // tablet
      expect(webViewportEffectiveScale(900, screenWidth: 1470), kWebViewportScale);
      // A small screen does NOT compensate below the breakpoint — that is a
      // desktop-only concern; tablet/phone always take the flat cap.
      expect(webViewportEffectiveScale(900, screenWidth: 300), kWebViewportScale);
      expect(
        webViewportEffectiveScale(kWebViewportScaleDesktopBreakpoint - 1),
        kWebViewportScale,
      );
    });

    test('desktop on a normal/large screen stays at the flat cap', () {
      // Unknown screen (null) → flat cap.
      expect(webViewportEffectiveScale(1280), kWebViewportScale);
      expect(webViewportEffectiveScale(1500), kWebViewportScale);
      // Known large screen → still the flat cap, no compensation.
      expect(webViewportEffectiveScale(1100, screenWidth: 1470), kWebViewportScale);
      expect(webViewportEffectiveScale(1024, screenWidth: 1920), kWebViewportScale);
    });

    test('resizing the window does NOT change the scale (this is the fix)', () {
      // Same screen, different window widths → identical scale. The old formula
      // keyed off the window and shrank here; that was the bug.
      const screen = 1470.0;
      expect(
        webViewportEffectiveScale(1280, screenWidth: screen),
        webViewportEffectiveScale(1050, screenWidth: screen),
      );
      expect(webViewportEffectiveScale(1050, screenWidth: screen), kWebViewportScale);
    });

    test('high OS scale (small SCREEN) compensates below the cap', () {
      // Drop below the cap only because the screen is small — independent of window.
      expect(webViewportEffectiveScale(1024, screenWidth: 1024), closeTo(0.80, 1e-4));
      expect(webViewportEffectiveScale(1097, screenWidth: 1097), closeTo(0.857, 1e-3));
      // Even a wide window on a small (high-scale) screen compensates.
      expect(webViewportEffectiveScale(1280, screenWidth: 1024), closeTo(0.80, 1e-4));
    });

    test('compensation pins the design width to the target on a small screen', () {
      // scale = screen / target, so screen / scale == target (1280).
      const screen = 1024.0;
      final scale = webViewportEffectiveScale(1100, screenWidth: screen);
      expect(screen / scale, closeTo(kWebViewportScaleTargetWidth, 1e-4));
    });

    test('the maxScale override is respected as the cap', () {
      // Use a non-default cap so this genuinely exercises the override.
      expect(webViewportEffectiveScale(1920, screenWidth: 1920, maxScale: 0.8), 0.8);
    });

    test('an absurdly small screen is clamped to the 0.5 floor', () {
      expect(webViewportEffectiveScale(1024, screenWidth: 300), 0.5);
    });
  });
}
