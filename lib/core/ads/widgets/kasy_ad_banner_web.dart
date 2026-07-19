import 'package:cowboydodartinc/core/ads/ads_types.dart';
import 'package:flutter/widgets.dart';

/// Web no-op banner. AdMob is mobile-only, so on web the banner renders nothing
/// while keeping the same public API as the mobile widget. See
/// [kasy_ad_banner.dart].
class KasyAdBanner extends StatelessWidget {
  const KasyAdBanner({
    super.key,
    this.size = KasyAdBannerSize.banner,
    this.forceTestAd = false,
  });

  final KasyAdBannerSize size;

  /// No-op on web; kept for API parity with the mobile widget.
  final bool forceTestAd;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
