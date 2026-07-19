import 'package:cowboydodartinc/components/kasy_description.dart';
import 'package:cowboydodartinc/components/kasy_field_error.dart';
import 'package:cowboydodartinc/components/kasy_label.dart';
import 'package:cowboydodartinc/components/kasy_text_field.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';

/// Kasy-styled numeric input (HeroUI NumberField) — a [KasyTextField] with
/// decrement / increment stepper buttons. It inherits the field's label,
/// description, error, focus contour and shadow, so it reads exactly like every
/// other field in the kit.
///
/// The value is changed ONLY through the `+` / `−` steppers — it is read-only
/// and cannot be typed. Allowing free typing would make it a plain TextField and
/// strip the steppers of any purpose. Pressing a stepper focuses the field, so
/// the whole field lights its focus contour (set [showFocusRing] false to opt
/// out).
///
/// Controlled: pass [value] and handle [onChanged]. [min] / [max] clamp the
/// steppers (and grey them out at the bounds); [step] sets the increment.
class KasyNumberField extends StatefulWidget {
  const KasyNumberField({
    super.key,
    this.value,
    this.onChanged,
    this.min,
    this.max,
    this.step = 1,
    this.label,
    this.hint,
    this.description,
    this.errorText,
    this.isInvalid = false,
    this.showRequiredIndicator = false,
    this.enabled = true,
    this.variant = KasyTextFieldVariant.primary,
    this.semanticLabel,
    this.showFocusRing = true,
  });

  final int? value;
  final ValueChanged<int>? onChanged;

  final int? min;
  final int? max;
  final int step;

  final String? label;
  final String? hint;
  final String? description;
  final String? errorText;
  final bool isInvalid;
  final bool showRequiredIndicator;
  final bool enabled;
  final KasyTextFieldVariant variant;
  final String? semanticLabel;

  /// When true (default), the `+` / `−` steppers show a focus contour ring
  /// whenever they hold focus — including after a pointer click, not only
  /// during keyboard navigation. Set to false to opt out of the ring entirely.
  final bool showFocusRing;

  @override
  State<KasyNumberField> createState() => _KasyNumberFieldState();
}

