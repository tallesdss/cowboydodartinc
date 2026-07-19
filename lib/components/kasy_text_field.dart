import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Visual treatments for [KasyTextField]:
/// - [primary]   filled (surface) + hairline border + soft shadow
/// - [secondary] elevated fill (contrasts on a surface/card) + border, no shadow
/// - [flat]      surface fill + field-flat border, no shadow (auth / same-color panel)
/// - [tonal]     [surfaceSecondary] fill, no border, no shadow (chrome / header search)
/// - [embedded]  transparent, no border, no shadow
enum KasyTextFieldVariant { primary, secondary, embedded, flat, tonal }

enum KasyTextFieldContentType { text, email, password, phone }

/// Fill for [KasyTextFieldVariant.secondary] / elevated fields on a same-color
/// modal surface (bottom sheet, dialog). Figma `surface/secondary`.
Color kasyElevatedSurfaceInputFill(BuildContext context) =>
    context.colors.surfaceSecondary;

/// Design-system single/multi-line input field.
///
/// Supports form validation via [validator], prefix/suffix icons, and multiline
/// via [maxLines] while keeping the visual field height stable.
///
/// Use [showRequiredIndicator] to append a red asterisk after [label] without
/// baking `*` into the copy (recommended for required fields).
class KasyTextField extends StatefulWidget {
  static const double adjacentFieldSpacing = KasySpacing.md;
  static const double iconSlotExtent = 38;
  static const double iconGlyphSize = 17;

  /// Canonical resting height for a single-line field. Drives the field's
  /// vertical content padding (what the filled/bordered box actually wraps), so
  /// changing this value grows or shrinks the visible box on every platform.
  /// Matches the medium [KasyButton] height (45) so fields, the DatePicker
  /// trigger and the primary action all share one control height.
  static const double singleLineHeight = 45;

  /// Figma `font-size/text-field`: Poppins Regular 16 / 24.
  static const double fieldFontSize = 16;
  static const double fieldLineHeight = 24;

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final String? label;

  /// When true, appends a red `*` after [label] (label text stays separate).
  final bool showRequiredIndicator;
  final String? description;
  final String? errorText;
  final bool isInvalid;
  final KasyTextFieldVariant variant;
  final KasyTextFieldContentType contentType;
  final String? semanticLabel;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final void Function(String?)? onSaved;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefix;
  final Widget? suffix;

  /// Overrides for the fixed affix slot size. When null, each affix uses the
  /// square [iconSlotExtent] slot. Composite fields (e.g. [KasyNumberField])
  /// widen the slot so they can bake breathing room around an inner divider
  /// without relying on `contentPadding`, which Flutter ignores horizontally
  /// once an affix icon is present.
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;

  /// Optional widget rendered to the right of [label] (e.g. a "Forgot password?" link).
  final Widget? labelTrailing;

  /// Override for the field's vertical/horizontal padding. When null, the
  /// design-system default is used (`KasySpacing.md` horizontal; single-line
  /// fields use 0 vertical and take their height from the [singleLineHeight]
  /// SizedBox, multi-line uses `13`). Passing a custom value opts the field out
  /// of the fixed single-line height (e.g. the compact header search).
  final EdgeInsetsGeometry? contentPadding;

  /// Override for the field's drop shadow. When null, the design-system
  /// default is used (single soft shadow on primary mobile variant, nothing
  /// on secondary/embedded/web). Pass an empty list to render no shadow.
  final List<BoxShadow>? boxShadow;

  /// When true (default), the field shows the theme primary-colored focus
  /// border while focused. Set to false to keep the resting border in every
  /// state —
  /// useful for read-only triggers or compact contexts where the focus
  /// affordance would feel noisy.
  final bool focusBorder;

  /// When true, paints the focused (primary) border even though the field holds
  /// no real focus. Composite controls like [KasyDatePicker] use this to show
  /// the trigger as "active" while their overlay is open WITHOUT taking focus —
  /// taking real focus would double up with the wrapper's keyboard focus ring
  /// (a second outline on mouse click) and can be stolen by the overlay after a
  /// moment. No effect on the embedded variant.
  final bool forceFocusBorder;

