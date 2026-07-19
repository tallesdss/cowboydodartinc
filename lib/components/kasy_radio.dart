import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/material.dart';

/// Size of a [KasyRadio] — control diameter + label scale together
/// (HeroUI Radio spec, mirrors [KasySwitch]'s sm/md/lg).
enum KasyRadioSize { sm, md, lg }

/// Visual variant of a [KasyRadio] (HeroUI Radio).
///
/// The two only differ while **unselected**: [primary] is a white raised disc,
/// [secondary] is a filled neutral disc. Selected looks identical in both.
enum KasyRadioVariant { primary, secondary }

extension _RadioSizeX on KasyRadioSize {
  /// Control diameter in logical px — 16 / 20 / 24, aligned to the Switch
  /// track heights so the two components share one size language.
  double get diameter => switch (this) {
        KasyRadioSize.sm => 16,
        KasyRadioSize.md => 20,
        KasyRadioSize.lg => 24,
      };

  /// Centre dot diameter (HeroUI ratio ≈ 0.375 → 6 / 7.5 / 9).
  double get dot => diameter * 0.375;
}

/// Custom visual style for [KasyRadio] / [KasyRadioGroup].
///
/// Colours only — the control diameter comes from [KasyRadio.size]. All fields
/// optional; unset fields fall back to theme defaults.
class KasyRadioStyle {
  const KasyRadioStyle({
    this.activeColor,
    this.borderColor,
    this.dotColor,
  });

  /// Fill + ring colour when selected. Defaults to [KasyColors.primary].
  final Color? activeColor;

  /// Ring colour when unselected. Defaults to [KasyColors.border].
  final Color? borderColor;

  /// Centre dot colour when selected. Defaults to white (accent-foreground).
  final Color? dotColor;
}

// ---------------------------------------------------------------------------
// KasyRadio — a single radio button
// ---------------------------------------------------------------------------

/// Kasy-styled radio button. Selected when [value] equals [groupValue]; tapping
/// reports its own [value] through [onChanged] (Flutter `Radio` semantics).
///
/// Selected = an accent-filled circle with a white centre dot; unselected =
/// a raised white disc ([KasyRadioVariant.primary]) or a filled neutral disc
/// ([KasyRadioVariant.secondary]). **Sizes**: sm / md / lg (control 16 / 20 /
/// 24). **States**: default, invalid ([isInvalid]), disabled
/// ([onChanged] == null).
///
/// Inline label/description: set [label] / [description].
/// Whole set with group label / error: use [KasyRadioGroup].
class KasyRadio<T> extends StatefulWidget {
  const KasyRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.size = KasyRadioSize.md,
    this.variant = KasyRadioVariant.primary,
    this.label,
    this.description,
    this.isInvalid = false,
    this.style,
  });

  final T value;
  final T? groupValue;

  /// Null → disabled.
  final ValueChanged<T?>? onChanged;

  final KasyRadioSize size;
  final KasyRadioVariant variant;
  final String? label;
  final String? description;
  final bool isInvalid;
  final KasyRadioStyle? style;

  bool get _isSelected => value == groupValue;
  bool get _isDisabled => onChanged == null;

  @override
  State<KasyRadio<T>> createState() => _KasyRadioState<T>();
}

