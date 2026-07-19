import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double _kCellSize = 44.0;
const double _kCellGap = KasySpacing.sm;

/// Width between digit groups when the stroke separator is hidden ([separatorStrokeVisible] false).
const double _kHiddenSeparatorGapWidth = KasySpacing.sm;

/// Neutral canvas fill for [KasyTextFieldOTP.neutralFlatCells] — soft-button tones, flat (no shadow).
Color _neutralFlatOtpFill(BuildContext context) =>
    context.isDark ? const Color(0xFF272729) : const Color(0xFFEBEBED);

/// Modern OTP / verification-code input.
///
/// Uses a **single hidden TextField** behind purely visual cells, which
/// eliminates keyboard flicker when advancing between digits and gives
/// native backspace behaviour out of the box.
///
/// ```dart
/// KasyTextFieldOTP(
///   length: 6,
///   separatorAfterIndex: 2,   // [0][1][2] — [3][4][5]
///   onCompleted: (code) => verify(code),
/// )
/// ```
class KasyTextFieldOTP extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;
  final bool enabled;
  final bool hasError;
  final String? placeholder;

  /// Overrides default enabled fill ([KasyColors.surface]) unless [neutralFlatCells] is true.
  final Color? cellFillColor;

  /// Soft neutral fill (#EBEBED / #272729) without cell shadow — opt-in (placeholder row / sheet).
  final bool neutralFlatCells;

  /// Drops cell shadow while keeping default borders and caret — pair with [cellFillColor] e.g. transparent.
  final bool suppressCellShadow;

  /// When [separatorAfterIndex] is set: keep only spacing between groups (no middle stroke widget).
  final bool separatorStrokeVisible;

  /// Focused cell uses no accent outline (caret / digits unchanged); errors still show border.
  final bool suppressFocusBorder;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  /// Insert a dash separator after this zero-based cell index.
  final int? separatorAfterIndex;

  /// Horizontal gap between digit cells (default matches kit spacing sm).
  final double cellGap;

  const KasyTextFieldOTP({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.autofocus = false,
    this.enabled = true,
    this.hasError = false,
    this.placeholder,
    this.cellFillColor,
    this.neutralFlatCells = false,
    this.suppressCellShadow = false,
    this.separatorStrokeVisible = true,
    this.suppressFocusBorder = false,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.separatorAfterIndex,
    this.cellGap = _kCellGap,
  });

  static double visualWidthFor({
    int length = 6,
    int? separatorAfterIndex,
    double cellGap = _kCellGap,
    bool separatorStrokeVisible = true,
  }) {
    final int visibleGaps = length > 1 ? length - 1 : 0;
    final bool hasSeparator =
        separatorAfterIndex != null &&
        separatorAfterIndex >= 0 &&
        separatorAfterIndex < length - 1;
    final int simpleGaps = hasSeparator ? visibleGaps - 1 : visibleGaps;
    final double separatorWidth = hasSeparator
        ? (separatorStrokeVisible
              ? _OTPSeparator.visualWidth
              : _kHiddenSeparatorGapWidth)
        : 0.0;

    return length * _kCellSize + simpleGaps * cellGap + separatorWidth;
  }

  @override
  State<KasyTextFieldOTP> createState() => _KasyTextFieldOTPState();
}

