import 'dart:math' as math;

import 'package:cowboydodartinc/components/kasy_modal_scrim.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';

/// Full-screen image lightbox: a single image floating over the kit modal scrim
/// ([KasyModalScrim]). Tapping outside the image (or pressing back) dismisses
/// it. Pinch / double-tap to zoom while open.
///
/// Pass a [heroTag] (e.g. the photo id) matching a [Hero] around the source
/// thumbnail to get a smooth shared-element zoom into and out of the viewer.
Future<void> showKasyImageViewer(
  BuildContext context, {
  required String imageUrl,
  Object? heroTag,
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) =>
          _ImageViewer(imageUrl: imageUrl, heroTag: heroTag),
      transitionsBuilder: (_, animation, _, child) {
        // The image itself rides the Hero flight; only the backdrop fades.
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

/// Caps the lightbox image so the modal scrim stays visible around the frame.
BoxConstraints kasyImageViewerConstraints(BuildContext context) {
  final Size size = MediaQuery.sizeOf(context);
  final bool isDesktop = size.width >= DeviceType.large.breakpoint;
  final double maxWidth = isDesktop
      ? math.min(KasyShadows.imageViewerDesktopMaxWidth, size.width * 0.36)
      : size.width >= DeviceType.medium.breakpoint
      ? size.width * 0.65
      : size.width * 0.82;
  final double maxHeight = size.height *
      (isDesktop
          ? KasyShadows.imageViewerDesktopMaxHeightFraction
          : KasyShadows.imageViewerMobileMaxHeightFraction);
  return BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight);
}

class _ImageViewer extends StatelessWidget {
  const _ImageViewer({required this.imageUrl, this.heroTag});

  final String imageUrl;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final BoxConstraints imageConstraints = kasyImageViewerConstraints(context);
    final bool isDesktop =
        MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;

    Widget image = Image.network(
      imageUrl,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
    );
    image = ClipRRect(
      borderRadius: KasyRadius.lgBorderRadius,
      child: image,
    );
    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          KasyModalScrim(onTap: () => Navigator.of(context).maybePop()),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(
                isDesktop ? KasySpacing.xxxl : KasySpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: imageConstraints,
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: image,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
