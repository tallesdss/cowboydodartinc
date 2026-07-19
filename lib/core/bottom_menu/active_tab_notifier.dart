import 'package:flutter/foundation.dart';

/// The bottom-bar tab the user last opened, held at top level so it outlives the
/// [BottomMenu] remount that happens whenever the responsive layout flips
/// small↔large (e.g. toggling the web device preview, which renders the app in a
/// phone-width frame). Persisting it lets the bottom bar restore the tab instead
/// of snapping back to the first one on remount or hard reload (F5).
///
/// It lives in its own dependency-free file so both [BottomMenu] and the auth
/// flow can touch it without an import cycle. Null until the user opens a tab.
final ValueNotifier<String?> activeTabRouteNotifier = ValueNotifier<String?>(
  null,
);

/// Forgets the remembered tab so the next [BottomMenu] mount starts on the
/// default tab (Home). Call this on any session boundary — sign-in and logout —
/// via the single helpers that own those transitions ([goHomeAfterLogin] and
/// [UserStateNotifier.onLogout]); never poke [activeTabRouteNotifier] directly
/// from feature code, so the reset stays in one obvious place.
void forgetActiveTab() => activeTabRouteNotifier.value = null;

/// Records [path] (a bare tab name like `home`/`settings`) as the active tab,
/// synchronously, the instant the user selects it.
///
/// Bart already mirrors route changes into [activeTabRouteNotifier] via its
/// `onRouteChanged` callback, but that path runs in a post-frame callback and
/// is skipped by an early-return when the index looks unchanged. The bottom bar
/// calls this on tap so the remembered tab can never lag behind the tab actually
/// shown. That matters because Bart's `MenuRouter` re-forces the highlighted tab
/// to the remembered route on every rebuild (e.g. a hot reload): if the
/// remembered value were stale, the highlight would jump to it while the content
/// stayed put.
void rememberActiveTab(String path) =>
    activeTabRouteNotifier.value = path.replaceAll('/', '');

/// One-shot flag: the next [BottomMenu] mount must land on Home, ignoring BOTH
/// the remembered tab and the (possibly stale) web URL.
///
/// A fresh login navigates to `/`, but on web the previous session's URL may
/// still read e.g. `/settings`, and [BottomMenu] falls back to that URL when no
/// tab is remembered — so clearing the notifier alone isn't enough to guarantee
/// Home (the URL fallback re-opens the old tab, then Bart rewrites the URL back
/// to it). This flag forces Home for exactly one mount, regardless of timing
/// between the login navigation and the auth page's own redirect. Set by
/// [goHomeAfterLogin]; consumed once by [BottomMenu].
bool _forceHomeOnNextMount = false;

/// Forgets the tab AND forces the next [BottomMenu] mount to Home. Use on a
/// fresh login (see [goHomeAfterLogin]) so the user never lands on whatever tab
/// or URL the previous session left behind.
void requestHomeOnNextMount() {
  activeTabRouteNotifier.value = null;
  _forceHomeOnNextMount = true;
}

/// Reads and clears the [requestHomeOnNextMount] flag. Returns true only for the
/// first [BottomMenu] mount after a login; false otherwise (so web reload / the
/// responsive remount keep restoring the tab normally).
bool consumeForceHomeOnNextMount() {
  if (!_forceHomeOnNextMount) {
    return false;
  }
  _forceHomeOnNextMount = false;
  return true;
}