class _KasyTextFieldOTPState extends State<KasyTextFieldOTP> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    _controller.addListener(_onChanged);
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  void _onChanged() {
    final v = _controller.text;
    setState(() {});
    widget.onChanged?.call(v);
    if (v.length == widget.length) widget.onCompleted?.call(v);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String value = _controller.text;
    final bool focused = widget.enabled && _focusNode.hasFocus;

    final bool isApple =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;
    final Color focusColor = context.colors.primary;
    final double focusBorderWidth = isApple ? 1.7 : 1.4;
    final Color errorColor = context.colors.error;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double visualWidth = KasyTextFieldOTP.visualWidthFor(
          length: widget.length,
          separatorAfterIndex: widget.separatorAfterIndex,
          cellGap: widget.cellGap,
          separatorStrokeVisible: widget.separatorStrokeVisible,
        );
        final double width =
            constraints.maxWidth.isFinite && constraints.maxWidth < visualWidth
            ? constraints.maxWidth
            : visualWidth;
        final double reservedWidth = _reservedWidthFor(
          length: widget.length,
          separatorAfterIndex: widget.separatorAfterIndex,
          cellGap: widget.cellGap,
          separatorStrokeVisible: widget.separatorStrokeVisible,
        );
        final double maxCellSize = (width - reservedWidth) / widget.length;
        final double availableCellSize = maxCellSize.isFinite
            ? maxCellSize
            : _kCellSize;
        final double cellSize = availableCellSize.clamp(36.0, _kCellSize);

        return SizedBox(
          width: width,
          height: _kCellSize,
          child: Stack(
            children: [
              // Visual cells row.
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildCells(
                      value: value,
                      focused: focused,
                      cellSize: cellSize,
                      enabled: widget.enabled,
                      placeholder: widget.placeholder,
                      cellFillColor: widget.cellFillColor,
                      neutralFlatCells: widget.neutralFlatCells,
                      suppressCellShadow: widget.suppressCellShadow,
                      suppressFocusBorder: widget.suppressFocusBorder,
                      focusColor: focusColor,
                      focusBorderWidth: focusBorderWidth,
                      errorColor: errorColor,
                    ),
                  ),
                ),
              ),
              // Single invisible TextField filling the entire widget.
              // Opacity(0) keeps it interactive (touch + keyboard) while fully hidden.
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    maxLength: widget.length,
                    keyboardType: widget.keyboardType ?? TextInputType.number,
                    textCapitalization: widget.textCapitalization,
                    autocorrect: false,
                    enableSuggestions: false,
                    smartDashesType: SmartDashesType.disabled,
                    smartQuotesType: SmartQuotesType.disabled,
                    spellCheckConfiguration:
                        const SpellCheckConfiguration.disabled(),
                    enableInteractiveSelection: false,
                    inputFormatters:
                        widget.inputFormatters ??
                        [FilteringTextInputFormatter.digitsOnly],
                    onTapOutside: (_) => _focusNode.unfocus(),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      // Prevent hover from changing fill on web (field is invisible but
                      // the hover color would bleed through if fillColor is set).
                      hoverColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _reservedWidthFor({
    required int length,
    required int? separatorAfterIndex,
    required double cellGap,
    required bool separatorStrokeVisible,
  }) {
    final int visibleGaps = length > 1 ? length - 1 : 0;
    final bool hasSeparator =
        separatorAfterIndex != null &&
        separatorAfterIndex >= 0 &&
        separatorAfterIndex < length - 1;
    final int simpleGaps = hasSeparator ? visibleGaps - 1 : visibleGaps;
    final double separatorWidth = hasSeparator
        ? (separatorStrokeVisible
              ? _OTPSeparator.visualWidth
              : _kHiddenSeparatorGapWidth)
        : 0.0;

    return simpleGaps * cellGap + separatorWidth;
  }

  List<Widget> _buildCells({
    required String value,
    required bool focused,
    required double cellSize,
    required bool enabled,
    required String? placeholder,
    required Color? cellFillColor,
    required bool neutralFlatCells,
    required bool suppressCellShadow,
    required bool suppressFocusBorder,
    required Color focusColor,
    required double focusBorderWidth,
    required Color errorColor,
  }) {
    final List<Widget> cells = [];

    for (int i = 0; i < widget.length; i++) {
      if (i > 0) {
        if (widget.separatorAfterIndex == i - 1) {
          cells.add(
            widget.separatorStrokeVisible
                ? _OTPSeparator(hasError: widget.hasError)
                : const SizedBox(width: _kHiddenSeparatorGapWidth),
          );
        } else {
          cells.add(SizedBox(width: widget.cellGap));
        }
      }

      final String digit = i < value.length ? value[i] : '';
      final bool cellFocused = focused && value.length == i;

      cells.add(
        SizedBox.square(
          dimension: cellSize,
          child: _OTPCell(
            digit: digit,
            isFocused: cellFocused,
            hasError: widget.hasError,
            enabled: enabled,
            placeholder: placeholder,
            cellFillColor: cellFillColor,
            neutralFlatCells: neutralFlatCells,
            suppressCellShadow: suppressCellShadow,
            suppressFocusBorder: suppressFocusBorder,
            focusColor: focusColor,
            focusBorderWidth: focusBorderWidth,
            errorColor: errorColor,
          ),
        ),
      );
    }

    return cells;
  }
}