class _KasyNumberFieldState extends State<KasyNumberField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value?.toString() ?? '');
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted && _focusNode.hasFocus != _focused) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void didUpdateWidget(KasyNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the field in sync when the value is driven from outside, without
    // stomping the cursor while the user is mid-edit.
    final String next = widget.value?.toString() ?? '';
    if (widget.value != oldWidget.value && next != _controller.text) {
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  int get _current => int.tryParse(_controller.text) ?? widget.value ?? 0;

  bool get _canDecrement =>
      widget.enabled && (widget.min == null || _current > widget.min!);
  bool get _canIncrement =>
      widget.enabled && (widget.max == null || _current < widget.max!);

  void _commit(int next) {
    final int clamped = next
        .clamp(widget.min ?? next, widget.max ?? next);
    final String text = clamped.toString();
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    widget.onChanged?.call(clamped);
  }

  // Pressing a stepper focuses the field, so the WHOLE field lights its focus
  // contour (same as clicking in to type) — the steppers don't carry their own
  // separate ring.
  void _decrement() {
    _focusNode.requestFocus();
    _commit(_current - widget.step);
  }

  void _increment() {
    _focusNode.requestFocus();
    _commit(_current + widget.step);
  }

  @override
  Widget build(BuildContext context) {
    // Divider colour = the global border token, which is exactly the HeroUI
    // InputGroup divider (#DEDEE0 light) and stays visible in dark (#28282C).
    final Color dividerColor = context.colors.border;

    // HeroUI lays the field out perfectly symmetric: the stepper glyph keeps a
    // 12px gap to the divider, and the value keeps the SAME 12px gap on the
    // other side of it. Flutter ignores horizontal `contentPadding` once an
    // affix icon is present (the value would glue to the slot edge), so we bake
    // that 12px of breathing room into the affix slot itself: a [buttonExtent]
    // tap target hugging the outer edge, plus [dividerGap] of dead space next to
    // the value. The dividers sit on the button's inner edge.
    const double buttonExtent = 40;
    const double dividerGap = KasySpacing.smd; // 12
    const double affixExtent = buttonExtent + dividerGap; // 52

    // The focus contour is the field's OWN border, not a ring on the steppers:
    // clicking + / − focuses the field, so the whole field lights up exactly
    // like clicking in to type. We turn the field's built-in focus border OFF
    // (focusBorder: false) and paint the contour ourselves as the TOP layer, so
    // it sits OVER the two vertical dividers (instead of being sliced by them).
    final TargetPlatform platform = Theme.of(context).platform;
    final bool isApple = platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;
    final bool showContour = widget.showFocusRing && _focused;
    final Color contourColor =
        widget.isInvalid ? context.colors.error : context.colors.primary;

    final Widget field = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        KasyTextField(
          controller: _controller,
          focusNode: _focusNode,
          focusBorder: false, // the contour is the overlay below
          hint: widget.hint,
          isInvalid: widget.isInvalid,
          enabled: widget.enabled,
          variant: widget.variant,
          semanticLabel: widget.semanticLabel ?? widget.label,
          // The value is stepper-only — never typed. The field is read-only and
          // shows no caret/keyboard; it can still take focus (to light the
          // contour) when a stepper is pressed. Typing would turn it into a
          // plain TextField and make the + / − pointless.
          readOnly: true,
          enableInteractiveSelection: false,
          prefixIconConstraints: const BoxConstraints.tightFor(
            width: affixExtent,
            height: KasyTextField.iconSlotExtent,
          ),
          suffixIconConstraints: const BoxConstraints.tightFor(
            width: affixExtent,
            height: KasyTextField.iconSlotExtent,
          ),
          prefix: SizedBox(
            width: affixExtent,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _StepperButton(
                icon: KasyIcons.minus,
                semanticLabel: 'Decrement',
                onTap: _canDecrement ? _decrement : null,
              ),
            ),
          ),
          suffix: SizedBox(
            width: affixExtent,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _StepperButton(
                icon: KasyIcons.add,
                semanticLabel: 'Increment',
                onTap: _canIncrement ? _increment : null,
              ),
            ),
          ),
        ),
        // Full-height vertical dividers on each button's inner edge. They share
        // the resting border colour, so at rest they read as one seamless line
        // top-to-bottom; on focus the contour overlay below paints over their
        // ends, keeping the blue outline unbroken.
        PositionedDirectional(
          start: buttonExtent,
          top: 0,
          bottom: 0,
          width: 1,
          child: ColoredBox(color: dividerColor),
        ),
        PositionedDirectional(
          end: buttonExtent,
          top: 0,
          bottom: 0,
          width: 1,
          child: ColoredBox(color: dividerColor),
        ),
        // Focus contour — the TOP layer, so it covers the dividers' top/bottom
        // ends and reads as a clean, unbroken outline around the whole field.
        if (showContour)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(KasyRadius.md),
                  border: Border.all(
                    color: contourColor,
                    width: isApple ? 1.7 : 1.4,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    final bool hasError = widget.isInvalid && widget.errorText != null;
    if (widget.label == null && !hasError && widget.description == null) {
      return field;
    }

    // Label / description sit at the field's label inset (6px), reusing the
    // kit's form primitives so colours and states match every other field.
    const EdgeInsets aroundInset = EdgeInsets.only(left: KasySpacing.sm - 2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null) ...[
          Padding(
            padding: aroundInset,
            child: KasyLabel(
              widget.label!,
              required: widget.showRequiredIndicator,
              isInvalid: widget.isInvalid,
            ),
          ),
          const SizedBox(height: KasySpacing.xs),
        ],
        field,
        if (hasError) ...[
          const SizedBox(height: KasySpacing.xs),
          Padding(padding: aroundInset, child: KasyFieldError(widget.errorText!)),
        ] else if (widget.description != null) ...[
          const SizedBox(height: KasySpacing.xs),
          Padding(
            padding: aroundInset,
            child: KasyDescription(widget.description!),
          ),
        ],
      ],
    );
  }
}

/// A stepper affix glyph (`+` / `−`). A plain tap target with no ring of its
/// own: tapping it focuses the parent field, which lights the whole-field focus
/// contour. The glyph dims when [onTap] is null (at a min/max bound or disabled).
class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.semanticLabel,
    this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final bool enabled = onTap != null;
    final Color color =
        enabled ? c.onSurface : c.onSurface.withValues(alpha: 0.32);

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 40,
            height: KasyTextField.iconSlotExtent,
            child: Center(child: Icon(icon, size: 18, color: color)),
          ),
        ),
      ),
    );
  }
}
