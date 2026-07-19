import 'package:web/web.dart' as web;

/// Web implementation: detects a mobile browser from the user-agent (iOS, Android
/// and other common phone/tablet agents). iPadOS 13+ reports a desktop Safari
/// user-agent, so we also treat a touch-capable "Macintosh" as mobile.
///
/// A false positive only costs the (also-working) redirect flow instead of the
/// popup, so the heuristic deliberately errs toward catching mobiles.
bool isMobileWebBrowser() {
  final ua = web.window.navigator.userAgent.toLowerCase();
  const needles = [
    'android',
    'iphone',
    'ipad',
    'ipod',
    'mobile',
    'windows phone',
    'blackberry',
    'opera mini',
    'iemobile',
  ];
  if (needles.any(ua.contains)) return true;
  // iPadOS 13+ masquerades as desktop Safari but still exposes touch points.
  return ua.contains('macintosh') && web.window.navigator.maxTouchPoints > 1;
}

/// localStorage key flagging that a redirect *sign-in* is in flight. localStorage
/// (not in-memory) because the redirect reloads the whole page.
const String _redirectLoginKey = 'kasy_redirect_login';

void markWebRedirectLogin() {
  web.window.localStorage.setItem(_redirectLoginKey, '1');
}

void resetUrlAfterRedirectLogin() {
  if (web.window.localStorage.getItem(_redirectLoginKey) == null) return;
  web.window.localStorage.removeItem(_redirectLoginKey);
  // Absolute path: land on Home, dropping the stale tab path (e.g. /settings)
  // the redirect returned to. replaceState (not pushState) so no bogus history
  // entry is left behind.
  web.window.history.replaceState(null, '', '/');
}
