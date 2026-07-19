import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

/// Forces the browser address bar to [path] on web (no-op on native).
///
/// Why this exists: the bottom bar (Bart) writes each tab's URL directly via
/// `history.pushState`, bypassing GoRouter — and it never writes the Home tab's
/// URL (Bart short-circuits when the tab index doesn't change, and Home is the
/// default index). So after a fresh login forces Home, GoRouter is at `/` but
/// the address bar still shows the previous session's tab (e.g. `/settings`),
/// and `go('/')` is a no-op because GoRouter already considers itself at `/`.
///
/// Inner routes on the same tab (e.g. `/settings/reminder`) hit the same Bart
/// short-circuit on pop, so callers must sync explicitly — see
/// [BartInnerRouteUrlSync] and [popSettingsInnerRoute].
///
/// `replaceState` (not `pushState`) so the stale entry is corrected in place,
/// without adding a bogus history step the user could "back" into. Path-only:
/// clears stale hash fragments from older navigation.
void syncBrowserUrl(String path) {
  if (!kIsWeb) {
    return;
  }
  final String normalized = Uri.parse(path).path;
  html.window.history.replaceState(
    null,
    '',
    normalized.isEmpty ? '/' : normalized,
  );
}