// ─── Internal widgets ────────────────────────────────────────────────────────

class _OTPSeparator extends StatelessWidget {
  static const double visualWidth = KasySpacing.smd * 2 + 10;

  final bool hasError;

  const _OTPSeparator({this.hasError = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KasySpacing.smd),
      child: Center(
        child: Container(
          width: 10,
          height: 2,
          decoration: BoxDecoration(
            color: hasError
                ? context.colors.error
                : context.colors.onSurface.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(KasyRadius.full),
          ),
        ),
      ),
    );
  }
}

class _OTPCell extends StatelessWidget {
  final String digit;
  final bool isFocused;
  final bool hasError;
  final bool enabled;
  final String? placeholder;
  final Color? cellFillColor;
  final bool neutralFlatCells;
  final bool suppressCellShadow;
  final bool suppressFocusBorder;
  final Color focusColor;
  final double focusBorderWidth;
  final Color errorColor;

  const _OTPCell({
    required this.digit,
    required this.isFocused,
    required this.hasError,
    required this.enabled,
    required this.placeholder,
    required this.cellFillColor,
    required this.neutralFlatCells,
    required this.suppressCellShadow,
    required this.suppressFocusBorder,
    required this.focusColor,
    required this.focusBorderWidth,
    required this.errorColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final double borderWidth;

    if (!enabled) {
      borderColor = Colors.transparent;
      borderWidth = 1;
    } else if (hasError) {
      borderColor = errorColor;
      borderWidth = 1.5;
    } else if (isFocused && !suppressFocusBorder) {
      borderColor = focusColor;
      borderWidth = focusBorderWidth;
    } else {
      borderColor = Colors.transparent;
      borderWidth = 1;
    }

    final Color fillColor = !enabled
        ? context.colors.surface.withValues(alpha: context.isDark ? 0.9 : 0.94)
        : neutralFlatCells
        ? _neutralFlatOtpFill(context)
        : (cellFillColor ?? context.colors.surface);
    final bool suppressShadow =
        enabled && (neutralFlatCells || suppressCellShadow);
    final List<BoxShadow> boxShadow = suppressShadow
        ? <BoxShadow>[]
        : KasyShadows.inputField(context, enabled: enabled);

    final TextStyle digitStyle =
        (context.textTheme.titleLarge ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w700,
          color: enabled
              ? context.colors.onSurface
              : context.colors.muted.withValues(alpha: 0.62),
        );
    final TextStyle placeholderStyle = digitStyle.copyWith(
      color: enabled
          ? context.colors.muted.withValues(alpha: 0.64)
          : context.colors.muted.withValues(alpha: 0.58),
    );
    final String? visiblePlaceholder = digit.isEmpty && placeholder != null
        ? placeholder
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(KasyRadius.md),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: boxShadow,
      ),
      child: Center(
        child: ClipRect(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            reverseDuration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.34),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: isFocused && digit.isEmpty
                ? _BlinkingCursor(
                    key: const ValueKey<String>('cursor'),
                    color: context.colors.muted,
                  )
                : visiblePlaceholder != null
                ? Text(
                    visiblePlaceholder,
                    key: ValueKey<String>('placeholder-$visiblePlaceholder'),
                    style: placeholderStyle,
                  )
                : Text(digit, key: ValueKey<String>(digit), style: digitStyle),
          ),
        ),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  final Color color;

  const _BlinkingCursor({super.key, required this.color});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 1.5,
        height: 18,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(KasyRadius.full),
        ),
      ),
    );
  }
}
