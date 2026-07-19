import 'package:cowboydodartinc/components/kasy_spinner.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/core/widgets/kasy_pressable_depth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Neutral pill fill for soft / neutral / tertiary buttons (light #EBEBED, dark #272729).
Color _neutralFilledButtonSurface(BuildContext context) =>
    context.isDark ? const Color(0xFF272729) : const Color(0xFFEBEBED);

/// Visual variants for [KasyButton].
enum KasyButtonVariant {
  primary,

  /// Legacy outlined variant used in existing screens.
  secondary,

  /// Legacy text variant used in existing screens.
  tertiary,
  destructive,

  /// Soft destructive style (tinted background + danger text).
  destructiveSoft,

  /// Filled inverted: white/surface background + primary text.
  inverse,

  /// Compact inline text action.
  link,

  /// Soft filled style with brand text.
  soft,

  /// Soft filled neutral style.
  neutral,

  /// Neutral outlined style.
  outline,

  /// Text-only neutral style.
  ghost,
}

/// Vertical rhythm presets for [KasyButton].
enum KasyButtonSize { small, medium, large }

/// Placement for [icon] when label is shown.
enum KasyButtonIconAlignment { leading, trailing, top }

/// Press-feedback style for [KasyButton].
enum KasyButtonPressEffect {
  /// Scale/depth animation (default).
  depth,

  /// Subtle background fill via [KasyHover] — matches card/list press style.
  fill,

  /// Scale/depth + fill overlay combined.
  both,
}

/// Loading behavior while [isLoading] is true.
enum KasyButtonLoadingBehavior {
  /// Keep normal button shape and only swap content to a spinner.
  inline,

  /// Morph width to a round loading orb and restore when loading finishes.
  shrinkToCircle,
}