class _KasyRadioState<T> extends State<KasyRadio<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _t;
  late final Animation<double> _dotScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget._isSelected ? 1.0 : 0.0,
    );
    _t = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    // Spring pop on the centre dot.
    _dotScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(KasyRadio<T> old) {
    super.didUpdateWidget(old);
    if (old._isSelected != widget._isSelected) {
      widget._isSelected ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final KasyRadioStyle style = widget.style ?? const KasyRadioStyle();
    final double diameter = widget.size.diameter;
    final VoidCallback? onTap =
        widget._isDisabled ? null : () => widget.onChanged!(widget.value);

    final Widget control = _RadioControl(
      isInvalid: widget.isInvalid,
      isDisabled: widget._isDisabled,
      variant: widget.variant,
      diameter: diameter,
      dotSize: widget.size.dot,
      style: style,
      t: _t,
      dotScale: _dotScale,
    );

    final Widget focusedControl = KasyFocusRing(
      enabled: !widget._isDisabled,
      onActivate: onTap,
      borderRadius: BorderRadius.circular(diameter / 2 + 2),
      child: control,
    );

    final bool hasLabel =
        widget.label != null || widget.description != null;

    final Widget content = hasLabel
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nudge the control down so it centres on the first text line.
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: focusedControl,
              ),
              const SizedBox(width: KasySpacing.smd),
              Expanded(child: _LabelColumn(widget: widget)),
            ],
          )
        : focusedControl;

    return MouseRegion(
      cursor:
          widget._isDisabled ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          container: true,
          inMutuallyExclusiveGroup: true,
          checked: widget._isSelected,
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

class _LabelColumn<T> extends StatelessWidget {
  const _LabelColumn({required this.widget});
  final KasyRadio<T> widget;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = widget._isDisabled
        ? context.colors.muted
        : context.colors.onSurface;

    // Label / description scale with the control size (HeroUI text-small /
    // text-medium / text-large). All labels stay Medium (w500).
    final (TextStyle? labelBase, TextStyle? descBase) = switch (widget.size) {
      KasyRadioSize.sm => (
          context.textTheme.bodySmall,
          context.textTheme.labelSmall,
        ),
      KasyRadioSize.md => (
          context.textTheme.bodyMedium,
          context.textTheme.bodySmall,
        ),
      KasyRadioSize.lg => (
          context.textTheme.bodyLarge,
          context.textTheme.bodyMedium,
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Text(
            widget.label!,
            style: labelBase?.copyWith(
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
        if (widget.description != null) ...[
          if (widget.label != null) const SizedBox(height: 2),
          Text(
            widget.description!,
            style: descBase?.copyWith(color: context.colors.muted),
          ),
        ],
      ],
    );
  }
}

class _RadioControl extends StatelessWidget {
  const _RadioControl({
    required this.isInvalid,
    required this.isDisabled,
    required this.variant,
    required this.diameter,
    required this.dotSize,
    required this.style,
    required this.t,
    required this.dotScale,
  });

  final bool isInvalid;
  final bool isDisabled;
  final KasyRadioVariant variant;
  final double diameter;
  final double dotSize;
  final KasyRadioStyle style;
  final Animation<double> t;
  final Animation<double> dotScale;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;

    final Color baseActive =
        isInvalid ? c.error : (style.activeColor ?? c.primary);
    final Color active =
        isDisabled ? baseActive.withValues(alpha: 0.45) : baseActive;

    // Unselected fill: primary = white disc; secondary = filled neutral disc.
    // Error always shows a hollow disc (white) so the red ring reads.
    final Color unselectedFill = isInvalid
        ? c.surface
        : (variant == KasyRadioVariant.secondary ? c.neutral : c.surface);
    final Color unselectedBorder = isInvalid
        ? c.error
        : (style.borderColor ??
            (variant == KasyRadioVariant.secondary
                ? Colors.transparent
                : (isDisabled ? c.border.withValues(alpha: 0.5) : c.border)));
    final Color dotColor = style.dotColor ?? Colors.white;

    return AnimatedBuilder(
      animation: t,
      builder: (context, _) {
        final double p = t.value.clamp(0.0, 1.0);
        // Fill goes white/neutral → accent; the hairline ring fades into accent.
        final Color fill = Color.lerp(unselectedFill, active, p)!;
        final Color border = Color.lerp(unselectedBorder, active, p)!;
        return Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: border),
            boxShadow: <BoxShadow>[
              // HeroUI shadow-field: soft raised edge.
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Transform.scale(
              scale: dotScale.value.clamp(0.0, 1.2),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// KasyRadioTile — full-width list row
// ---------------------------------------------------------------------------

/// Full-width tile wrapping [KasyRadio] — a choice row with control + label +
/// description, the whole row tappable.
class KasyRadioTile<T> extends StatelessWidget {
  const KasyRadioTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    this.onChanged,
    this.size = KasyRadioSize.md,
    this.variant = KasyRadioVariant.primary,
    this.description,
    this.isInvalid = false,
    this.style,
    this.padding = const EdgeInsets.symmetric(
      horizontal: KasySpacing.md,
      vertical: KasySpacing.smd,
    ),
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final KasyRadioSize size;
  final KasyRadioVariant variant;
  final String label;
  final String? description;
  final bool isInvalid;
  final KasyRadioStyle? style;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: KasyRadio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        size: size,
        variant: variant,
        label: label,
        description: description,
        isInvalid: isInvalid,
        style: style,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// KasyRadioGroup — a managed set of options
// ---------------------------------------------------------------------------

/// Layout direction for [KasyRadioGroup].
enum KasyRadioOrientation { vertical, horizontal }

/// One option in a [KasyRadioGroup].
class KasyRadioOption<T> {
  const KasyRadioOption({
    required this.value,
    required this.label,
    this.description,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? description;
  final bool enabled;
}

/// A managed set of mutually-exclusive [options] under a shared group [label]
/// and [description], with an optional [errorText] (HeroUI RadioGroup). Holds
/// the selected [value] and reports the new one through [onChanged]. No card —
/// it composes inline like the HeroUI kit.
class KasyRadioGroup<T> extends StatelessWidget {
  const KasyRadioGroup({
    super.key,
    required this.value,
    required this.options,
    this.onChanged,
    this.size = KasyRadioSize.md,
    this.variant = KasyRadioVariant.primary,
    this.label,
    this.description,
    this.errorText,
    this.orientation = KasyRadioOrientation.vertical,
    this.style,
  });

  final T? value;
  final ValueChanged<T?>? onChanged;
  final List<KasyRadioOption<T>> options;

  final KasyRadioSize size;
  final KasyRadioVariant variant;

  /// Group heading.
  final String? label;

  /// Supporting text under the heading.
  final String? description;

  /// When non-null, the group renders in its error state (red radios) and shows
  /// this message at the bottom.
  final String? errorText;

  final KasyRadioOrientation orientation;
  final KasyRadioStyle? style;

  bool get _isInvalid => errorText != null;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;

    final List<Widget> radios = [
      for (final opt in options)
        KasyRadio<T>(
          value: opt.value,
          groupValue: value,
          onChanged:
              (opt.enabled && onChanged != null) ? onChanged : null,
          size: size,
          variant: variant,
          label: opt.label,
          description: opt.description,
          isInvalid: _isInvalid,
          style: style,
        ),
    ];

    final Widget items = orientation == KasyRadioOrientation.vertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < radios.length; i++) ...[
                if (i > 0) const SizedBox(height: KasySpacing.smd),
                radios[i],
              ],
            ],
          )
        : Wrap(
            spacing: KasySpacing.lg,
            runSpacing: KasySpacing.smd,
            children: radios,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: c.onSurface,
            ),
          ),
        if (description != null) ...[
          const SizedBox(height: 2),
          Text(
            description!,
            style: context.textTheme.bodySmall?.copyWith(color: c.muted),
          ),
        ],
        if (label != null || description != null)
          const SizedBox(height: KasySpacing.smd),
        items,
        if (errorText != null) ...[
          const SizedBox(height: KasySpacing.sm),
          Text(
            errorText!,
            style: context.textTheme.bodySmall?.copyWith(color: c.error),
          ),
        ],
      ],
    );
  }
}
