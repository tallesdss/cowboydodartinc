import 'package:cowboydodartinc/core/bottom_menu/active_tab_notifier.dart';
import 'package:cowboydodartinc/core/bottom_menu/web_url.dart';
import 'package:cowboydodartinc/router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sends a freshly-authenticated user to Home — the single source of truth for
/// post-login navigation.
///
/// EVERY sign-in flow (email/password, Google, Google Play Games, Apple,
/// Facebook, phone and sign-up) calls this instead of navigating on its own, so
/// they all behave identically:
///   1. force the next bottom-bar mount to Home — a fresh login must land on
///      Home, never on whatever tab (or stale web URL) a previous session left
///      behind. This is a one-shot flag, so it wins the race against the auth
///      page's own `redirectIfAuthenticated` (both navigate to `/`);
///   2. navigate Home;
///   3. on web, rewrite the address bar to `/` — the bottom bar (Bart) writes
///      tab URLs directly and never writes Home's, so without this the URL stays
///      frozen on the previous tab (e.g. `/settings`) while the screen is Home.
///
/// Adding a new sign-in method later? Call this one function and the tab reset
/// comes for free — there is nothing to remember and nothing to duplicate, which
/// is exactly what kept the old per-flow `go('/')` calls drifting out of sync.
void goHomeAfterLogin(Ref ref) {
  requestHomeOnNextMount();
  ref.read(goRouterProvider).go('/');
  // After the frame that mounts the Home shell, correct the address bar. Home
  // never re-pushes the URL, so this `replaceState('/')` sticks.
  WidgetsBinding.instance
      .addPostFrameCallback((_) => syncBrowserUrl('/'));
}
