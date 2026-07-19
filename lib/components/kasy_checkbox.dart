import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/material.dart';

/// Shape of the checkbox box.
enum KasyCheckboxShape {
  /// Rounded square (default).
  roundedSquare,

  /// Fully circular.
  circle,
}

/// Custom visual style for [KasyCheckbox].
///
/// All fields are optional; unset fields fall back to theme defaults.
class KasyCheckboxStyle {
  const KasyCheckboxStyle({
    this.size = 22.0,
    this.shape = KasyCheckboxShape.roundedSquare,
    this.activeColor,
    this.activeGradient,
    this.inactiveColor,
    this.borderColor,
    this.checkColor,
    this.checkedIcon,
    this.uncheckedIcon,
    this.borderWidth = 1.8,
    this.iconPop = false,
  });

  /// Box size in logical pixels.
  final double size;

  final KasyCheckboxShape shape;

  /// Fill when checked. Ignored when [activeGradient] is set.
  final Color? activeColor;

  /// Gradient fill (replaces [activeColor] when set).
  final Gradient? activeGradient;

  /// Fill when unchecked. Defaults to transparent.
  final Color? inactiveColor;

  /// Border when unchecked. Defaults to [KasyColors.outline].
  final Color? borderColor;

  /// Icon colour when checked. Defaults to white.
  final Color? checkColor;

  /// Icon shown when checked. Defaults to [KasyIcons.check].
  final IconData? checkedIcon;

  /// Icon shown when unchecked. When set, both icons swap with a cross-fade.
  final IconData? uncheckedIcon;

  final double borderWidth;

  /// When true, the check icon briefly overshoots the box boundary on check
  /// (uses [Curves.easeOutBack] with an [OverflowBox] wrapper).
  final bool iconPop;
}

// ---------------------------------------------------------------------------
// KasyCheckbox
// ---------------------------------------------------------------------------

/// Kasy-styled checkbox with spring-pop animation.
///
/// **States**: default, invalid ([isInvalid]), disabled ([onChanged] == null).
/// **Custom**: pass a [KasyCheckboxStyle] for full visual control —
/// gradients, circle shape, custom icons.
///
/// Inline label/description: set [label] / [description].
/// List-style layout: use [KasyCheckboxTile].
class KasyCheckbox extends StatefulWidget {
  const KasyCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.description,
    this.isInvalid = false,
    this.style,
  });

  final bool value;

  /// Null → disabled.
  final ValueChanged<bool>? onChanged;

  final String? label;
  final String? description;

  /// Applies error/invalid styling (red tones).
  final bool isInvalid;

  final KasyCheckboxStyle? style;

  bool get _isDisabled => onChanged == null;

  @override
  State<KasyCheckbox> createState() => _KasyCheckboxState();
}

