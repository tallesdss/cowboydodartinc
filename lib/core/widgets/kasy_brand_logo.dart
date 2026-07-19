import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';

/// Wordmark height on phone-width chrome (Home app bar reference).
const double kasyBrandLogoHeightMobile = 34;

/// Wordmark height on tablet/desktop page app bars (Home app bar reference).
const double kasyBrandLogoHeightTabletUp = 42;

/// [KasyBrandLogo] height for overlay page app bars (e.g. Home root tab).
double kasyBrandLogoAppBarHeight(BuildContext context) {
  return DeviceType.fromWidth(MediaQuery.sizeOf(context).width) ==
          DeviceType.small
      ? kasyBrandLogoHeightMobile
      : kasyBrandLogoHeightTabletUp;
}

/// [KasyBrandLogo] height for sidebar/drawer chrome. Matches the Home app bar on
/// phone and tablet (34); desktop rail keeps the same compact cap.
double kasyBrandLogoSidebarHeight(BuildContext context) =>
    kasyBrandLogoHeightMobile;

/// In-app brand wordmark (`logo-light.png` / `logo-dark.png`).
///
/// Separate from native splash artwork (`splash-logo-*.png`). `kasy splash`
/// must not overwrite these files.
///
/// Swaps light/dark from the active theme. No cacheHeight (decode resize
/// pixelates small wordmarks). Paint with [FilterQuality.high].
///
/// Use [height] for chrome (sidebar, app bar). Use [boxSize] for auth
/// (`kAuthBrandLogoBox`): sized to match Figma Sign In ink, not the raw 132
/// frame (our PNG has less padding than the Figma image fill).
class KasyBrandLogo extends StatelessWidget {
  const KasyBrandLogo({
    super.key,
    this.height = 48,
    this.boxSize,
    this.lightAsset = 'assets/branding/logo-light.png',
    this.darkAsset = 'assets/branding/logo-dark.png',
    this.semanticLabel,
  });

  /// Rendered logo height when [boxSize] is null. Width follows aspect ratio.
  final double height;

  /// Square frame size (Figma auth). Image fills with [BoxFit.contain].
  final double? boxSize;

  /// Logo used in light mode.
  final String lightAsset;

  /// Logo used in dark mode.
  final String darkAsset;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final String asset = context.isDark ? darkAsset : lightAsset;
    final double? box = boxSize;
    if (box != null) {
      return SizedBox(
        width: box,
        height: box,
        child: Image.asset(
          asset,
          width: box,
          height: box,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          semanticLabel: semanticLabel,
        ),
      );
    }
    return Image.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      semanticLabel: semanticLabel,
    );
  }
}
