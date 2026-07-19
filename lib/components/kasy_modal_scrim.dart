import 'dart:ui';

import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Frosted-glass backdrop for modal surfaces.
///
/// Used by [showKasyBlurDialog], [showKasyBlurBottomSheet], [showKasyImageViewer],
/// and paywall overlays. Blur and dim tokens live on [KasyShadows.modalScrimBlur]
/// and [KasyShadows.modalScrimDimAlpha].
class KasyModalScrim extends StatelessWidget {
  const KasyModalScrim({
    super.key,
    this.opacity = 1,
    this.blurSigma,
    this.onTap,
  });

  /// Multiplier for entrance/exit animations (0..1).
  final double opacity;
  final double? blurSigma;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double t = opacity.clamp(0.0, 1.0);
    final double sigma = (blurSigma ?? KasyShadows.modalScrimBlur) * t;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: ColoredBox(
          color: Colors.black.withValues(
            alpha: KasyShadows.modalScrimDimAlpha * t,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
