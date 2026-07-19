import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/material.dart';

/// Size of a [KasySwitch] — track + thumb scale together (HeroUI Switch spec).
enum KasySwitchSize { sm, md, lg }

/// Custom visual style for [KasySwitch].
///
/// Colours and the optional thumb icon only — dimensions come from
/// [KasySwitch.size]. All fields optional; unset fields fall back to theme
/// defaults so a bare `KasySwitch(value: …)` already looks right.
class KasySwitchStyle {
  const KasySwitchStyle({
    this.activeColor,
    this.activeGradient,
    this.inactiveColor,
    this.thumbColor,
    this.thumbIconActive,
    this.thumbIconInactive,
    this.thumbIconColor,
  });

  /// Track fill when on. Ignored when [activeGradient] is set. Defaults to
  /// [KasyColors.primary] (accent).
  final Color? activeColor;

  /// Gradient track fill when on (replaces [activeColor] when set).
  final Gradient? activeGradient;

  /// Track fill when off. Defaults to [KasyColors.neutral] (HeroUI default).
  final Color? inactiveColor;

  /// Thumb fill. Defaults to white.
  final Color? thumbColor;

  /// Icon shown inside the thumb when on. When [thumbIconInactive] is also set
  /// the two cross-fade as the switch toggles.
  final IconData? thumbIconActive;

  /// Icon shown inside the thumb when off.
  final IconData? thumbIconInactive;

  /// Thumb icon colour. Defaults to the resolved track colour so the glyph
  /// reads as a cut-out of the track.
  final Color? thumbIconColor;
}

/// Per-size geometry (HeroUI Switch spec). Track padding is a constant 2px.
class _SwitchMetrics {
  const _SwitchMetrics(this.trackWidth, this.trackHeight);
  final double trackWidth;
  final double trackHeight;

  static const double pad = 2;
  double get thumbSize => trackHeight - pad * 2;

  factory _SwitchMetrics.of(KasySwitchSize size) => switch (size) {
        KasySwitchSize.sm => const _SwitchMetrics(32, 16),
        KasySwitchSize.md => const _SwitchMetrics(40, 20),
        KasySwitchSize.lg => const _SwitchMetrics(48, 24),
      };
}

// ---------------------------------------------------------------------------
// KasySwitch
// ---------------------------------------------------------------------------

/// Kasy-styled on/off switch with a sliding thumb and animated track fill.
///
/// **Sizes**: sm / md / lg (track 32×16 / 40×20 / 48×24 — HeroUI).
/// **States**: default, invalid ([isInvalid]), disabled ([onChanged] == null).
/// **Custom**: pass a [KasySwitchStyle] for colours / gradient / thumb icon.
///
/// Inline label/description: set [label] / [description].
/// List-style layout (label left, switch right): use [KasySwitchTile].
class KasySwitch extends StatefulWidget {
  const KasySwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.size = KasySwitchSize.md,
    this.label,
    this.description,
    this.isInvalid = false,
    this.style,
  });

  final bool value;

  /// Null → disabled.
  final ValueChanged<bool>? onChanged;

  final KasySwitchSize size;
  final String? label;
  final String? description;

  /// Applies error/invalid styling (red track when on).
  final bool isInvalid;

  final KasySwitchStyle? style;

  bool get _isDisabled => onChanged == null;

  @override
  State<KasySwitch> createState() => _KasySwitchState();
}

