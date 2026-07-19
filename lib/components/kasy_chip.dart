import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/material.dart';

/// Visual hierarchy (emphasis) of a [KasyChip]. Mirrors the HeroUI Chip kit.
enum KasyChipVariant {
  /// High emphasis: solid fill in the type colour.
  primary,

  /// Medium emphasis: neutral grey fill, type-coloured text.
  secondary,

  /// Low emphasis: no fill, type-coloured text (ghost).
  tertiary,

  /// Subtle: soft tinted fill in the type colour, type-coloured text.
  soft,
}

/// Semantic colour of a [KasyChip].
///
/// `neutral` is HeroUI's "default" type (`default` is a reserved word in Dart).
enum KasyChipType { primary, neutral, success, warning, danger }

/// Size of a [KasyChip].
enum KasyChipSize { sm, md, lg }

/// Compact label for statuses, categories and tags.
///
/// A chip is composed of an optional **prefix** (leading icon/widget), a
/// **label**, and an optional **suffix** (trailing icon/widget — commonly a
/// remove/close action via [onSuffixTap]). Style it along three axes:
/// [variant] (emphasis), [type] (semantic colour) and [size].
///
/// ```dart
/// KasyChip(label: 'Completed', type: KasyChipType.success)            // soft green
/// KasyChip(label: 'Pending', variant: KasyChipVariant.primary,
///          type: KasyChipType.warning)                                // solid amber
/// KasyChip(label: 'react', suffixIcon: KasyIcons.close,
///          onSuffixTap: () {})                                        // removable tag
/// ```
class KasyChip extends StatefulWidget {
  const KasyChip({
    super.key,
    required this.label,
    this.variant = KasyChipVariant.soft,
    this.type = KasyChipType.neutral,
    this.size = KasyChipSize.md,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onPressed,
    this.onSuffixTap,
    this.enabled = true,
  });

  final String label;
  final KasyChipVariant variant;
  final KasyChipType type;
  final KasyChipSize size;

  /// Leading widget. Takes precedence over [prefixIcon].
  final Widget? prefix;

  /// Trailing widget. Takes precedence over [suffixIcon].
  final Widget? suffix;

  /// Convenience leading icon (sized/coloured by the chip).
  final IconData? prefixIcon;

  /// Convenience trailing icon (sized/coloured by the chip).
  final IconData? suffixIcon;

  /// Whole-chip tap. When non-null the chip gains a pointer cursor, hover and a
  /// keyboard focus ring.
  final VoidCallback? onPressed;

  /// Independent tap on the suffix — e.g. a remove/close action. Hit-tested
  /// before [onPressed].
  final VoidCallback? onSuffixTap;

  final bool enabled;

  bool get _interactive =>
      enabled && (onPressed != null || onSuffixTap != null);

  @override
  State<KasyChip> createState() => _KasyChipState();
}

class _KasyChipState extends State<KasyChip> {
  bool _hovered = false;

  // ── Per-size geometry (HeroUI Chip spec) ──────────────────────────────────
  double get _height => switch (widget.size) {
        KasyChipSize.lg => 28,
        KasyChipSize.md => 24,
        KasyChipSize.sm => 20,
      };

  // Horizontal inset on a side that holds an icon (HeroUI spec: the glyph sits
  // this far from the edge).
  double get _iconPadH => switch (widget.size) {
        KasyChipSize.lg => 12,
        KasyChipSize.md => 8,
        KasyChipSize.sm => 4,
      };

  // Horizontal inset on a side where the label meets the edge directly. Wider
  // than [_iconPadH] so text always has breathing room — the icon paddings are
  // tuned around a glyph, and a bare label needs more air than a 4px gutter.
  double get _textPadH => switch (widget.size) {
        KasyChipSize.lg => 12,
        KasyChipSize.md => 10,
        KasyChipSize.sm => 8,
      };

  double get _iconSize => switch (widget.size) {
        KasyChipSize.lg => 16,
        KasyChipSize.md => 14,
        KasyChipSize.sm => 12,
      };

  static const double _gap = 2;

  // ── Colour resolution ─────────────────────────────────────────────────────

