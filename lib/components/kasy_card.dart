import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_pressable_depth.dart';
import 'package:flutter/material.dart';

/// Visual surface treatment for [KasyCard].
enum KasyCardVariant {
  /// White/surface background, subtle shadow, hairline border.
  elevated,

  /// Soft zinc fill ([surfaceSecondary]), no shadow.
  ///
  /// Home filter chips and other resting surfaces use this so unselected
  /// cards stay flat (Figma 03 Home) instead of carrying [shadow/surface].
  filled,

  /// Transparent background, hairline border only.
  outlined,

  /// No background, no border, no shadow.
  ghost,

  /// Onboarding-style spotlight card: surface, hairline border, component shadow.
  /// Pair with [borderRadius] 16 via [KasySpotlightCard].
  spotlight,
}

/// Design-system surface card.
///
/// [variant] controls background, border, and shadow. Use [onTap] for
/// interactive cards (adds [KasyPressableDepth] feedback).
///
/// [borderColor] overrides the variant's default border color. Useful for
/// tinted flat cards (e.g. combine with [KasyCardVariant.outlined] and [color]
/// to get a shadow-free card with a custom border tint).
class KasyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final bool clipContent;
  final KasyCardVariant variant;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const KasyCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.borderColor,
    this.clipContent = true,
    this.variant = KasyCardVariant.elevated,
    this.borderRadius,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final BorderRadius resolvedRadius =
        borderRadius ?? BorderRadius.circular(KasyRadius.xl);

    final Color bg;
    final Border? border;
    final List<BoxShadow>? shadows;

    switch (variant) {
      case KasyCardVariant.elevated:
        bg = color ?? c.surface;
        // Figma `border/elevated` — fully transparent in dark (no stroke).
        border = c.borderElevated.a < 0.01
            ? null
            : Border.all(color: c.borderElevated);
        shadows = KasyShadows.cardElevated(context);
      case KasyCardVariant.filled:
        bg = color ?? c.surfaceSecondary;
        border = null;
        shadows = null;
      case KasyCardVariant.outlined:
        bg = color ?? Colors.transparent;
        border = Border.all(color: c.borderSoft);
        shadows = null;
      case KasyCardVariant.ghost:
        bg = color ?? Colors.transparent;
        border = null;
        shadows = null;
      case KasyCardVariant.spotlight:
        bg = color ?? c.surface;
        border = Border.all(
          color: borderColor ?? c.borderSoft,
        );
        shadows = KasyShadows.surfaceOf(context);
    }

    final Widget content =
        padding == null ? child : Padding(padding: padding!, child: child);

    final Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: resolvedRadius,
        border: borderColor != null ? Border.all(color: borderColor!) : border,
        boxShadow: shadows,
      ),
      child: clipContent
          ? ClipRRect(borderRadius: resolvedRadius, child: content)
          : content,
    );

    final Widget margined =
        margin != null ? Padding(padding: margin!, child: card) : card;

    if (onTap != null) {
      return KasyPressableDepth(
        onPressed: onTap!,
        semanticLabel: semanticLabel ?? 'Card',
        clipBorderRadius: resolvedRadius,
        // Subtle overlay → a hover highlight on web (pointer) and a soft press
        // flash everywhere. A tappable card is an actionable control, so it
        // should feel interactive on hover like any web control.
        pressOverlayColor:
            c.onSurface.withValues(alpha: context.isDark ? 0.06 : 0.04),
        // A tappable card is an actionable control, so make it a keyboard
        // tab-stop with the standard focus ring (matches buttons/links).
        focusable: true,
        focusBorderRadius: resolvedRadius,
        child: margined,
      );
    }

    return margined;
  }
}
