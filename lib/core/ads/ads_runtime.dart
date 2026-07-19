/// Imperative AdMob calls (initialize + full-screen formats), isolated behind a
/// conditional import.
///
/// The real implementation (`ads_runtime_io.dart`) imports `google_mobile_ads`,
/// which is mobile-only. On web the conditional import swaps in the no-op stub
/// (`ads_runtime_web.dart`) so the mobile SDK never reaches the web build. The
/// public surface (the top-level functions below) is identical on both sides,
/// so callers, like [GoogleAdsNotifier], never branch on platform.
library;

export 'ads_runtime_io.dart'
    if (dart.library.js_interop) 'ads_runtime_web.dart';
export 'ads_types.dart';
