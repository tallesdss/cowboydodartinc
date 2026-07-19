import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/material.dart';

/// Visual style of a [KasyToggleButton] (HeroUI ToggleButton variant).
///
/// [filled] carries a neutral fill at rest (standard toggle). [ghost] is
/// transparent at rest and only paints a fill on hover/selected — ideal for
/// toolbars and dense UIs.
enum KasyToggleButtonVariant { filled, ghost }

/// Size of a [KasyToggleButton]. Heights 32 / 36 / 40, all fully rounded.
enum KasyToggleButtonSize { sm, md, lg }

extension _KasyToggleButtonSizeX on KasyToggleButtonSize {
  double get height => switch (this) {
        KasyToggleButtonSize.sm => 32,
        KasyToggleButtonSize.md => 36,
        KasyToggleButtonSize.lg => 40,
      };

  double get paddingH => switch (this) {
        KasyToggleButtonSize.sm => 12,
        KasyToggleButtonSize.md => 16,
        KasyToggleButtonSize.lg => 16,
      };

  // lg steps up to text-base (16/24); sm and md use text-sm (14/20).
  double get fontSize => this == KasyToggleButtonSize.lg ? 16 : 14;
  double get lineHeight => this == KasyToggleButtonSize.lg ? 24 / 16 : 20 / 14;
}

/// Kasy-styled toggle button (HeroUI ToggleButton) — a button that holds an
/// on/off [selected] state, for filters, formatting, or persistent settings.
/// Use [KasySwitch] for a single binary setting and [KasyButton] for momentary
/// actions.
///
/// Provide a [label] (optionally with [prefixIcon] / [suffixIcon]) or, for an
/// icon-only toggle, just an [icon]. Selected paints a soft-accent fill with
/// the accent foreground; disabled ([onChanged] == null) drops to 50% opacity.
class KasyToggleButton extends StatefulWidget {
  const KasyToggleButton({
    super.key,
    this.label,
    required this.selected,
    this.onChanged,
    this.variant = KasyToggleButtonVariant.filled,
    this.size = KasyToggleButtonSize.md,
    this.prefixIcon,
    this.suffixIcon,
    this.icon,
    this.borderRadius,
    this.semanticLabel,
  }) : assert(
          label != null || icon != null,
          'Provide a label (optionally with prefix/suffix icons) or an icon.',
        );

  /// Text content. Omit (and pass [icon]) for an icon-only toggle.
  final String? label;

  final bool selected;

  /// Called with the next selected value. Null disables the toggle.
  final ValueChanged<bool>? onChanged;

  final KasyToggleButtonVariant variant;
  final KasyToggleButtonSize size;

  /// Leading / trailing glyphs shown alongside [label].
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  /// Icon-only glyph (used when [label] is null).
  final IconData? icon;

  /// Overrides the pill shape — pass [BorderRadius.zero] when the button sits
  /// inside an attached [KasyToggleButtonGroup] segmented control.
  final BorderRadius? borderRadius;

  final String? semanticLabel;

  bool get _iconOnly => label == null && icon != null;
  bool get _enabled => onChanged != null;

  @override
  State<KasyToggleButton> createState() => _KasyToggleButtonState();
}

class _KasyToggleButtonState extends State<KasyToggleButton> {
  bool _hovered = false;

  Color _backgroundColor(KasyColors c) {
    final bool hovered = _hovered && widget._enabled;
    if (widget.selected) {
      return hovered ? c.primarySoftHover : c.primarySoft;
    }
    switch (widget.variant) {
      case KasyToggleButtonVariant.filled:
        return hovered ? c.neutralHover : c.neutral;
      case KasyToggleButtonVariant.ghost:
        // Transparent at rest, neutral fill on hover.
        return hovered ? c.neutral : Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final KasyToggleButtonSize size = widget.size;
    const double iconSize = 16;
    final Color fg =
        widget.selected ? c.primarySoftForeground : c.onSurface;

    final TextStyle textStyle =
        (context.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontSize: size.fontSize,
      height: size.lineHeight,
      fontWeight: FontWeight.w500,
      color: fg,
    );

    final List<Widget> children = widget._iconOnly
        ? <Widget>[Icon(widget.icon, size: iconSize, color: fg)]
        : <Widget>[
            if (widget.prefixIcon != null)
              Icon(widget.prefixIcon, size: iconSize, color: fg),
            Text(widget.label!, style: textStyle),
            if (widget.suffixIcon != null)
              Icon(widget.suffixIcon, size: iconSize, color: fg),
          ];

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: children,
    );

    // Geometry is content-driven and identical across states, so the hover
    // colour change never resizes the control (a resizing control under the
    // pointer ping-pongs enter/exit and flickers). Icon-only is a fixed square;
    // a labelled toggle hugs its content behind horizontal padding.
    final Widget inner = widget._iconOnly
        ? SizedBox(
            width: size.height,
            height: size.height,
            child: Center(child: content),
          )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: size.paddingH),
            child: content,
          );

    // Pill by default; an attached group passes BorderRadius.zero so cells sit
    // flush and the group clips the outer corners.
    final BorderRadius radius =
        widget.borderRadius ?? BorderRadius.circular(size.height / 2);

    // Instant colour change (no implicit animation): a fade between a
    // transparent (ghost rest) and an opaque fill reads as a flicker as the
    // pointer crosses adjacent toggles. Geometry stays constant across states.
    Widget button = Container(
      height: size.height,
      constraints: BoxConstraints(minWidth: size.height),
      decoration: BoxDecoration(
        color: _backgroundColor(c),
        borderRadius: radius,
      ),
      child: inner,
    );

    if (!widget._enabled) {
      button = Opacity(opacity: 0.5, child: button);
    }

    return Semantics(
      button: true,
      toggled: widget.selected,
      enabled: widget._enabled,
      label: widget.semanticLabel ?? widget.label,
      child: KasyFocusRing(
        enabled: widget._enabled,
        onActivate:
            widget._enabled ? () => widget.onChanged!(!widget.selected) : null,
        borderRadius: radius,
        child: MouseRegion(
          cursor: widget._enabled
              ? SystemMouseCursors.click
              : MouseCursor.defer,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: widget._enabled
                ? () => widget.onChanged!(!widget.selected)
                : null,
            behavior: HitTestBehavior.opaque,
            child: button,
          ),
        ),
      ),
    );
  }
}
