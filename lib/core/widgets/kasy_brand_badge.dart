import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Premium brand mark: a brand‑gradient rounded squircle holding an icon (or any
/// child), optionally floating on a soft radial brand glow.
///
/// This is the kit's single "hero badge" primitive. Auth screens and permission
/// prompts all build their top mark from it, so rebranding is a one‑file change:
/// swap the [icon] (or pass a logo as [child]), or retint via [gradient] /
/// [foregroundColor]. Colors default to the active theme's brand color, so it
/// adapts to light/dark automatically.
class KasyBrandBadge extends StatelessWidget {
  const KasyBrandBadge({
    super.key,
    this.icon,
    this.child,
    this.size = 64,
    this.glyphSize = 30,
    this.glow = true,
    this.gradient,
    this.foregroundColor,
  }) : assert(
         icon != null || child != null,
         'KasyBrandBadge needs an icon or a child',
       );

  /// Icon drawn inside the badge. Ignored when [child] is provided.
  final IconData? icon;

  /// Custom content (e.g. an `Image` logo). Overrides [icon] when set.
  final Widget? child;

  /// Badge edge length.
  final double size;

  /// Icon size inside the badge.
  final double glyphSize;

  /// Soft radial brand glow behind the badge.
  final bool glow;

  /// Overrides the default subtle brand gradient fill.
  final Gradient? gradient;

  /// Icon color. Defaults to [KasyColors.onPrimary].
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final KasyColors colors = context.colors;

    final Widget badge = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient:
            gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary,
                Color.lerp(colors.primary, Colors.black, 0.18)!,
              ],
            ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(
              alpha: context.isDark ? 0.34 : 0.26,
            ),
            blurRadius: 22,
            spreadRadius: -6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child:
          child ??
          Icon(
            icon,
            color: foregroundColor ?? colors.onPrimary,
            size: glyphSize,
          ),
    );

    if (!glow) return badge;

    final double glowSize = size * 2.2;
    return SizedBox(
      width: glowSize,
      height: glowSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.primary.withValues(
                      alpha: context.isDark ? 0.20 : 0.14,
                    ),
                    colors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          badge,
        ],
      ),
    );
  }
}
