/// Whether the app is running inside a *mobile* web browser (phone/tablet).
///
/// Drives the OAuth flow choice on web: mobile browsers handle provider popups
/// unreliably — the provider opens in a new tab and the popup result is
/// frequently lost when the browser reclaims the backgrounded opener tab, so the
/// sign-in future never resolves and the app stays stuck "signing in". On mobile
/// we use a full-page redirect instead (completed at startup by
/// `getRedirectResult`); desktop web keeps the smoother popup.
///
/// Non-web stub: always false. The real implementation lives in
/// `auth_web_support_web.dart` and is selected via conditional import on web.
bool isMobileWebBrowser() => false;

/// Marks that a full-page redirect *sign-in* (not provider linking) is starting.
/// Persisted across the redirect's page reload so [resetUrlAfterRedirectLogin]
/// can tell, at startup, that we returned from a login (and must land on Home)
/// rather than from a link (which stays on the originating screen, e.g. Settings).
/// Non-web stub: no-op.
void markWebRedirectLogin() {}

/// If we just returned from a redirect sign-in (see [markWebRedirectLogin]),
/// clear the marker and reset the address bar to `/` so the app boots on Home
/// instead of whatever stale tab URL the redirect returned to. MUST run before
/// the router reads the initial URL. Non-web stub: no-op.
void resetUrlAfterRedirectLogin() {}