  /// Forwards to [TextField.enableInteractiveSelection]. When false, the
  /// field renders no caret, suppresses text-selection gestures, and stops
  /// showing the I-beam cursor on web/desktop — handy for read-only triggers
  /// (like [KasyDatePicker]) that should look like an input but feel like a
  /// button.
  final bool enableInteractiveSelection;

  const KasyTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hint,
    this.label,
    this.showRequiredIndicator = false,
    this.description,
    this.errorText,
    this.isInvalid = false,
    this.variant = KasyTextFieldVariant.primary,
    this.contentType = KasyTextFieldContentType.text,
    this.semanticLabel,
    this.autofillHints,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.validator,
    this.onSaved,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.prefix,
    this.suffix,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.labelTrailing,
    this.contentPadding,
    this.boxShadow,
    this.focusBorder = true,
    this.forceFocusBorder = false,
    this.enableInteractiveSelection = true,
  });

  @override
  State<KasyTextField> createState() => _KasyTextFieldState();
}

class _KasyTextFieldState extends State<KasyTextField> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;
  bool _passwordVisible = false;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController!;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
    _effectiveController.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant KasyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (oldWidget.focusNode == null && widget.focusNode != null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      } else if (widget.focusNode == null) {
        _internalFocusNode ??= FocusNode();
      }
    }
    if (oldWidget.controller == widget.controller) return;

    final TextEditingController oldController =
        oldWidget.controller ?? _internalController!;
    oldController.removeListener(_handleTextChanged);

    if (oldWidget.controller == null && widget.controller != null) {
      _internalController?.dispose();
      _internalController = null;
    } else if (widget.controller == null) {
      _internalController ??= TextEditingController();
    }

    _effectiveController.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleTextChanged);
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    if (widget.maxLength == null || !mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool useForm = widget.validator != null || widget.onSaved != null;
    if (!useForm) {
      return _buildField(
        context,
        validationErrorText: null,
        onChanged: widget.onChanged,
      );
    }

    return FormField<String>(
      initialValue: _effectiveController.text,
      enabled: widget.enabled,
      validator: (_) => widget.validator?.call(_effectiveController.text),
      onSaved: (_) => widget.onSaved?.call(_effectiveController.text),
      builder: (FormFieldState<String> field) {
        return _buildField(
          context,
          validationErrorText: field.errorText,
          onChanged: (String value) {
            field.didChange(value);
            widget.onChanged?.call(value);
          },
        );
      },
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String? validationErrorText,
    required ValueChanged<String>? onChanged,
  }) {
    final bool hasErrorText =
        widget.errorText != null && widget.errorText!.trim().isNotEmpty;
    final bool hasValidationError =
        validationErrorText != null && validationErrorText.trim().isNotEmpty;
    final bool hasInvalidState =
        widget.isInvalid || hasErrorText || hasValidationError;
    final String? helperText = hasErrorText
        ? widget.errorText
        : hasValidationError
        ? validationErrorText
        : widget.description;
    final bool hasHelperText =
        helperText != null && helperText.trim().isNotEmpty;
    final bool hasCounter = widget.maxLength != null;
    final bool isDisabled = !widget.enabled;
    final bool isSecondaryVariant =
        widget.variant == KasyTextFieldVariant.secondary;
    final bool isEmbeddedVariant =
        widget.variant == KasyTextFieldVariant.embedded;
    final bool isFlatVariant = widget.variant == KasyTextFieldVariant.flat;
    final bool isTonalVariant = widget.variant == KasyTextFieldVariant.tonal;
    // (No more web-specific padding — the field now uses the same vertical
    // padding on every platform so primary/web TextFields render at the same
    // height as mobile and as the KasyDatePicker trigger.)

    // ── Disabled state: opaque "softened" colors, NOT transparency. ────────
    // Kit-wide rule (see KasyButton): keep the original hue but render it
    // weaker by alpha-blending toward the surface — never use raw opacity,
    // which would leak whatever sits behind the widget. [dimDisabled] takes
    // any base color and returns an opaque, softer version of it (or the
    // color itself when the field is enabled). The [alpha] parameter
    // controls how much of the original color is kept: higher = stronger
    // (closer to the original), lower = softer (closer to the surface).
    final Color blendSurface = context.colors.surface;
    Color dimDisabled(Color base, {double alpha = 0.46}) {
      if (!isDisabled) return base;
      return Color.alphaBlend(base.withValues(alpha: alpha), blendSurface);
    }
    final bool isPassword =
        widget.contentType == KasyTextFieldContentType.password;
    final bool isEmail = widget.contentType == KasyTextFieldContentType.email;
    final bool isPhone =
        widget.contentType == KasyTextFieldContentType.phone ||
        widget.keyboardType == TextInputType.phone;
    final bool resolvedObscureText = isPassword
        ? !_passwordVisible
        : widget.obscureText;
    // Single-line fields with the default padding get a fixed canonical height
    // so they match the medium KasyButton and render identically on every
    // platform. Multi-line fields (minLines set, or maxLines > 1) keep growing
    // with their content; callers that pass a custom [contentPadding] (e.g. the
    // compact header search) are opting into their own height, so the lock is
    // skipped for them.
    final bool isSingleLineField =
        widget.contentPadding == null &&
        widget.minLines == null &&
        (resolvedObscureText || (widget.maxLines ?? 1) == 1);
    // Height of the filled/bordered box = single-line text height + 2× vertical
    // padding. So to hit [singleLineHeight] we back out the padding from it
    // (subtract one text line, halve). This is the only lever that actually
    // stretches the visible box — constraints/SizedBox just pad around it.
    // The text line is forced to exactly [fieldLineHeight] (see the strut on the
    // inner field), so this is deterministic on every renderer/platform:
    // box = fieldLineHeight + 2×padding = singleLineHeight, always (45 → 11px).
    const double singleLineTextHeight = KasyTextField.fieldLineHeight;
    final double singleLineVerticalPadding =
        ((KasyTextField.singleLineHeight - singleLineTextHeight) / 2)
            .clamp(0.0, 60.0);
    final Iterable<String>? resolvedAutofillHints =
        widget.autofillHints ?? _defaultAutofillHints(widget.contentType);
    final TextInputType? resolvedKeyboardType =
        widget.keyboardType ??
        (isEmail
            ? TextInputType.emailAddress
            : isPhone
            ? TextInputType.phone
            : null);
    final List<TextInputFormatter>? resolvedInputFormatters = isPhone
        ? <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            ...?widget.inputFormatters,
          ]
        : widget.inputFormatters;
    final InputDecorationThemeData inputTheme = Theme.of(
      context,
    ).inputDecorationTheme;
    final TextStyle labelBaseStyle =
        inputTheme.labelStyle ??
        context.textTheme.bodyMedium ??
        const TextStyle();
    final TextStyle helperBaseStyle =
        inputTheme.helperStyle ??
        context.textTheme.bodyMedium ??
        const TextStyle();
    final TextStyle errorBaseStyle =
        inputTheme.errorStyle ??
        helperBaseStyle.copyWith(color: context.colors.error);
    final TextStyle hintBaseStyle =
        inputTheme.hintStyle ??
        context.textTheme.bodyMedium ??
        const TextStyle();
    final TextStyle labelStyle = labelBaseStyle.copyWith(
      color: hasInvalidState
          ? context.colors.error
          : dimDisabled(
              labelBaseStyle.color ?? context.colors.fieldLabel,
              alpha: 0.55,
            ),
    );
    final TextStyle descriptionStyle =
        (hasInvalidState ? errorBaseStyle : helperBaseStyle).copyWith(
          color: hasInvalidState
              ? context.colors.error
              : dimDisabled(
                  helperBaseStyle.color ?? context.colors.muted,
                  alpha: 0.45,
                ),
        );
    final BorderRadius fieldRadius = BorderRadius.circular(KasyRadius.md);
    // Contained shadow (no Y offset, negative spread). Renders on every
    // platform — removed the previous `!kIsWeb` guard so web matches mobile
    // and the KasyDatePicker trigger.
    final bool shouldShowShadow =
        !isSecondaryVariant &&
        !isEmbeddedVariant &&
        !isFlatVariant &&
        !isTonalVariant;
    final List<BoxShadow> resolvedShadow =
        KasyShadows.inputField(context, enabled: !isDisabled);
    final TargetPlatform platform = Theme.of(context).platform;
    final bool isApplePlatform =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final double focusedBorderWidth = isApplePlatform ? 1.7 : 1.4;
    final Color focusedBorderColor = context.colors.primary;
    final Color resolvedFocusedBorderColor = hasInvalidState
        ? context.colors.error
        : focusedBorderColor;
    final Color enabledBorderColor = isFlatVariant
        ? KasyShadows.inputFieldFlatBorder(context)
        : KasyShadows.inputFieldRestingBorder(context);
    final Color restingBorderColor = hasInvalidState
        ? context.colors.error
        : enabledBorderColor;
    // Tonal (chrome search) and embedded rest with no stroke; error still draws.
    final double restingBorderWidth =
        (isEmbeddedVariant || (isTonalVariant && !hasInvalidState))
        ? 0
        : hasInvalidState
        ? 1.3
        : 1;
    final InputBorder embeddedBorder = OutlineInputBorder(
      borderRadius: fieldRadius,
      borderSide: BorderSide.none,
    );
    // When forceFocusBorder is set, the always-visible (resting) border adopts
    // the focused look — so a composite trigger reads as "active" without the
    // field ever holding real focus.
    final InputBorder resolvedEnabledBorder =
        (isEmbeddedVariant || (isTonalVariant && !hasInvalidState))
        ? embeddedBorder
        : OutlineInputBorder(
            borderRadius: fieldRadius,
            borderSide: widget.forceFocusBorder
                ? BorderSide(
                    color: resolvedFocusedBorderColor,
                    width: focusedBorderWidth,
                  )
                : BorderSide(
                    color: restingBorderColor,
                    width: restingBorderWidth,
                  ),
          );
    // When focusBorder is disabled, the focused state collapses to the
    // resting border so the field never grows that bright outline. Error
    // states still take priority via resolvedEnabledBorder picking the error
    // color, so invalid fields keep the red highlight.
    final InputBorder resolvedFocusedBorder = !widget.focusBorder
        ? resolvedEnabledBorder
        : isEmbeddedVariant
            ? embeddedBorder
            : OutlineInputBorder(
                borderRadius: fieldRadius,
                borderSide: BorderSide(
                  color: resolvedFocusedBorderColor,
                  width: focusedBorderWidth,
                ),
              );
    final Color surfaceColor = isEmbeddedVariant
        ? Colors.transparent
        : isTonalVariant || isSecondaryVariant
        ? context.colors.surfaceSecondary
        : inputTheme.fillColor ?? context.colors.surface;
    final Color fieldFillColor = isDisabled
        ? surfaceColor.withValues(alpha: context.isDark ? 0.9 : 0.94)
        : surfaceColor;
    // Affix icon tint matches the kit's helper-icon tone (0.62) when the
    // field is enabled. When disabled, dimDisabled blends that base color
    // toward the surface — the icon stays opaque, just less saturated.
    final Color affixBase = context.colors.onSurface.withValues(alpha: 0.62);
    final Color affixColor = dimDisabled(affixBase);
    final Widget? resolvedPrefix = widget.prefix == null
        ? null
        : Center(
            child: IconTheme.merge(
              data: IconThemeData(
                size: KasyTextField.iconGlyphSize,
                color: affixColor,
              ),
              child: widget.prefix!,
            ),
          );
    final Widget? customSuffix = widget.suffix == null
        ? null
        : Center(
            child: IconTheme.merge(
              data: IconThemeData(
                size: KasyTextField.iconGlyphSize,
                color: affixColor,
              ),
              child: widget.suffix!,
            ),
          );
    final Widget? resolvedSuffix =
        customSuffix ??
        (isPassword
            ? Semantics(
                button: true,
                label: _passwordVisible ? 'Hide password' : 'Show password',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.enabled
                      ? () =>
                            setState(() => _passwordVisible = !_passwordVisible)
                      : null,
                  child: SizedBox(
                    width: KasyTextField.iconSlotExtent,
                    height: KasyTextField.iconSlotExtent,
                    child: Center(
                      child: Icon(
                        _passwordVisible ? KasyIcons.eyeOff : KasyIcons.eye,
                        size: KasyTextField.iconGlyphSize,
                        color: affixColor,
                      ),
                    ),
                  ),
                ),
              )
            : null);

    final Color fieldTextColor = dimDisabled(context.colors.fieldForeground);
    final TextStyle fieldTextStyle =
        (context.textTheme.bodyLarge ?? const TextStyle()).copyWith(
      color: fieldTextColor,
      fontSize: KasyTextField.fieldFontSize,
      // Pin the line-height so the text box is a fixed [fieldLineHeight]px;
      // paired with the forced strut on the field below, this makes the control
      // height identical on every renderer (web CanvasKit vs native) and size.
      height: KasyTextField.fieldLineHeight / KasyTextField.fieldFontSize,
    );
    final InputDecoration decoration = InputDecoration(
      isDense: true,
      hintText: widget.hint,
      prefixIcon: resolvedPrefix,
      suffixIcon: resolvedSuffix,
      prefixIconConstraints: resolvedPrefix == null
          ? null
          : widget.prefixIconConstraints ??
              const BoxConstraints.tightFor(
                width: KasyTextField.iconSlotExtent,
                height: KasyTextField.iconSlotExtent,
              ),
      suffixIconConstraints: resolvedSuffix == null
          ? null
          : widget.suffixIconConstraints ??
              const BoxConstraints.tightFor(
                width: KasyTextField.iconSlotExtent,
                height: KasyTextField.iconSlotExtent,
              ),
      // Single-line height comes from this vertical padding (derived from
      // singleLineHeight); multi-line keeps a fixed comfortable padding.
      contentPadding: widget.contentPadding ??
          EdgeInsets.symmetric(
            horizontal: isEmbeddedVariant ? 0 : KasySpacing.md,
            vertical: isSingleLineField ? singleLineVerticalPadding : 13,
          ),
      fillColor: fieldFillColor,
      filled: !isEmbeddedVariant,
      // On web: keep fill unchanged on hover (hoverColor replaces fillColor — don't let
      // Flutter's default semi-transparent hoverColor make the field look transparent).
      hoverColor: kIsWeb ? fieldFillColor : null,
      enabledBorder: resolvedEnabledBorder,
      border: resolvedEnabledBorder,
      disabledBorder: isEmbeddedVariant
          ? embeddedBorder
          : OutlineInputBorder(
              borderRadius: fieldRadius,
              borderSide: BorderSide(color: enabledBorderColor),
            ),
      focusedBorder: resolvedFocusedBorder,
      errorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: context.colors.error, width: 1.3),
      ),
      // Mirrors the focusBorder opt-out: when disabled, the focused-error
      // state reuses the resting error border (no thicker outline on focus).
      focusedErrorBorder: !widget.focusBorder
          ? OutlineInputBorder(
              borderRadius: fieldRadius,
              borderSide: BorderSide(
                color: context.colors.error,
                width: 1.3,
              ),
            )
          : OutlineInputBorder(
              borderRadius: fieldRadius,
              borderSide: BorderSide(
                color: context.colors.error,
                width: focusedBorderWidth,
              ),
            ),
      hintStyle: hintBaseStyle.copyWith(
        // Placeholder dims along with the field via the kit-wide softened
        // color rule (opaque blend toward the surface, not raw opacity).
        color: dimDisabled(
          hintBaseStyle.color ?? context.colors.muted,
          alpha: 0.55,
        ),
      ),
    );
    final Widget innerField = TextField(
      controller: _effectiveController,
      focusNode: _effectiveFocusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      obscureText: resolvedObscureText,
      keyboardType: resolvedKeyboardType,
      autofillHints: resolvedAutofillHints,
      enableSuggestions: !isPassword,
      autocorrect: !isPassword && !isEmail,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: resolvedInputFormatters,
      onChanged: onChanged,
      onSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      minLines: resolvedObscureText ? null : widget.minLines,
      maxLines: resolvedObscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      buildCounter: hasCounter ? _hideInputCounter : null,
      style: fieldTextStyle,
      // Force the line box to exactly [fieldLineHeight] regardless of the font's
      // intrinsic metrics, so the field is the same height on every renderer
      // (web CanvasKit and native disagree by ~1px otherwise) and breakpoint.
      strutStyle: StrutStyle.fromTextStyle(
        fieldTextStyle,
        forceStrutHeight: true,
      ),
      decoration: decoration,
      enableInteractiveSelection: widget.enableInteractiveSelection,
    );
    // TEST: shadow disabled to investigate the visual difference with DatePicker
    final List<BoxShadow>? effectiveBoxShadow = widget.boxShadow ??
        (shouldShowShadow ? resolvedShadow : null);
    final Widget decoratedField = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: fieldRadius,
        boxShadow: effectiveBoxShadow,
      ),
      child: Semantics(
        textField: true,
        enabled: widget.enabled,
        label:
            widget.semanticLabel ?? widget.label ?? widget.hint ?? 'Text field',
        // Force standard visual density so the field renders at the same height
        // on web/desktop as on mobile (Flutter's adaptive density is compact on
        // web and would otherwise shave ~4px). The height itself comes from the
        // vertical contentPadding below — that's what the filled/bordered box
        // wraps, so it grows/shrinks the box you actually see.
        child: Theme(
          data: Theme.of(context).copyWith(
            visualDensity: VisualDensity.standard,
          ),
          child: innerField,
        ),
      ),
    );
    final Widget? labelTrailing = widget.labelTrailing;
    final Widget fieldWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.trim().isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: KasySpacing.sm - 2),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _effectiveFocusNode.requestFocus(),
                    child: Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(text: widget.label!.trim(), style: labelStyle),
                          if (widget.showRequiredIndicator)
                            TextSpan(
                              text: ' *',
                              style: labelStyle.copyWith(
                                color: context.colors.error,
                              ),
                            ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                if (labelTrailing != null) ...[
                  const SizedBox(width: KasySpacing.sm),
                  Align(alignment: Alignment.centerRight, child: labelTrailing),
                ],
              ],
            ),
          ),
          const SizedBox(height: KasySpacing.xs),
        ],
        decoratedField,
        if (hasHelperText || hasCounter) ...[
          const SizedBox(height: KasySpacing.xs),
          Padding(
            padding: const EdgeInsets.only(
              left: KasySpacing.sm - 2,
              right: KasySpacing.sm - 2,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasHelperText)
                  Expanded(
                    child: Text(
                      helperText,
                      style: descriptionStyle,
                      textAlign: TextAlign.left,
                    ),
                  )
                else
                  const Spacer(),
                if (hasCounter) ...[
                  if (hasHelperText) const SizedBox(width: KasySpacing.sm),
                  Text(
                    '${_effectiveController.text.length}/${widget.maxLength}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: dimDisabled(
                        context.colors.onSurface.withValues(alpha: 0.54),
                        alpha: 0.55,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
    return TapRegion(groupId: EditableText, child: fieldWidget);
  }

  Iterable<String>? _defaultAutofillHints(KasyTextFieldContentType type) {
    return switch (type) {
      KasyTextFieldContentType.text => null,
      KasyTextFieldContentType.email => const <String>[AutofillHints.email],
      KasyTextFieldContentType.password => const <String>[
        AutofillHints.password,
      ],
      KasyTextFieldContentType.phone => const <String>[
        AutofillHints.telephoneNumber,
      ],
    };
  }

  Widget? _hideInputCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) {
    return null;
  }
}