/// Design-system button used across the app.
///
/// Backward compatible with existing calls (`label`, `variant`, `isLoading`,
/// `icon`, `expand`) and extended with richer visual variants and size control.
///
/// Stroke: outlined styles use [variant] (e.g. [KasyButtonVariant.secondary],
/// [KasyButtonVariant.outline]). Custom rim: non-transparent [borderColor] plus
/// optional [outlineWidth].
///
/// Corners default to [KasyRadius.xl] (24) or a circle for icon-only; set
/// [borderRadius] to override (e.g. `BorderRadius.circular(KasyRadius.md)`).
class KasyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final KasyButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool expand;
  final KasyButtonSize size;
  final KasyButtonIconAlignment iconAlignment;
  final KasyButtonLoadingBehavior loadingBehavior;
  final Duration morphDuration;
  final Duration morphBackDuration;

  /// Optional fixed width when [expand] is false.
  final double? width;

  /// Optional fills and colors; omit to use tokens from [variant].
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Stroke override. When the color is not fully transparent, draws the rim.
  final Color? borderColor;

  /// Hairline thickness when [borderColor] / variant resolves a visible stroke (~1 px if omitted).
  final double? outlineWidth;

  /// Rounded corners; omit for defaults (md body, circular icon-only).
  final BorderRadius? borderRadius;
  final Gradient? backgroundGradient;
  final FontWeight? fontWeight;
  final String? semanticLabel;

  /// Press feedback style; defaults to [KasyButtonPressEffect.depth] (scale).
  ///
  /// Use [KasyButtonPressEffect.fill] for pill/surface buttons where a
  /// background fill matches nearby card or list press feedback.
  final KasyButtonPressEffect pressEffect;

  /// Optional press/hover veil colour (web [KasyButtonPressEffect.both] /
  /// [KasyButtonPressEffect.fill]). Include alpha when you want an exact veil.
  ///
  /// When null, the kit derives a tint from [borderColor], then
  /// [backgroundColor], then label [foregroundColor] so custom Figma palettes
  /// do not flash a neutral grey hover.
  final Color? pressOverlayColor;

  /// Light tap feedback via [KasyPressableDepth]; disable with false.
  final bool hapticFeedbackEnabled;

  /// Icon-only layout: replaces the circular extent from [size] metrics (width × height).
  final double? iconOnlyLayoutExtent;

  /// Icon-only: drawn glyph size; when null, uses the metric for [size].
  final double? iconGlyphSize;

  /// Fixed pixel height of a [KasyButtonSize.small] button. Exposed so layouts
  /// can reserve matching header space and keep adjacent titles aligned.
  static const double smallHeight = 40;

  const KasyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = KasyButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expand = false,
    this.size = KasyButtonSize.medium,
    this.iconAlignment = KasyButtonIconAlignment.leading,
    this.loadingBehavior = KasyButtonLoadingBehavior.inline,
    this.morphDuration = const Duration(milliseconds: 180),
    this.morphBackDuration = const Duration(milliseconds: 130),
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.outlineWidth,
    this.borderRadius,
    this.backgroundGradient,
    this.fontWeight,
    this.semanticLabel,
    this.pressEffect = kIsWeb
        ? KasyButtonPressEffect.both
        : KasyButtonPressEffect.depth,
    this.pressOverlayColor,
    this.hapticFeedbackEnabled = true,
    this.iconOnlyLayoutExtent,
    this.iconGlyphSize,
  });

  /// Circular icon-only action button.
  const KasyButton.iconOnly({
    super.key,
    required IconData this.icon,
    required this.onPressed,
    this.variant = KasyButtonVariant.primary,
    this.isLoading = false,
    this.size = KasyButtonSize.medium,
    this.loadingBehavior = KasyButtonLoadingBehavior.inline,
    this.morphDuration = const Duration(milliseconds: 180),
    this.morphBackDuration = const Duration(milliseconds: 130),
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.outlineWidth,
    this.borderRadius,
    this.backgroundGradient,
    this.fontWeight,
    this.semanticLabel,
    this.pressEffect = kIsWeb
        ? KasyButtonPressEffect.both
        : KasyButtonPressEffect.depth,
    this.pressOverlayColor,
    this.hapticFeedbackEnabled = true,
    this.iconOnlyLayoutExtent,
    this.iconGlyphSize,
  }) : label = '',
       expand = false,
       iconAlignment = KasyButtonIconAlignment.leading;

  bool get _isIconOnly => label.trim().isEmpty && icon != null;

  @override
  Widget build(BuildContext context) {
    final bool interactive = onPressed != null && !isLoading;
    final _KasyButtonMetrics metrics = _metricsFor(size);
    final _KasyButtonPalette palette = _resolvePalette(
      context,
      disabledLook: onPressed == null,
      isLoading: isLoading,
      variant: variant,
    );
    final bool morphToCircle =
        isLoading &&
        loadingBehavior == KasyButtonLoadingBehavior.shrinkToCircle;
    final double layoutIconExtent = _isIconOnly && iconOnlyLayoutExtent != null
        ? iconOnlyLayoutExtent!
        : metrics.iconOnlyExtent;
    final double buttonHeight = _isIconOnly ? layoutIconExtent : metrics.height;
    final double? targetWidth = morphToCircle
        ? buttonHeight
        : expand
        ? double.infinity
        : (_isIconOnly && width == null ? buttonHeight : width);

    final Widget shell = _KasyButtonShell(
      label: label,
      icon: icon,
      enabled: interactive,
      isLoading: isLoading,
      isIconOnly: _isIconOnly,
      morphToCircle: morphToCircle,
      iconAlignment: iconAlignment,
      metrics: metrics,
      palette: palette,
      buttonHeight: buttonHeight,
      iconOnlyGlyphOverride: iconGlyphSize,
      variant: variant,
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      backgroundGradient: backgroundGradient,
      fontWeight: fontWeight,
      pressEffect: pressEffect,
      pressOverlayColor: pressOverlayColor,
      customBackgroundColor: backgroundColor,
      customBorderColor: borderColor,
      hapticFeedbackEnabled: hapticFeedbackEnabled,
      outlineWidth: outlineWidth,
      borderRadius: borderRadius,
    );

    Widget result;
    if (expand) {
      result = SizedBox(width: double.infinity, child: shell);
    } else if (targetWidth != null && targetWidth.isFinite) {
      final Duration widthMorphDuration = morphToCircle
          ? morphBackDuration
          : morphDuration;
      result = TweenAnimationBuilder<double>(
        duration: widthMorphDuration,
        curve: Curves.easeInOutCubic,
        tween: Tween<double>(begin: targetWidth, end: targetWidth),
        child: shell,
        builder: (BuildContext context, double animatedWidth, Widget? child) {
          return SizedBox(width: animatedWidth, child: child);
        },
      );
    } else {
      result = shell;
    }

    return result;
  }

  _KasyButtonPalette _resolvePalette(
    BuildContext context, {
    required bool disabledLook,
    required bool isLoading,
    required KasyButtonVariant variant,
  }) {
    final KasyColors c = context.colors;
    final _KasyButtonPalette base = switch (variant) {
      KasyButtonVariant.primary => _KasyButtonPalette(
        background: c.primary,
        foreground: c.onPrimary,
        border: Colors.transparent,
      ),
      KasyButtonVariant.secondary => _KasyButtonPalette(
        background: Colors.transparent,
        foreground: c.primary,
        // Figma `border/soft` — social / secondary outline chrome.
        border: c.borderSoft,
      ),
      KasyButtonVariant.tertiary => _KasyButtonPalette(
        background: _neutralFilledButtonSurface(context),
        foreground: c.onSurface,
        border: Colors.transparent,
      ),
      KasyButtonVariant.destructive => _KasyButtonPalette(
        background: c.error,
        foreground: c.onError,
        border: Colors.transparent,
      ),
      KasyButtonVariant.destructiveSoft => _KasyButtonPalette(
        background: c.surfaceErrorSoft,
        foreground: c.error,
        border: Colors.transparent,
      ),
      KasyButtonVariant.inverse => _KasyButtonPalette(
        background: c.onPrimary,
        foreground: c.primary,
        border: Colors.transparent,
      ),
      // Text-only secondary CTA ("Not now", skip). Uses onSurface so it reads
      // as white/ink, never brand blue / link cyan.
      KasyButtonVariant.link => _KasyButtonPalette(
        background: Colors.transparent,
        foreground: c.onSurface,
        border: Colors.transparent,
      ),
      KasyButtonVariant.soft => _KasyButtonPalette(
        background: _neutralFilledButtonSurface(context),
        foreground: c.primary,
        border: Colors.transparent,
      ),
      KasyButtonVariant.neutral => _KasyButtonPalette(
        background: _neutralFilledButtonSurface(context),
        foreground: c.onSurface,
        border: Colors.transparent,
      ),
      KasyButtonVariant.outline => _KasyButtonPalette(
        background: Colors.transparent,
        foreground: c.onSurface,
        border: context.isDark
            ? const Color(0x2BFFFFFF)
            : c.outline.withValues(alpha: 0.48),
      ),
      KasyButtonVariant.ghost => _KasyButtonPalette(
        background: Colors.transparent,
        foreground: c.onSurface,
        border: Colors.transparent,
      ),
    };
    final Color resolvedBg = backgroundColor ?? base.background;
    final Color resolvedFg = foregroundColor ?? base.foreground;
    final Color resolvedBorder = borderColor ?? base.border;
    if (disabledLook) {
      // Loading + disabled: keep loading palette so spinner colours read well.
      final _KasyButtonPalette? loading = _disabledLoadingPalette(
        context,
        variant,
        isLoading: isLoading,
      );
      if (loading != null) {
        final Color? fgCustom = foregroundColor;
        final Color fg = fgCustom != null
            ? fgCustom.withValues(alpha: 0.92)
            : loading.foreground;
        final Color bg = backgroundColor ?? loading.background;
        return _KasyButtonPalette(
          background: bg,
          foreground: fg,
          border: _disabledBorderFor(variant, resolvedBorder),
        );
      }
      // Normal disabled: compute opaque muted colours so the button stays
      // solid — no transparency bleed-through from whatever is behind it.
      final Color blendSurface = context.colors.surfaceNeutralSoft;
      final bool hasSolidBg = resolvedBg.a > 0.05;
      return _KasyButtonPalette(
        background: hasSolidBg
            ? Color.alphaBlend(resolvedBg.withValues(alpha: 0.46), blendSurface)
            : resolvedBg, // transparent-bg variants (secondary, link, ghost) keep transparent
        foreground: resolvedFg.withValues(alpha: 0.45),
        border: resolvedBorder.a > 0.05
            ? resolvedBorder.withValues(alpha: 0.40)
            : resolvedBorder,
      );
    }
    return _KasyButtonPalette(
      background: resolvedBg,
      foreground: resolvedFg,
      border: resolvedBorder,
    );
  }

  _KasyButtonPalette? _disabledLoadingPalette(
    BuildContext context,
    KasyButtonVariant variant, {
    required bool isLoading,
  }) {
    if (!isLoading) {
      return null;
    }
    final KasyColors c = context.colors;
    final Color soft = c.surfaceNeutralSoft;
    // Variants used on non-theme-matched backgrounds (e.g. inverse on the paywall gradient)
    // need an explicit case — the generic disabled fallback blends with surfaceNeutralSoft,
    // which goes near-black in dark mode and kills contrast on colored surfaces.
    return switch (variant) {
      KasyButtonVariant.primary => _KasyButtonPalette(
        background: Color.alphaBlend(c.primary.withValues(alpha: 0.62), soft),
        foreground: c.onPrimary.withValues(alpha: 0.94),
        border: Colors.transparent,
      ),
      KasyButtonVariant.neutral || KasyButtonVariant.soft => _KasyButtonPalette(
        background: _neutralFilledButtonSurface(context),
        foreground: c.primary.withValues(alpha: 0.90),
        border: Colors.transparent,
      ),
      KasyButtonVariant.inverse => _KasyButtonPalette(
        background: c.onPrimary,
        foreground: c.primary.withValues(alpha: 0.62),
        border: Colors.transparent,
      ),
      _ => null,
    };
  }

  Color _disabledBorderFor(KasyButtonVariant variant, Color resolvedBorder) {
    final bool keepsStroke =
        variant == KasyButtonVariant.secondary ||
        variant == KasyButtonVariant.outline;
    if (!keepsStroke || resolvedBorder.a == 0) {
      return Colors.transparent;
    }
    return resolvedBorder.withValues(alpha: 0.42);
  }

  _KasyButtonMetrics _metricsFor(KasyButtonSize buttonSize) {
    return switch (buttonSize) {
      // HeroUI's button uses Button base = 16 across the board, so the label is
      // 16 for every size; the sizes differ by height / padding, not by text.
      // Stable across breakpoints (buttons don't scale).
      KasyButtonSize.small => const _KasyButtonMetrics(
        height: smallHeight,
        iconOnlyExtent: smallHeight,
        horizontalPadding: EdgeInsets.symmetric(horizontal: KasySpacing.md),
        labelFontSize: 16,
        iconSize: KasyIconSize.sm,
        iconOnlyGlyphSize: KasyIconSize.xxs,
        loadingSpinnerExtent: 13,
      ),
      KasyButtonSize.medium => const _KasyButtonMetrics(
        height: 45,
        iconOnlyExtent: 45,
        horizontalPadding: EdgeInsets.symmetric(horizontal: KasySpacing.md + 2),
        labelFontSize: 16,
        iconSize: KasyIconSize.md,
        iconOnlyGlyphSize: KasyIconSize.xs,
        loadingSpinnerExtent: 14,
      ),
      KasyButtonSize.large => const _KasyButtonMetrics(
        height: 54,
        iconOnlyExtent: 54,
        horizontalPadding: EdgeInsets.symmetric(horizontal: KasySpacing.lg - 2),
        labelFontSize: 16,
        iconSize: KasyIconSize.md,
        iconOnlyGlyphSize: KasyIconSize.md,
        loadingSpinnerExtent: 15,
      ),
    };
  }
}

