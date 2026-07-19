import 'package:cowboydodartinc/components/kasy_text_field.dart'
    show KasyTextField, KasyTextFieldVariant;
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Kasy Design System — multi-line text area.
///
/// Purpose-built for free-form text input (messages, notes, descriptions).
/// For single-line inputs use [KasyTextField].
class KasyTextArea extends StatefulWidget {
  static const double adjacentFieldSpacing = KasySpacing.md;

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final String? label;
  final bool showRequiredIndicator;
  final String? description;
  final String? errorText;
  final bool isInvalid;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final void Function(String?)? onSaved;
  final int minLines;
  final int? maxLines;
  final int? maxLength;

  /// Visual treatment — same set as [KasyTextField] (primary / secondary /
  /// flat / embedded). [flat] is the surface fill with a hairline border and
  /// NO shadow. Defaults to [primary].
  final KasyTextFieldVariant variant;

  const KasyTextArea({
    super.key,
    this.controller,
    this.focusNode,
    this.hint,
    this.label,
    this.showRequiredIndicator = false,
    this.description,
    this.errorText,
    this.isInvalid = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.onSaved,
    this.minLines = 4,
    this.maxLines = 8,
    this.maxLength,
    this.variant = KasyTextFieldVariant.primary,
  });

  @override
  State<KasyTextArea> createState() => _KasyTextAreaState();
}

