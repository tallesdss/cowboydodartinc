/// A self-contained AdMob banner widget.
///
/// Drop `const KasyAdBanner()` anywhere; it reads the banner ad unit from the
/// environment, hides itself for premium users, and manages the ad lifecycle.
/// On web it renders nothing (AdMob is mobile-only) via the conditional import
/// below, so it's always safe to place in shared widget trees.
library;

export 'package:cowboydodartinc/core/ads/ads_types.dart' show KasyAdBannerSize;
export 'kasy_ad_banner_io.dart'
    if (dart.library.js_interop) 'kasy_ad_banner_web.dart';
