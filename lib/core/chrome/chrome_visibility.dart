import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single source of truth for how much of the app's "chrome" — the top
/// [KasyAppBar] and the bottom navigation bar — is revealed while the user
/// scrolls. `1` = fully shown, `0` = fully hidden; both bars interpolate on
/// this value so they slide away and come back together.
///
/// Behaviour (mobile only — tablet/desktop use the sidebar, which never hides):
/// - Scrolling DOWN collapses the chrome glued to the gesture: a fast flick
///   hides it fast, a slow drag hides it gradually.
/// - Scrolling UP slowly keeps it hidden; only a fast fling up brings it back.
/// - Reaching the top always brings it back.
///
/// Exposed as a global singleton (same pattern as `activeTabRouteNotifier` /
/// `kasyContentFocusTarget`) because both the app bar component and the bottom
/// bar factory need the same value without threading it through every page.
class KasyChromeVisibility {
  KasyChromeVisibility._();

  static final KasyChromeVisibility instance = KasyChromeVisibility._();

  /// `1` = chrome fully visible, `0` = fully hidden.
  final ValueNotifier<double> reveal = ValueNotifier<double>(1);

  bool _enabled = true;

  /// Whether the "hide on scroll" feature is on. Off → the chrome stays pinned.
  bool get enabled => _enabled;
  set enabled(bool value) {
    _enabled = value;
    if (!value) reveal.value = 1; // pin the chrome back when turned off
  }

  /// Distance (logical px) over which the chrome fully collapses while scrolling
  /// down. Small, so it feels glued to the gesture.
  static const double _collapseDistance = 90;

  /// An upward scroll delta at least this large in a single update counts as a
  /// fast fling up and snaps the chrome back into view, even mid-page.
  static const double _flingUpThreshold = 14;

  /// Within this many px of the top, the chrome is always fully shown.
  static const double _topThreshold = 6;

  /// Bring the chrome fully back. Call on tab changes so a new screen never
  /// starts with hidden chrome.
  void resetShown() => reveal.value = 1;

  /// Feed every vertical scroll update here (from a [NotificationListener] in
  /// the shell). Updates [reveal] in place.
  void handleScrollUpdate(ScrollUpdateNotification notification) {
    if (!_enabled) return;
    if (notification.metrics.axis != Axis.vertical) return;
    final double delta = notification.scrollDelta ?? 0;
    final double pixels = notification.metrics.pixels;

    if (pixels <= _topThreshold) {
      reveal.value = 1; // at the top → always shown
      return;
    }
    if (delta > 0) {
      // Scrolling down: collapse proportionally — fast scroll (big delta) hides
      // fast, slow scroll hides gradually. Glued to the gesture.
      reveal.value = (reveal.value - delta / _collapseDistance).clamp(0.0, 1.0);
    } else if (delta < 0 && -delta >= _flingUpThreshold) {
      // Scrolling up: a slow drag keeps it hidden; only a fast fling reveals.
      reveal.value = 1;
    }
  }
}

/// Brings the chrome back whenever a route is pushed onto or popped from the
/// root navigator. Tab switches already reset via [BartScaffold.onRouteChanged],
/// but detail screens (feedback, reminders, …) are pushed on the root navigator
/// and bypass that — so without this, returning to a screen that had scrolled
/// its chrome away would leave the app bar and bottom menu stuck hidden.
///
/// Only the chrome is restored; the destination screen keeps its scroll position
/// (the framework preserves it), matching how large apps handle back navigation.
class KasyChromeVisibilityObserver extends NavigatorObserver {
  void _reset() => KasyChromeVisibility.instance.resetShown();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _reset();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _reset();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _reset();
}

// ---------------------------------------------------------------------------
// Configuration — edit these to change the experience your app ships with.
// ---------------------------------------------------------------------------

/// Whether the Settings screen shows the "hide bars when scrolling" toggle to
/// the END USER.
///
/// - `true`  → the toggle appears in Settings → Preferences and the user
///   decides; its initial value is [kHideChromeOnScrollDefault].
/// - `false` → the toggle is hidden and the behaviour is LOCKED to
///   [kHideChromeOnScrollDefault] (the user cannot change it).
const bool kShowHideChromeOnScrollSetting = true;

/// The default behaviour: `true` = the app bar and bottom menu hide while
/// scrolling down (and come back on scroll up / at the top); `false` = they
/// stay fixed. Used as the toggle's initial value when shown, and as the locked
/// value when [kShowHideChromeOnScrollSetting] is `false`.
const bool kHideChromeOnScrollDefault = true;

/// Persisted on/off for the hide-on-scroll behaviour. Wires the effective value
/// into [KasyChromeVisibility] so the bars react immediately.
final hideChromeOnScrollProvider =
    NotifierProvider<HideChromeOnScrollNotifier, bool>(
  HideChromeOnScrollNotifier.new,
);

class HideChromeOnScrollNotifier extends Notifier<bool> {
  @override
  bool build() {
    // When the user toggle is hidden, the behaviour is locked to the default
    // and any previously saved preference is ignored.
    final bool enabled = kShowHideChromeOnScrollSetting
        ? (ref.read(sharedPreferencesProvider).getHideChromeOnScroll() ??
            kHideChromeOnScrollDefault)
        : kHideChromeOnScrollDefault;
    KasyChromeVisibility.instance.enabled = enabled;
    return enabled;
  }

  Future<void> toggle() async {
    final bool next = !state;
    state = next;
    KasyChromeVisibility.instance.enabled = next;
    await ref.read(sharedPreferencesProvider).setHideChromeOnScroll(next);
  }
}
