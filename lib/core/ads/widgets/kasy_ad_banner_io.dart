import 'package:cowboydodartinc/core/ads/ads_provider.dart';
import 'package:cowboydodartinc/core/ads/ads_types.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Mobile (Android/iOS) banner. Loads a [BannerAd] and renders it once ready;
/// renders nothing while loading, on failure, or when no banner should be shown
/// (premium user / no ad unit configured). See [kasy_ad_banner.dart].
class KasyAdBanner extends ConsumerStatefulWidget {
  const KasyAdBanner({
    super.key,
    this.size = KasyAdBannerSize.banner,
    this.forceTestAd = false,
  });

  final KasyAdBannerSize size;

  /// Always serve a Google test ad and ignore premium (used by the in-app ads
  /// demo so it's safe to show in any build).
  final bool forceTestAd;

  @override
  ConsumerState<KasyAdBanner> createState() => _KasyAdBannerState();
}

class _KasyAdBannerState extends ConsumerState<KasyAdBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  AdSize get _adSize => switch (widget.size) {
    KasyAdBannerSize.banner => AdSize.banner,
    KasyAdBannerSize.largeBanner => AdSize.largeBanner,
    KasyAdBannerSize.mediumRectangle => AdSize.mediumRectangle,
    KasyAdBannerSize.fullBanner => AdSize.fullBanner,
    KasyAdBannerSize.leaderboard => AdSize.leaderboard,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  void _load() {
    final String? adUnitId = ref
        .read(googleAdsProvider.notifier)
        .resolveBannerAdUnitId(forceTest: widget.forceTestAd);
    if (adUnitId == null) return;
    final BannerAd ad = BannerAd(
      size: _adSize,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) => ad.dispose(),
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the user/subscription changes so the banner disappears the
    // moment the user becomes premium (auto-served ads are hidden for them).
    ref.watch(userStateNotifierProvider);
    final BannerAd? ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    if (ref
            .read(googleAdsProvider.notifier)
            .resolveBannerAdUnitId(forceTest: widget.forceTestAd) ==
        null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