class _KasyButtonShell extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool enabled;
  final bool isLoading;
  final bool isIconOnly;
  final bool morphToCircle;
  final KasyButtonIconAlignment iconAlignment;
  final _KasyButtonMetrics metrics;
  final _KasyButtonPalette palette;
  final double buttonHeight;
  final double? iconOnlyGlyphOverride;
  final KasyButtonVariant variant;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final Gradient? backgroundGradient;
  final FontWeight? fontWeight;
  final KasyButtonPressEffect pressEffect;
  final Color? pressOverlayColor;
  final Color? customBackgroundColor;
  final Color? customBorderColor;
  final bool hapticFeedbackEnabled;
  final double? outlineWidth;
  final BorderRadius? borderRadius;
  static const Duration _contentTransitionDuration = Duration(
    milliseconds: 220,
  );

  const _KasyButtonShell({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.isLoading,
    required this.isIconOnly,
    required this.morphToCircle,
    required this.iconAlignment,
    required this.metrics,
    required this.palette,
    required this.buttonHeight,
    this.iconOnlyGlyphOverride,
    required this.variant,
    required this.onPressed,
    required this.semanticLabel,
    required this.backgroundGradient,
    required this.fontWeight,
    required this.pressEffect,
    this.pressOverlayColor,
    this.customBackgroundColor,
    this.customBorderColor,
    required this.hapticFeedbackEnabled,
    required this.outlineWidth,
    required this.borderRadius,
  });

  String get _accessibilityLabel =>
      semanticLabel ?? (label.isEmpty ? 'Button' : label);

  Widget _wrapFocus(Widget child, BorderRadius borderRadius) {
    if (!enabled || onPressed == null) return child;
    return KasyFocusRing(
      onActivate: onPressed,
      borderRadius: borderRadius,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool compactLink = variant == KasyButtonVariant.link;
    final BorderRadius resolvedRadius = morphToCircle
        ? BorderRadius.circular(buttonHeight / 2)
        : borderRadius ??
              BorderRadius.circular(
                // App-wide default: 24 (KasyRadius.xl). Icon-only stays circular.
                // Override per call site via [borderRadius] (e.g. the preview
                // screen shows a few less-rounded demos).
                isIconOnly ? buttonHeight / 2 : KasyRadius.xl,
              );

    if (compactLink) {
      final Widget linkVisual = _buildContent(context, compactLink);
      if (enabled && onPressed != null) {
        return _wrapFocus(
          KasyPressableDepth(
            semanticLabel: _accessibilityLabel,
            onPressed: onPressed!,
            hapticFeedbackEnabled: hapticFeedbackEnabled,
            child: linkVisual,
          ),
          resolvedRadius,
        );
      }
      return Semantics(
        button: true,
        enabled: false,
        label: _accessibilityLabel,
        child: linkVisual,
      );
    }

    final BoxDecoration decoration = BoxDecoration(
      color: backgroundGradient != null ? null : palette.background,
      gradient: backgroundGradient,
      borderRadius: resolvedRadius,
      border: palette.border.a == 0
          ? null
          : Border.all(color: palette.border, width: outlineWidth ?? 1),
    );

    final Widget content = AnimatedSwitcher(
      duration: _contentTransitionDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final Animation<Offset> slide = Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: KeyedSubtree(
        key: ValueKey<String>(_contentStateKey(compactLink)),
        child: _buildContent(context, compactLink),
      ),
    );
    final Widget inner =
        iconAlignment == KasyButtonIconAlignment.top && !isIconOnly
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                child: content,
              )
            : SizedBox(
                height: buttonHeight,
                child: Padding(
                  padding: isIconOnly || morphToCircle
                      ? EdgeInsets.zero
                      : metrics.horizontalPadding,
                  child: content,
                ),
              );

    final Widget painted = DecoratedBox(
      decoration: decoration,
      child: inner,
    );

    if (!enabled || onPressed == null) {
      return Semantics(
        button: true,
        enabled: false,
        label: _accessibilityLabel,
        child: ClipRRect(borderRadius: resolvedRadius, child: painted),
      );
    }

    if (pressEffect == KasyButtonPressEffect.fill) {
      return _wrapFocus(
        ClipRRect(
          borderRadius: resolvedRadius,
          child: DecoratedBox(
            decoration: decoration,
            child: KasyHover(
              onTap: onPressed!,
              pressColor: _pressFeedbackTint(context),
              semanticLabel: _accessibilityLabel,
              hapticEnabled: hapticFeedbackEnabled,
              child: inner,
            ),
          ),
        ),
        resolvedRadius,
      );
    }

    if (pressEffect == KasyButtonPressEffect.both) {
      return KasyPressableDepth(
        semanticLabel: _accessibilityLabel,
        onPressed: onPressed!,
        clipBorderRadius: resolvedRadius,
        hapticFeedbackEnabled: hapticFeedbackEnabled,
        pressOverlayColor: _resolvedPressOverlayColor(context),
        // Wrap the focus ring around the painted visual, not the pressable: the
        // pressable enforces a 44px min tap target and stretches to its parent,
        // so ringing it would draw an oversized oval around a small round orb.
        child: _wrapFocus(painted, resolvedRadius),
      );
    }

    return KasyPressableDepth(
      semanticLabel: _accessibilityLabel,
      onPressed: onPressed!,
      clipBorderRadius: resolvedRadius,
      hapticFeedbackEnabled: hapticFeedbackEnabled,
      // Ring hugs the visual, not the (larger) tap target. See note above.
      child: _wrapFocus(painted, resolvedRadius),
    );
  }

  Widget _buildContent(BuildContext context, bool compactLink) {
    final double effectiveIconOnlyGlyph =
        iconOnlyGlyphOverride ?? metrics.iconOnlyGlyphSize;

    // Single, uniform label weight for every button: HeroUI font-medium / w500.
    // [fontWeight] overrides this per call site.
    final FontWeight labelWeight = fontWeight ?? FontWeight.w500;

    if (isLoading && morphToCircle) {
      return Center(
        child: _ButtonLoading(
          color: palette.foreground,
          extent: metrics.loadingSpinnerExtent,
        ),
      );
    }

    if (isLoading && !compactLink && !isIconOnly && !morphToCircle) {
      final TextStyle loadingTextStyle =
          context.textTheme.labelLarge?.copyWith(
            color: palette.foreground,
            fontWeight: labelWeight,
            fontSize: metrics.labelFontSize,
            height: 1.05,
          ) ??
          TextStyle(
            color: palette.foreground,
            fontWeight: labelWeight,
            fontSize: metrics.labelFontSize,
            height: 1.05,
          );
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ButtonLoading(
              color: palette.foreground,
              extent: metrics.loadingSpinnerExtent,
            ),
            const SizedBox(width: KasySpacing.sm),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: loadingTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return Center(
        child: _ButtonLoading(
          color: palette.foreground,
          extent: isIconOnly
              ? effectiveIconOnlyGlyph
              : metrics.loadingSpinnerExtent,
        ),
      );
    }

    if (isIconOnly && icon != null) {
      return Center(
        child: Icon(
          icon,
          size: effectiveIconOnlyGlyph,
          color: palette.foreground,
        ),
      );
    }

    // HeroUI "Button base" = font-medium / w500 at 16. Same weight for EVERY
    // variant; a filled button only LOOKS a touch bolder than an outline one
    // because white-on-colour reads heavier than dark-on-light — not the weight.
    final TextStyle textStyle =
        context.textTheme.labelLarge?.copyWith(
          color: palette.foreground,
          fontWeight: labelWeight,
          fontSize: metrics.labelFontSize,
          height: 1.05,
        ) ??
        TextStyle(
          color: palette.foreground,
          fontWeight: labelWeight,
          fontSize: metrics.labelFontSize,
          height: 1.05,
        );

    final Widget text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
      textAlign: TextAlign.center,
    );
    final bool hasIcon = icon != null;
    if (!hasIcon) {
      return Center(child: text);
    }
    final Widget iconWidget = Icon(
      icon,
      size: metrics.iconSize,
      color: palette.foreground,
    );
    if (iconAlignment == KasyButtonIconAlignment.top && !compactLink) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: metrics.iconSize + 4, color: palette.foreground),
          const SizedBox(height: 6),
          text,
        ],
      );
    }
    if (compactLink) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: iconAlignment == KasyButtonIconAlignment.leading
            ? <Widget>[iconWidget, const SizedBox(width: KasySpacing.xs), text]
            : <Widget>[text, const SizedBox(width: KasySpacing.xs), iconWidget],
      );
    }
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: iconAlignment == KasyButtonIconAlignment.leading
            ? <Widget>[iconWidget, const SizedBox(width: KasySpacing.sm), text]
            : <Widget>[text, const SizedBox(width: KasySpacing.sm), iconWidget],
      ),
    );
  }

  Color _pressFeedbackTint(BuildContext context) {
    return resolveKasyButtonPressFeedbackTint(
      paletteBackground: palette.background,
      paletteForeground: palette.foreground,
      paletteBorder: palette.border,
      customBackground: customBackgroundColor,
      customBorder: customBorderColor,
    );
  }

  Color _resolvedPressOverlayColor(BuildContext context) {
    return resolveKasyButtonPressOverlayColor(
      context: context,
      paletteBackground: palette.background,
      paletteForeground: palette.foreground,
      paletteBorder: palette.border,
      customBackground: customBackgroundColor,
      customBorder: customBorderColor,
      override: pressOverlayColor,
    );
  }

  String _contentStateKey(bool compactLink) {
    if (isLoading && morphToCircle) {
      return 'loading-circle';
    }
    if (isLoading && !compactLink && !isIconOnly && !morphToCircle) {
      return 'loading-inline-label';
    }
    if (isLoading) {
      return 'loading-glyph';
    }
    if (isIconOnly) {
      return 'icon-only';
    }
    if (icon != null) {
      return compactLink ? 'text-icon-link' : 'text-icon';
    }
    return 'text-only';
  }
}