class _KasyCheckboxState extends State<KasyCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fillAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );

    // Spring pop: compress → overshoot → settle
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.80)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.80, end: 1.10)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.10, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_ctrl);

    _fillAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    if (widget.value) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(KasyCheckbox old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      widget.value ? _ctrl.forward(from: 0) : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget box = _CheckboxBox(
      value: widget.value,
      isInvalid: widget.isInvalid,
      isDisabled: widget._isDisabled,
      style: widget.style ?? const KasyCheckboxStyle(),
      scaleAnim: _scaleAnim,
      fillAnim: _fillAnim,
    );

    final bool hasLabel =
        widget.label != null || widget.description != null;

    final VoidCallback? onTap =
        widget._isDisabled ? null : () => widget.onChanged!(!widget.value);

    return KasyFocusRing(
      enabled: onTap != null,
      onActivate: onTap,
      borderRadius: BorderRadius.circular(KasyRadius.sm),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: hasLabel
            ? Row(
                children: [
                  box,
                  const SizedBox(width: KasySpacing.smd),
                  Expanded(child: _LabelColumn(widget: widget)),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(11),
                child: box,
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal sub-widgets
// ---------------------------------------------------------------------------

class _LabelColumn extends StatelessWidget {
  const _LabelColumn({required this.widget});
  final KasyCheckbox widget;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = widget._isDisabled
        ? context.colors.muted
        : context.colors.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Text(
            widget.label!,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        if (widget.description != null) ...[
          if (widget.label != null) const SizedBox(height: 2),
          Text(
            widget.description!,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.muted,
            ),
          ),
        ],
      ],
    );
  }
}

class _CheckboxBox extends StatelessWidget {
  const _CheckboxBox({
    required this.value,
    required this.isInvalid,
    required this.isDisabled,
    required this.style,
    required this.scaleAnim,
    required this.fillAnim,
  });

  final bool value;
  final bool isInvalid;
  final bool isDisabled;
  final KasyCheckboxStyle style;
  final Animation<double> scaleAnim;
  final Animation<double> fillAnim;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final double size = style.size;
    final double radius = style.shape == KasyCheckboxShape.circle
        ? size / 2
        : KasyRadius.sm;
    final double iconSize = size * 0.62;

    // --- Resolved colors ---
    final Color baseActive =
        isInvalid ? c.error : (style.activeColor ?? c.primary);
    final Color activeColor =
        isDisabled ? baseActive.withValues(alpha: 0.42) : baseActive;

    final Color inactiveColor = style.inactiveColor ?? Colors.transparent;

    final Color inactiveBorder = style.borderColor ??
        (isInvalid ? c.error : (isDisabled ? Colors.transparent : c.outline));

    final Color checkColor = style.checkColor ?? Colors.white;

    final IconData checkedIcon = style.checkedIcon ?? KasyIcons.check;

    return AnimatedBuilder(
      animation: scaleAnim,
      builder: (_, child) =>
          Transform.scale(scale: scaleAnim.value, child: child),
      child: AnimatedBuilder(
        animation: fillAnim,
        builder: (context2, child2) {
          final double t = fillAnim.value.clamp(0.0, 1.0);

          // Gradient variant: gradient always present, animate border opacity
          if (style.activeGradient != null) {
            final Color borderC =
                Color.lerp(inactiveBorder, Colors.transparent, t)!;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: style.activeGradient,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: borderC,
                  width: style.borderWidth,
                ),
              ),
              child: Center(
                child: _icon(
                  t: t,
                  checked: checkedIcon,
                  unchecked: style.uncheckedIcon,
                  color: checkColor,
                  size: iconSize,
                  iconPop: style.iconPop,
                ),
              ),
            );
          }

          // Default: interpolate fill and border.
          // Use a hue-matched transparent start to prevent the dark flash that
          // Color.lerp(transparent-black, someColor, t) produces at low t.
          final Color startFill = inactiveColor.a == 0
              ? activeColor.withValues(alpha: 0)
              : inactiveColor;
          final Color fill = Color.lerp(startFill, activeColor, t)!;
          final Color border = isDisabled
              ? Colors.transparent
              : Color.lerp(inactiveBorder, activeColor, t)!;

          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: border, width: style.borderWidth),
            ),
            child: Center(
              child: _icon(
                t: t,
                checked: checkedIcon,
                unchecked: style.uncheckedIcon,
                color: checkColor,
                size: iconSize,
                iconPop: style.iconPop,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _icon({
    required double t,
    required IconData checked,
    required IconData? unchecked,
    required Color color,
    required double size,
    required bool iconPop,
  }) {
    if (unchecked == null) {
      final double effectiveT = iconPop
          ? Curves.easeOutBack.transform(t.clamp(0.0, 1.0))
          : t;
      final Widget iconWidget = Icon(checked, size: size, color: color);
      return OverflowBox(
        maxWidth: iconPop ? size * 1.6 : size,
        maxHeight: iconPop ? size * 1.6 : size,
        child: Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.35 + 0.65 * effectiveT,
            child: iconWidget,
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: Icon(
        key: ValueKey(t > 0.5),
        t > 0.5 ? checked : unchecked,
        size: size,
        color: color,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// KasyCheckboxTile — full-width list row
// ---------------------------------------------------------------------------

/// Full-width tile wrapping [KasyCheckbox] — suitable for settings / consent
/// lists. Provides a larger touch target than [KasyCheckbox] alone.
class KasyCheckboxTile extends StatelessWidget {
  const KasyCheckboxTile({
    super.key,
    required this.value,
    required this.label,
    this.onChanged,
    this.description,
    this.isInvalid = false,
    this.style,
    this.padding = const EdgeInsets.symmetric(
      horizontal: KasySpacing.md,
      vertical: KasySpacing.smd,
    ),
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final String? description;
  final bool isInvalid;
  final KasyCheckboxStyle? style;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: KasyCheckbox(
        value: value,
        onChanged: onChanged,
        label: label,
        description: description,
        isInvalid: isInvalid,
        style: style,
      ),
    );
  }
}
