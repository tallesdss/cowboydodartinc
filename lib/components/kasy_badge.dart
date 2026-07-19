import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

enum KasyBadgePlacement { topRight, topLeft, bottomRight, bottomLeft }

enum KasyBadgeSize { sm, md, lg }

enum KasyBadgeTone { primary, neutral, success, warning, danger }

class KasyBadge extends StatelessWidget {
  final String? text;
  final bool isDot;
  final KasyBadgeTone tone;
  final KasyBadgeSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const KasyBadge({
    super.key,
    this.text,
    this.isDot = false,
    this.tone = KasyBadgeTone.danger,
    this.size = KasyBadgeSize.md,
    this.backgroundColor,
    this.foregroundColor,
  });

  const KasyBadge.dot({
    super.key,
    this.tone = KasyBadgeTone.primary,
    this.size = KasyBadgeSize.md,
    this.backgroundColor,
    this.foregroundColor,
  }) : text = null,
       isDot = true;

  @override
  Widget build(BuildContext context) {
    final _KasyBadgePalette palette = _resolvePalette(context);
    final _KasyBadgeMetrics metrics = _resolveMetrics(size);
    final String label = isDot ? 'Badge' : (text ?? 'Badge');

    return Semantics(
      label: label,
      child: isDot
          ? Container(
              width: metrics.dotDiameter,
              height: metrics.dotDiameter,
              decoration: BoxDecoration(
                color: palette.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colors.surface,
                  width: metrics.ringWidth,
                ),
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                color: palette.background,
                borderRadius: BorderRadius.circular(KasyRadius.full),
                border: Border.all(
                  color: context.colors.surface,
                  width: metrics.ringWidth,
                ),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: metrics.minWidth),
                child: SizedBox(
                  height: metrics.height,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: metrics.horizontalPadding,
                    ),
                    child: Center(
                      child: Text(
                        (text ?? '').trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (context.textTheme.labelSmall ?? const TextStyle())
                                .copyWith(
                                  color: palette.foreground,
                                  // w600, not w700 — a counter shouldn't carry
                                  // heading weight; still punchy at tiny size.
                                  fontWeight: FontWeight.w600,
                                  fontSize: metrics.fontSize,
                                  height: 1,
                                ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  _KasyBadgePalette _resolvePalette(BuildContext context) {
    final KasyColors c = context.colors;
    final Color bg =
        backgroundColor ??
        switch (tone) {
          KasyBadgeTone.primary => c.primary,
          KasyBadgeTone.neutral =>
            context.isDark ? c.avatarFallbackFill : c.surfaceNeutralSoft,
          KasyBadgeTone.success => c.success,
          KasyBadgeTone.warning => c.warning,
          KasyBadgeTone.danger => c.error,
        };
    final Color fg =
        foregroundColor ??
        switch (tone) {
          KasyBadgeTone.neutral => context.isDark ? c.fieldLabel : c.muted,
          _ => Colors.white,
        };
    return _KasyBadgePalette(background: bg, foreground: fg);
  }

  static _KasyBadgeMetrics metricsFor(KasyBadgeSize size) {
    return _resolveMetrics(size);
  }

  static _KasyBadgeMetrics _resolveMetrics(KasyBadgeSize size) {
    return switch (size) {
      KasyBadgeSize.sm => const _KasyBadgeMetrics(
        height: 16,
        minWidth: 16,
        horizontalPadding: 5,
        ringWidth: 1.5,
        fontSize: 10.5,
        dotDiameter: 12,
      ),
      KasyBadgeSize.md => const _KasyBadgeMetrics(
        height: 18,
        minWidth: 18,
        horizontalPadding: 6,
        ringWidth: 1.5,
        fontSize: 11,
        dotDiameter: 14,
      ),
      KasyBadgeSize.lg => const _KasyBadgeMetrics(
        height: 20,
        minWidth: 20,
        horizontalPadding: 7,
        ringWidth: 1.5,
        fontSize: 11.5,
        dotDiameter: 16,
      ),
    };
  }
}

class KasyBadged extends StatelessWidget {
  final Widget child;
  final KasyBadge badge;
  final KasyBadgePlacement placement;
  final double? overlap;
  final double? avatarDiameter;
  final bool isCircularAvatar;

  const KasyBadged({
    super.key,
    required this.child,
    required this.badge,
    this.placement = KasyBadgePlacement.topRight,
    this.overlap,
    this.avatarDiameter,
    this.isCircularAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final _KasyBadgeOffset resolvedOffset = _resolveOffset();
    final (
      double? top,
      double? right,
      double? bottom,
      double? left,
    ) = switch (placement) {
      KasyBadgePlacement.topRight => (
        -resolvedOffset.y,
        -resolvedOffset.x,
        null,
        null,
      ),
      KasyBadgePlacement.topLeft => (
        -resolvedOffset.y,
        null,
        null,
        -resolvedOffset.x,
      ),
      KasyBadgePlacement.bottomRight => (
        null,
        -resolvedOffset.x,
        -resolvedOffset.y,
        null,
      ),
      KasyBadgePlacement.bottomLeft => (
        null,
        null,
        -resolvedOffset.y,
        -resolvedOffset.x,
      ),
    };
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: top,
          right: right,
          bottom: bottom,
          left: left,
          child: badge,
        ),
      ],
    );
  }

  _KasyBadgeOffset _resolveOffset() {
    if (overlap != null) {
      return _KasyBadgeOffset(x: overlap!, y: overlap!);
    }
    final _KasyBadgeMetrics metrics = KasyBadge.metricsFor(badge.size);
    final double bh = badge.isDot
        ? metrics.dotDiameter / 2
        : metrics.height / 2;
    if (!isCircularAvatar) {
      // Rounded-square: sit at bounding-box corner, ~35% of badge inside.
      return _KasyBadgeOffset(x: bh * 0.65, y: bh * 0.65);
    }
    // Circle arc: badge center on 45° arc. k = 1 − 1/√2 ≈ 0.2929.
    // Dot badges get +2 px push so they sit visibly outside (status-indicator style).
    final double diameter =
        avatarDiameter ??
        switch (badge.size) {
          KasyBadgeSize.sm => 40.0,
          KasyBadgeSize.md => 54.0,
          KasyBadgeSize.lg => 70.0,
        };
    final double R = diameter / 2;
    const double k = 0.2929;
    final double dotExtra = badge.isDot ? 2.0 : 0.0;
    final double off = bh - R * k + dotExtra;
    return _KasyBadgeOffset(x: off, y: off);
  }
}

class _KasyBadgePalette {
  final Color background;
  final Color foreground;

  const _KasyBadgePalette({required this.background, required this.foreground});
}

class _KasyBadgeMetrics {
  final double height;
  final double minWidth;
  final double horizontalPadding;
  final double ringWidth;
  final double fontSize;
  final double dotDiameter;

  const _KasyBadgeMetrics({
    required this.height,
    required this.minWidth,
    required this.horizontalPadding,
    required this.ringWidth,
    required this.fontSize,
    required this.dotDiameter,
  });
}

class _KasyBadgeOffset {
  final double x;
  final double y;

  const _KasyBadgeOffset({required this.x, required this.y});
}