class _ButtonLoading extends StatelessWidget {
  final Color color;
  final double extent;

  const _ButtonLoading({required this.color, required this.extent});

  @override
  Widget build(BuildContext context) {
    // Soft end via alpha (not surface-mix): the spinner sits on the button's
    // own coloured fill, so the gradient must read against any background.
    return KasySpinner(
      diameter: extent,
      color: color,
      softColor: color.withValues(alpha: 0.25),
    );
  }
}

class _KasyButtonPalette {
  final Color background;
  final Color foreground;
  final Color border;

  const _KasyButtonPalette({
    required this.background,
    required this.foreground,
    required this.border,
  });
}

class _KasyButtonMetrics {
  final double height;
  final double iconOnlyExtent;
  final EdgeInsets horizontalPadding;
  final double labelFontSize;

  /// Icon next to the label (buttons with text).
  final double iconSize;

  /// Glyph size inside the icon-only button (may differ from [iconSize]).
  final double iconOnlyGlyphSize;
  final double loadingSpinnerExtent;

  const _KasyButtonMetrics({
    required this.height,
    required this.iconOnlyExtent,
    required this.horizontalPadding,
    required this.labelFontSize,
    required this.iconSize,
    required this.iconOnlyGlyphSize,
    required this.loadingSpinnerExtent,
  });
}