  ({Color base, Color foreground, Color soft, Color softForeground}) _palette(
    KasyColors c,
  ) {
    return switch (widget.type) {
      KasyChipType.primary => (
          base: c.primary,
          foreground: c.primaryForeground,
          soft: c.primarySoft,
          softForeground: c.primarySoftForeground,
        ),
      // HeroUI "default": neutral grey backbone. No dedicated soft token, so the
      // soft fill is the neutral at half alpha (matches default-soft #ebebec80).
      KasyChipType.neutral => (
          base: c.neutral,
          foreground: c.neutralForeground,
          soft: c.neutral.withValues(alpha: 0.5),
          softForeground: c.neutralForeground,
        ),
      KasyChipType.success => (
          base: c.success,
          foreground: c.successForeground,
          soft: c.successSoft,
          softForeground: c.successSoftForeground,
        ),
      KasyChipType.warning => (
          base: c.warning,
          foreground: c.warningForeground,
          soft: c.warningSoft,
          softForeground: c.warningSoftForeground,
        ),
      KasyChipType.danger => (
          base: c.danger,
          foreground: c.dangerForeground,
          soft: c.dangerSoft,
          softForeground: c.dangerSoftForeground,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final palette = _palette(c);

    // variant → (background, foreground). secondary always sits on the neutral
    // grey fill (HeroUI), with the type colour carried by the text.
    final (Color variantBg, Color variantFg) = switch (widget.variant) {
      KasyChipVariant.primary => (palette.base, palette.foreground),
      KasyChipVariant.secondary => (c.neutral, palette.softForeground),
      KasyChipVariant.tertiary => (Colors.transparent, palette.softForeground),
      KasyChipVariant.soft => (palette.soft, palette.softForeground),
    };

    // Disabled: a clearly-present neutral grey fill + muted text (rather than
    // fading the type colour, which makes a soft fill all but vanish). A light
    // dim signals "inert" while keeping the pill visible. Tertiary stays
    // borderless/transparent — there's no fill to keep.
    final bool disabled = !widget.enabled;
    final Color background = disabled
        ? (widget.variant == KasyChipVariant.tertiary
            ? Colors.transparent
            : c.neutral)
        : variantBg;
    final Color foreground = disabled ? c.muted : variantFg;
    final double opacity = disabled ? 0.85 : 1.0;
    final BorderRadius radius = BorderRadius.circular(_height / 2);

    final TextStyle labelStyle =
        (context.textTheme.labelLarge ?? const TextStyle()).copyWith(
      fontSize: widget.size == KasyChipSize.lg ? 14 : 12,
      height: widget.size == KasyChipSize.lg ? 20 / 14 : 16 / 12,
      fontWeight: FontWeight.w500,
      color: foreground,
    );

    final Widget? leading = widget.prefix ?? _icon(widget.prefixIcon, foreground);
    Widget? trailing = widget.suffix ?? _icon(widget.suffixIcon, foreground);
    if (trailing != null && widget.onSuffixTap != null && widget.enabled) {
      trailing = _SuffixTapTarget(onTap: widget.onSuffixTap!, child: trailing);
    }

    // Tight icon gutter where a slot holds a glyph; wider gutter where the label
    // meets the edge, so text never crowds the pill's rounded ends.
    final EdgeInsets padding = EdgeInsets.only(
      left: leading != null ? _iconPadH : _textPadH,
      right: trailing != null ? _iconPadH : _textPadH,
    );

    Widget chip = Container(
      height: _height,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[leading, const SizedBox(width: _gap)],
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: _gap), trailing],
        ],
      ),
    );

    // Hover scrim (web/desktop) — a subtle foreground wash that works on every
    // variant including transparent tertiary.
    if (widget._interactive && _hovered) {
      chip = Stack(
        children: [
          chip,
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.foreground.withValues(alpha: 0.06),
                borderRadius: radius,
              ),
            ),
          ),
        ],
      );
    }

    chip = Opacity(opacity: opacity, child: chip);

    if (!widget._interactive) return chip;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: KasyFocusRing(
        enabled: widget.onPressed != null,
        onActivate: widget.onPressed,
        borderRadius: radius,
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: chip,
        ),
      ),
    );
  }

  Widget? _icon(IconData? icon, Color color) {
    if (icon == null) return null;
    return Icon(icon, size: _iconSize, color: color);
  }
}

/// Wraps the suffix so its own tap (remove/close) fires without triggering the
/// chip's [KasyChip.onPressed].
class _SuffixTapTarget extends StatelessWidget {
  const _SuffixTapTarget({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
