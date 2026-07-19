import 'package:cowboydodartinc/components/kasy_spinner.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_pressable_depth.dart';
import 'package:flutter/material.dart';

/// Semantic tone for [KasyAlert].
enum KasyAlertTone { info, success, warning, danger }

/// Matches [KasyAccordionVariant.surface] horizontal behavior: full width, or
/// compact width from content (centered by parent / preview).
enum KasyAlertWidthMode { full, intrinsic }

/// Alert card used for inline status and feedback messages.
///
/// Visual shell matches [KasyAccordion] `surface` variant: border + soft
/// omnidirectional shadow (no downward offset).
class KasyAlert extends StatelessWidget {
  final String title;
  final String? message;
  final KasyAlertTone tone;
  final bool emphasizeTitleWithTone;
  final Widget? leading;
  final Widget? trailing;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final IconData? icon;
  final bool isLoading;
  final KasyAlertWidthMode widthMode;

  const KasyAlert({
    super.key,
    required this.title,
    this.message,
    this.tone = KasyAlertTone.info,
    this.emphasizeTitleWithTone = false,
    this.leading,
    this.trailing,
    this.borderRadius = KasyRadius.xl,
    this.padding = const EdgeInsets.symmetric(
      horizontal: KasySpacing.smd,
      vertical: KasySpacing.smd,
    ),
    this.icon,
    this.isLoading = false,
    this.widthMode = KasyAlertWidthMode.full,
  });

  static const double _leadingIconLogicalSize = 19;
  static const double _loadingIndicatorSlotSize = 17;

  @override
  Widget build(BuildContext context) {
    final _KasyAlertPalette palette = _resolvePalette(context, tone);
    final bool hasMessage = message != null && message!.trim().isNotEmpty;
    // Inline component header = HeroUI "Body base medium": 16 / w500. Content
    // emphasis, NOT a heading — w500 (Medium), not w600, so the title doesn't
    // read heavier than HeroUI's. (SemiBold is reserved for real headings:
    // overlay/section/page titles.)
    final TextStyle titleStyle =
        context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: emphasizeTitleWithTone
              ? palette.accent
              : context.colors.onSurface,
        ) ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: emphasizeTitleWithTone
              ? palette.accent
              : context.colors.onSurface,
        );
    final TextStyle messageStyle =
        context.textTheme.bodyMedium?.copyWith(
          color: context.colors.onSurface.withValues(alpha: 0.62),
          height: 1.45,
        ) ??
        TextStyle(
          fontSize: 14,
          color: context.colors.onSurface.withValues(alpha: 0.62),
          height: 1.45,
        );
    final double maxTextWidth = _resolveMaxTextWidth(context);
    final Widget leadingWidget = leading ?? _buildLeading(context, palette);
    final CrossAxisAlignment rowCrossAlign = !hasMessage && trailing != null
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final Widget textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: titleStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
        if (hasMessage) ...[
          const SizedBox(height: KasySpacing.xs),
          Text(message!, style: messageStyle),
        ],
      ],
    );
    final Widget row = Row(
      crossAxisAlignment: rowCrossAlign,
      mainAxisSize: widthMode == KasyAlertWidthMode.intrinsic
          ? MainAxisSize.min
          : MainAxisSize.max,
      children: [
        leadingWidget,
        const SizedBox(width: KasySpacing.smd),
        if (widthMode == KasyAlertWidthMode.full)
          Expanded(child: textBlock)
        else
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxTextWidth),
            child: textBlock,
          ),
        if (trailing != null) ...[
          const SizedBox(width: KasySpacing.smd),
          trailing!,
        ],
      ],
    );
    final BoxDecoration decoration = BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: context.colors.outline.withValues(alpha: 0.22)),
      // One soft shadow with no offset: even falloff on every side of the card.
      boxShadow: [KasyShadows.component(context)],
    );
    final Widget shell = DecoratedBox(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(padding: padding, child: row),
      ),
    );
    if (widthMode == KasyAlertWidthMode.intrinsic) {
      return Center(child: IntrinsicWidth(child: shell));
    }
    return shell;
  }

  double _resolveMaxTextWidth(BuildContext context) {
    final double screenW = MediaQuery.sizeOf(context).width;
    const double pageGutter = KasySpacing.pageHorizontalGutter * 2;
    return (screenW - pageGutter - 32).clamp(120, 520);
  }

  Widget _buildLeading(BuildContext context, _KasyAlertPalette palette) {
    if (isLoading) {
      return KasySpinner(
        diameter: _loadingIndicatorSlotSize,
        color: palette.accent,
        softColor: palette.accent.withValues(alpha: 0.25),
      );
    }
    return Icon(
      icon ?? _defaultIconForTone(tone),
      size: _leadingIconLogicalSize,
      color: palette.accent,
    );
  }
}

/// Small rounded action button for inline [KasyAlert] actions (no elevation).
class KasyAlertActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final KasyAlertTone tone;

  const KasyAlertActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = KasyAlertTone.info,
  });

  @override
  Widget build(BuildContext context) {
    final _KasyAlertPalette palette = _resolvePalette(context, tone);
    return KasyPressableDepth(
      onPressed: onPressed,
      semanticLabel: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.accent,
          borderRadius: BorderRadius.circular(KasyRadius.full),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KasySpacing.smd,
            vertical: KasySpacing.sm,
          ),
          child: Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact circular icon action for [KasyAlert] trailing controls.
class KasyAlertCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const KasyAlertCircleButton({
    super.key,
    this.icon = KasyIcons.close,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return KasyPressableDepth(
      onPressed: onPressed,
      semanticLabel: 'Close alert',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.outline.withValues(alpha: 0.26),
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: KasyIconSize.md,
            color: context.colors.onSurface.withValues(alpha: 0.58),
          ),
        ),
      ),
    );
  }
}

class _KasyAlertPalette {
  final Color accent;

  const _KasyAlertPalette({required this.accent});
}

_KasyAlertPalette _resolvePalette(BuildContext context, KasyAlertTone tone) {
  return switch (tone) {
    KasyAlertTone.info => _KasyAlertPalette(accent: context.colors.primary),
    KasyAlertTone.success => _KasyAlertPalette(accent: context.colors.success),
    KasyAlertTone.warning => _KasyAlertPalette(accent: context.colors.warning),
    KasyAlertTone.danger => _KasyAlertPalette(accent: context.colors.error),
  };
}

IconData _defaultIconForTone(KasyAlertTone tone) {
  return switch (tone) {
    KasyAlertTone.info => KasyIcons.error,
    KasyAlertTone.success => KasyIcons.checkCircle,
    KasyAlertTone.warning => KasyIcons.time,
    KasyAlertTone.danger => KasyIcons.error,
  };
}