/// Base tint for [KasyButton] press/hover feedback before alpha is applied.
///
/// Priority: visible custom border → opaque custom fill → label colour.
@visibleForTesting
Color resolveKasyButtonPressFeedbackTint({
  required Color paletteBackground,
  required Color paletteForeground,
  required Color paletteBorder,
  Color? customBackground,
  Color? customBorder,
}) {
  final Color? border = customBorder != null && customBorder.a > 0.05
      ? customBorder
      : null;
  if (border != null) {
    return border;
  }

  if (customBackground != null && customBackground.a > 0.05) {
    if (customBackground.computeLuminance() > 0.45) {
      return Color.lerp(customBackground, const Color(0xFF0D0D12), 0.18)!;
    }
    return Color.lerp(customBackground, Colors.white, 0.28)!;
  }

  if (paletteBorder.a > 0.05) {
    return paletteBorder;
  }

  return paletteForeground;
}

/// Veil colour for web [KasyButtonPressEffect.both] (alpha included).
@visibleForTesting
Color resolveKasyButtonPressOverlayColor({
  required BuildContext context,
  required Color paletteBackground,
  required Color paletteForeground,
  required Color paletteBorder,
  Color? customBackground,
  Color? customBorder,
  Color? override,
}) {
  if (override != null) {
    return override;
  }
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  final double alpha = isDark ? 0.04 : 0.10;
  return resolveKasyButtonPressFeedbackTint(
    paletteBackground: paletteBackground,
    paletteForeground: paletteForeground,
    paletteBorder: paletteBorder,
    customBackground: customBackground,
    customBorder: customBorder,
  ).withValues(alpha: alpha);
}