class _KasyTextAreaState extends State<KasyTextArea> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;

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
  void didUpdateWidget(covariant KasyTextArea oldWidget) {
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

  Widget? _hideInputCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !widget.enabled;
    final bool isSecondary = widget.variant == KasyTextFieldVariant.secondary;
    final bool isEmbedded = widget.variant == KasyTextFieldVariant.embedded;
    final bool isFlat = widget.variant == KasyTextFieldVariant.flat;
    final bool isTonal = widget.variant == KasyTextFieldVariant.tonal;
    final bool showShadow = widget.variant == KasyTextFieldVariant.primary;
    final bool hasInvalidState = widget.isInvalid || widget.errorText != null;
    final bool useForm = widget.validator != null || widget.onSaved != null;

    const double disabledLabelOpacity = 0.46;
    const double disabledTextOpacity = 0.56;
    const double disabledDescriptionOpacity = 0.34;
    // Contained shadow — no Y offset, negative spread so the shadow hugs the
    // border instead of leaking a halo below the field. Matches KasyTextField.
    final BoxShadow fieldShadow = BoxShadow(
      color: const Color(0xFF000000).withValues(
        alpha: context.isDark ? 0.28 : 0.11,
      ),
      blurRadius: 3,
      spreadRadius: -1,
    );

    const BorderRadius fieldRadius = BorderRadius.all(
      Radius.circular(KasyRadius.md),
    );
    final TargetPlatform platform = Theme.of(context).platform;
    final bool isApplePlatform =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final double focusedBorderWidth = isApplePlatform ? 1.7 : 1.4;
    final Color focusedBorderColor = context.colors.primary;
    final Color resolvedFocusedBorderColor = hasInvalidState
        ? context.colors.error
        : focusedBorderColor;
    final Color enabledBorderColor = isFlat
        ? KasyShadows.inputFieldFlatBorder(context)
        : KasyShadows.inputFieldRestingBorder(context);
    final Color restingBorderColor = hasInvalidState
        ? context.colors.error
        : enabledBorderColor;
    final double restingBorderWidth =
        (isEmbedded || (isTonal && !hasInvalidState))
        ? 0
        : hasInvalidState
            ? 1.3
            : 1;
    final Color surfaceColor = isEmbedded
        ? Colors.transparent
        : isTonal || isSecondary
            ? context.colors.surfaceSecondary
            : context.colors.surface;
    final Color fieldFillColor = isDisabled
        ? surfaceColor.withValues(alpha: context.isDark ? 0.9 : 0.94)
        : surfaceColor;

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
          : (labelBaseStyle.color ?? context.colors.fieldLabel).withValues(
              alpha: isDisabled ? disabledLabelOpacity : 1,
            ),
    );

    final TextStyle fieldTextStyle =
        (context.textTheme.bodyLarge ?? const TextStyle()).copyWith(
          color: context.colors.fieldForeground.withValues(
            alpha: isDisabled ? disabledTextOpacity : 1,
          ),
          fontSize: KasyTextField.fieldFontSize,
          height: KasyTextField.fieldLineHeight / KasyTextField.fieldFontSize,
        );

    final TextStyle descriptionStyle =
        (hasInvalidState ? errorBaseStyle : helperBaseStyle).copyWith(
          color: hasInvalidState
              ? context.colors.error
              : (helperBaseStyle.color ?? context.colors.muted).withValues(
                  alpha: isDisabled ? disabledDescriptionOpacity : 1,
                ),
        );

    final InputDecoration decoration = InputDecoration(
      isDense: true,
      hintText: widget.hint,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: KasySpacing.smd,
      ),
      fillColor: fieldFillColor,
      filled: true,
      hoverColor: kIsWeb ? fieldFillColor : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(
          color: restingBorderColor,
          width: restingBorderWidth,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(
          color: restingBorderColor,
          width: restingBorderWidth,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: enabledBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(
          color: resolvedFocusedBorderColor,
          width: focusedBorderWidth,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: context.colors.error, width: 1.3),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(
          color: context.colors.error,
          width: focusedBorderWidth,
        ),
      ),
      hintStyle: hintBaseStyle.copyWith(
        color: (hintBaseStyle.color ?? context.colors.muted).withValues(
          alpha: isDisabled ? 0.42 : 1,
        ),
      ),
    );

    final bool hasCounter = widget.maxLength != null;

    final Widget innerField = useForm
        ? TextFormField(
            controller: _effectiveController,
            focusNode: _effectiveFocusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            keyboardType: TextInputType.multiline,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onEditingComplete: widget.onEditingComplete,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            buildCounter: hasCounter ? _hideInputCounter : null,
            style: fieldTextStyle,
            decoration: decoration,
            validator: widget.validator,
            onSaved: widget.onSaved,
          )
        : TextField(
            controller: _effectiveController,
            focusNode: _effectiveFocusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            keyboardType: TextInputType.multiline,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onEditingComplete: widget.onEditingComplete,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            buildCounter: hasCounter ? _hideInputCounter : null,
            style: fieldTextStyle,
            decoration: decoration,
          );

    final bool hasErrorText =
        widget.errorText != null && widget.errorText!.trim().isNotEmpty;
    final bool hasDescriptionText =
        widget.description != null && widget.description!.trim().isNotEmpty;
    final bool hasHelperText = hasErrorText || hasDescriptionText;
    final String? helperText = hasErrorText
        ? widget.errorText
        : hasDescriptionText
        ? widget.description
        : null;

    final Widget areaWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.trim().isNotEmpty) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _effectiveFocusNode.requestFocus(),
            child: Padding(
              padding: const EdgeInsets.only(left: KasySpacing.sm - 2),
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(text: widget.label!.trim(), style: labelStyle),
                    if (widget.showRequiredIndicator)
                      TextSpan(
                        text: ' *',
                        style: labelStyle.copyWith(color: context.colors.error),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: KasySpacing.xs),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: fieldRadius,
            boxShadow: showShadow ? [fieldShadow] : null,
          ),
          // Force standard visual density so the area renders identically on
          // web/desktop and mobile (Flutter's adaptive density is compact on
          // web and would otherwise shrink line spacing). Mirrors KasyTextField.
          child: Theme(
            data: Theme.of(context).copyWith(
              visualDensity: VisualDensity.standard,
            ),
            child: innerField,
          ),
        ),
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
                      helperText!,
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
                      color: context.colors.onSurface.withValues(
                        alpha: isDisabled ? 0.34 : 0.54,
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
    return TapRegion(groupId: EditableText, child: areaWidget);
  }
}