class _KasySwitchState extends State<KasySwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.value ? 1.0 : 0.0,
    );
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(KasySwitch old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      widget.value ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final KasySwitchStyle style = widget.style ?? const KasySwitchStyle();
    final _SwitchMetrics m = _SwitchMetrics.of(widget.size);
    final VoidCallback? onTap =
        widget._isDisabled ? null : () => widget.onChanged!(!widget.value);

    final Widget track = _SwitchTrack(
      isInvalid: widget.isInvalid,
      isDisabled: widget._isDisabled,
      style: style,
      metrics: m,
      slide: _slide,
    );

    final Widget focusedTrack = KasyFocusRing(
      enabled: onTap != null,
      onActivate: onTap,
      borderRadius: BorderRadius.circular(m.trackHeight / 2),
      child: track,
    );

    final bool hasLabel =
        widget.label != null || widget.description != null;

    final Widget content = hasLabel
        ? Row(
            children: [
              Expanded(child: _LabelColumn(widget: widget)),
              const SizedBox(width: KasySpacing.smd),
              focusedTrack,
            ],
          )
        : focusedTrack;

    return MouseRegion(
      cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          container: true,
          toggled: widget.value,
          enabled: !widget._isDisabled,
          label: widget.label,
          child: content,
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
  final KasySwitch widget;

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

class _SwitchTrack extends StatelessWidget {
  const _SwitchTrack({
    required this.isInvalid,
    required this.isDisabled,
    required this.style,
    required this.metrics,
    required this.slide,
  });

  final bool isInvalid;
  final bool isDisabled;
  final KasySwitchStyle style;
  final _SwitchMetrics metrics;
  final Animation<double> slide;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final double trackRadius = metrics.trackHeight / 2;

    // On = accent (or error when invalid); off = neutral grey — HeroUI.
    final Color baseActive =
        isInvalid ? c.error : (style.activeColor ?? c.primary);
    final Color activeTrack =
        isDisabled ? baseActive.withValues(alpha: 0.45) : baseActive;
    final Color baseInactive = style.inactiveColor ?? c.neutral;
    final Color inactiveTrack =
        isDisabled ? baseInactive.withValues(alpha: 0.5) : baseInactive;

    final Color thumbColor = (style.thumbColor ?? Colors.white)
        .withValues(alpha: isDisabled ? 0.9 : 1.0);

    return AnimatedBuilder(
      animation: slide,
      builder: (context, _) {
        final double t = slide.value.clamp(0.0, 1.0);
        final Color track = Color.lerp(inactiveTrack, activeTrack, t)!;

        return SizedBox(
          width: metrics.trackWidth,
          height: metrics.trackHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: track,
                    borderRadius: BorderRadius.circular(trackRadius),
                  ),
                ),
              ),
              if (style.activeGradient != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: t,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: style.activeGradient,
                        borderRadius: BorderRadius.circular(trackRadius),
                      ),
                    ),
                  ),
                ),
              Align(
                alignment:
                    Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, t)!,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _SwitchMetrics.pad,
                  ),
                  child: _Thumb(
                    size: metrics.thumbSize,
                    color: thumbColor,
                    t: t,
                    iconActive: style.thumbIconActive,
                    iconInactive: style.thumbIconInactive,
                    iconColor: style.thumbIconColor ?? activeTrack,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.size,
    required this.color,
    required this.t,
    required this.iconActive,
    required this.iconInactive,
    required this.iconColor,
  });

  final double size;
  final Color color;
  final double t;
  final IconData? iconActive;
  final IconData? iconInactive;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: KasyShadows.switchControlOf(context),
      ),
      child: _thumbIcon(),
    );
  }

  Widget _thumbIcon() {
    if (iconActive == null && iconInactive == null) {
      return const SizedBox.shrink();
    }
    final bool on = t > 0.5;
    final IconData? icon = on ? iconActive : iconInactive;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: icon == null
          ? const SizedBox.shrink()
          : Icon(
              icon,
              key: ValueKey<bool>(on),
              size: size * 0.62,
              color: iconColor,
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// KasySwitchTile — full-width list row
// ---------------------------------------------------------------------------

/// Full-width tile wrapping [KasySwitch] — the canonical settings row: label and
/// description on the left, switch pinned right. Larger touch target than
/// [KasySwitch] alone.
class KasySwitchTile extends StatelessWidget {
  const KasySwitchTile({
    super.key,
    required this.value,
    required this.label,
    this.onChanged,
    this.size = KasySwitchSize.md,
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
  final KasySwitchSize size;
  final String label;
  final String? description;
  final bool isInvalid;
  final KasySwitchStyle? style;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: KasySwitch(
        value: value,
        onChanged: onChanged,
        size: size,
        label: label,
        description: description,
        isInvalid: isInvalid,
        style: style,
      ),
    );
  }
}
