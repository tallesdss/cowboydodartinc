import 'package:cowboydodartinc/components/kasy_bottom_sheet.dart';
import 'package:cowboydodartinc/components/kasy_dialog.dart';
import 'package:cowboydodartinc/components/kasy_text_field.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Presentation + sizing
// ─────────────────────────────────────────────────────────────────────────────
const double _kDialogTimePickerWidth = 320;
const double _kWheelItemExtent = 40;
const double _kWheelHeight = 200;
const double _kWheelColumnWidth = 64;
const double _kEstimatedPanelHeight = 260;

/// How the time picker opens when the trigger field is tapped.
///
/// When [KasyTimePicker.presentation] is omitted, the picker picks
/// [popover] on desktop (>= [DeviceType.large]) and [bottomSheet] on phone
/// and tablet. Pass an explicit value to override.
enum KasyTimePickerPresentation {
  /// Floating overlay anchored below the trigger.
  /// Adaptive default on desktop.
  popover,

  /// Modal dialog centered on screen.
  dialog,

  /// Modal bottom sheet sliding up from the bottom.
  /// Adaptive default on phone and tablet.
  bottomSheet,
}

int _snapMinute(int minute, int interval) {
  final int step = interval < 1 ? 1 : interval;
  if (step <= 1) return minute.clamp(0, 59);
  final int snapped = ((minute / step).round() * step) % 60;
  return snapped;
}

List<int> _minuteValues(int interval) {
  final int step = interval < 1 ? 1 : interval;
  if (step <= 1) {
    return [for (int m = 0; m < 60; m++) m];
  }
  return [for (int m = 0; m < 60; m += step) m];
}

String _defaultFormatTime(TimeOfDay time, {required bool use24HourFormat}) {
  if (use24HourFormat) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
  final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final String period =
      time.period == DayPeriod.am ? t.time_picker.am : t.time_picker.pm;
  return '${hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')} $period';
}

// ─────────────────────────────────────────────────────────────────────────────
// Imperative API
// ─────────────────────────────────────────────────────────────────────────────

/// Opens the kit time picker and returns the chosen [TimeOfDay], or null when
/// dismissed. Uses a dialog on desktop (no field to anchor a popover) and a
/// bottom sheet on phone / tablet.
Future<TimeOfDay?> showKasyTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  bool? use24HourFormat,
  int minuteInterval = 1,
  String? title,
}) {
  final bool use24 =
      use24HourFormat ?? MediaQuery.alwaysUse24HourFormatOf(context);
  final bool desktop =
      MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;
  final String resolvedTitle = title ?? t.time_picker.title;

  if (desktop) {
    return showKasyDialog<TimeOfDay>(
      context: context,
      builder: (ctx) => _KasyTimePickerDialog(
        title: resolvedTitle,
        initialTime: initialTime,
        use24HourFormat: use24,
        minuteInterval: minuteInterval,
      ),
    );
  }

  return showKasyBottomSheet<TimeOfDay>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _TimePickerBottomSheetContent(
      title: resolvedTitle,
      initialTime: initialTime,
      use24HourFormat: use24,
      minuteInterval: minuteInterval,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// KasyTimePicker — field trigger
// ─────────────────────────────────────────────────────────────────────────────

/// Time picker combining a read-only [KasyTextField] trigger with a modal face.
///
/// Mirrors [KasyDatePicker]: the trigger inherits input styling; tapping opens
/// a popover, dialog or bottom sheet with scroll wheels for hour, minute and
/// (in 12-hour mode) AM/PM.
class KasyTimePicker extends StatefulWidget {
  const KasyTimePicker({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.placeholder,
    this.presentation,
    this.use24HourFormat,
    this.minuteInterval = 1,
    this.formatTime,
    this.showRequiredIndicator = false,
    this.errorText,
    this.isInvalid = false,
    this.description,
    this.variant = KasyTextFieldVariant.primary,
    this.focusBorder = true,
    this.showSuffix = true,
    this.showBarrier = true,
  });

  final String? label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay>? onChanged;
  final bool enabled;
  final String? placeholder;

  /// How the picker opens when the field is tapped.
  ///
  /// When null (the default), uses [KasyTimePickerPresentation.popover] on
  /// desktop and [KasyTimePickerPresentation.bottomSheet] on phone / tablet.
  /// Pass an explicit value to force one presentation on every breakpoint.
  final KasyTimePickerPresentation? presentation;
  final bool? use24HourFormat;

  /// Minute wheel step (1, 5, 10, 15, 30…). Values snap to the nearest step.
  final int minuteInterval;

  /// Custom display formatter for the trigger field. When null, uses the
  /// default 12h / 24h layout.
  final String Function(TimeOfDay time)? formatTime;

  final bool showRequiredIndicator;
  final String? errorText;
  final bool isInvalid;
  final String? description;
  final KasyTextFieldVariant variant;
  final bool focusBorder;
  final bool showSuffix;

  /// Popover only: dimmed scrim behind the panel (matches [KasyDatePicker]).
  final bool showBarrier;

  @override
  State<KasyTimePicker> createState() => _KasyTimePickerState();
}

class _KasyTimePickerState extends State<KasyTimePicker>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _portalController = OverlayPortalController();
  OverlayEntry? _barrierEntry;
  OverlayEntry? _panelEntry;
  final Object _tapGroupId = Object();
  final GlobalKey _fieldKey = GlobalKey();

  late final TextEditingController _displayController;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  bool _triggerActive = false;
  bool _isOpen = false;
  bool _openUp = false;
  double _panelWidth = _kDialogTimePickerWidth;
  TimeOfDay? _pendingPopoverSelection;

  @override
  void initState() {
    super.initState();
    // Empty here: display text depends on MediaQuery / locale, which cannot be
    // read in initState. It is set in didChangeDependencies (see DatePicker).
    _displayController = TextEditingController();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _displayController.text = _displayText();
  }

  @override
  void didUpdateWidget(KasyTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.use24HourFormat != widget.use24HourFormat ||
        oldWidget.formatTime != widget.formatTime) {
      _displayController.text = _displayText();
    }
  }

  @override
  void dispose() {
    _removeOverlayEntries();
    _displayController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Color _popoverBarrierColor(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Colors.black.withValues(alpha: dark ? 0.58 : 0.42);
  }

  void _removeOverlayEntries() {
    _panelEntry?.remove();
    _panelEntry = null;
    _barrierEntry?.remove();
    _barrierEntry = null;
  }

  void _showBarrierAndPanel() {
    if (_barrierEntry != null || _panelEntry != null) return;
    // Root overlay so the scrim covers app chrome. Panel inserted after barrier.
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);

    _barrierEntry = OverlayEntry(
      builder: (BuildContext context) => SizedBox.expand(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _closePopover,
            child: ColoredBox(color: _popoverBarrierColor(context)),
          ),
        ),
      ),
    );
    _panelEntry = OverlayEntry(
      builder: (BuildContext context) => _buildPanelOverlay(context),
    );
    overlay.insert(_barrierEntry!);
    overlay.insert(_panelEntry!);
  }

  bool _resolveUse24HourFormat() =>
      widget.use24HourFormat ?? MediaQuery.alwaysUse24HourFormatOf(context);

  String _formatDisplay(TimeOfDay time) {
    if (widget.formatTime != null) return widget.formatTime!(time);
    return _defaultFormatTime(
      time,
      use24HourFormat: _resolveUse24HourFormat(),
    );
  }

  String _displayText() {
    if (widget.value == null) return '';
    return _formatDisplay(widget.value!);
  }

  String get _resolvedPlaceholder =>
      widget.placeholder ?? t.time_picker.placeholder;

  /// Adaptive default: popover on desktop, bottom sheet on phone / tablet.
  /// Explicit [KasyTimePicker.presentation] always wins.
  KasyTimePickerPresentation get _presentation {
    if (widget.presentation != null) return widget.presentation!;
    final bool desktop = MediaQuery.sizeOf(context).width >=
        DeviceType.large.breakpoint;
    return desktop
        ? KasyTimePickerPresentation.popover
        : KasyTimePickerPresentation.bottomSheet;
  }

  void _togglePicker() {
    if (!widget.enabled) return;
    switch (_presentation) {
      case KasyTimePickerPresentation.popover:
        if (_isOpen) {
          _closePopover();
        } else {
          _openPopover();
        }
      case KasyTimePickerPresentation.dialog:
        _openDialog();
      case KasyTimePickerPresentation.bottomSheet:
        _openBottomSheet();
    }
  }

  TimeOfDay get _initialTime {
    final TimeOfDay base = widget.value ?? TimeOfDay.fromDateTime(DateTime.now());
    return TimeOfDay(
      hour: base.hour,
      minute: _snapMinute(base.minute, widget.minuteInterval),
    );
  }

  void _openPopover() {
    final RenderBox? fieldBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    _panelWidth = fieldBox?.size.width ?? _kDialogTimePickerWidth;

    bool openUp = false;
    if (fieldBox != null) {
      final Offset fieldTopLeft = fieldBox.localToGlobal(Offset.zero);
      final Size viewport = MediaQuery.sizeOf(context);
      final EdgeInsets safe = MediaQuery.viewPaddingOf(context);
      final double fieldBottom = fieldTopLeft.dy + fieldBox.size.height;
      final double spaceBelow = viewport.height - safe.bottom - fieldBottom;
      final double spaceAbove = fieldTopLeft.dy - safe.top;
      if (spaceBelow < _kEstimatedPanelHeight + 8 && spaceAbove > spaceBelow) {
        openUp = true;
      }
    }
    _openUp = openUp;
    _pendingPopoverSelection = _initialTime;
    if (widget.showBarrier) {
      _showBarrierAndPanel();
    } else {
      _portalController.show();
    }
    _animCtrl.forward();
    setState(() {
      _isOpen = true;
      _triggerActive = true;
    });
  }

  void _closePopover() {
    _animCtrl.reverse().then((_) {
      if (!mounted) return;
      _removeOverlayEntries();
      if (_portalController.isShowing) {
        _portalController.hide();
      }
      final TimeOfDay? pending = _pendingPopoverSelection;
      if (pending != null) {
        _pendingPopoverSelection = null;
        _displayController.text = _formatDisplay(pending);
        widget.onChanged?.call(pending);
      }
      setState(() => _triggerActive = false);
    });
    setState(() => _isOpen = false);
  }

  Future<void> _openDialog() async {
    setState(() => _triggerActive = true);
    final TimeOfDay? picked = await showKasyDialog<TimeOfDay>(
      context: context,
      builder: (ctx) => _KasyTimePickerDialog(
        title: t.time_picker.title,
        initialTime: _initialTime,
        use24HourFormat: _resolveUse24HourFormat(),
        minuteInterval: widget.minuteInterval,
      ),
    );
    if (!mounted) return;
    setState(() => _triggerActive = false);
    if (picked != null) {
      _displayController.text = _formatDisplay(picked);
      widget.onChanged?.call(picked);
    }
  }

  Future<void> _openBottomSheet() async {
    setState(() => _triggerActive = true);
    final TimeOfDay? picked = await showKasyBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _TimePickerBottomSheetContent(
        title: t.time_picker.title,
        initialTime: _initialTime,
        use24HourFormat: _resolveUse24HourFormat(),
        minuteInterval: widget.minuteInterval,
      ),
    );
    if (!mounted) return;
    setState(() => _triggerActive = false);
    if (picked != null) {
      _displayController.text = _formatDisplay(picked);
      widget.onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget field = _buildField(context);

    if (_presentation == KasyTimePickerPresentation.popover) {
      return TapRegion(
        groupId: _tapGroupId,
        child: OverlayPortal(
          controller: _portalController,
          overlayChildBuilder: _buildOverlay,
          child: field,
        ),
      );
    }

    return field;
  }

  Widget _buildField(BuildContext context) {
    final KasyColors c = context.colors;
    final bool isDisabled = !widget.enabled;
    final bool hasErrorText =
        widget.errorText != null && widget.errorText!.isNotEmpty;
    final bool hasInvalidState = widget.isInvalid || hasErrorText;
    final String? footerText =
        hasErrorText ? widget.errorText : widget.description;
    final Color labelColor = hasInvalidState ? c.error : c.fieldLabel;
    final Color blendSurface = c.surface;

    Color dimDisabled(Color base, {double alpha = 0.55}) {
      if (!isDisabled) return base;
      return Color.alphaBlend(base.withValues(alpha: alpha), blendSurface);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null && widget.label!.trim().isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: KasySpacing.sm - 2),
            child: Row(
              children: [
                Text(
                  widget.label!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: dimDisabled(labelColor),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.showRequiredIndicator)
                  Text(
                    ' *',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: c.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: KasySpacing.xs),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: MouseRegion(
            cursor: widget.enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: KasyFocusRing(
              onActivate: _togglePicker,
              borderRadius: BorderRadius.circular(KasyRadius.md),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _togglePicker,
                child: IgnorePointer(
                  child: KasyTextField(
                    key: _fieldKey,
                    controller: _displayController,
                    readOnly: true,
                    enabled: widget.enabled,
                    hint: _resolvedPlaceholder,
                    isInvalid: hasInvalidState,
                    variant: widget.variant,
                    focusBorder: widget.focusBorder,
                    forceFocusBorder: widget.focusBorder && _triggerActive,
                    enableInteractiveSelection: false,
                    suffix: widget.showSuffix
                        ? const Icon(KasyIcons.time)
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (footerText != null) ...[
          const SizedBox(height: KasySpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KasySpacing.sm - 2,
            ),
            child: Text(
              footerText,
              style: context.textTheme.bodySmall?.copyWith(
                color:
                    dimDisabled(hasErrorText ? c.error : c.muted, alpha: 0.45),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPanelOverlay(BuildContext context) {
    // Overlay entries lay out with tight full-screen constraints.
    // Stack absorbs them so the panel shrink-wraps (same as DatePicker).
    return TapRegion(
      groupId: _tapGroupId,
      onTapOutside: (_) => _closePopover(),
      child: Stack(
        children: [
          CompositedTransformFollower(
            link: _layerLink,
            targetAnchor:
                _openUp ? Alignment.topLeft : Alignment.bottomLeft,
            followerAnchor:
                _openUp ? Alignment.bottomLeft : Alignment.topLeft,
            offset: _openUp ? const Offset(0, -8) : const Offset(0, 8),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                alignment:
                    _openUp ? Alignment.bottomCenter : Alignment.topCenter,
                child: _TimePickerPanel(
                  width: _panelWidth,
                  initialTime: _initialTime,
                  use24HourFormat: _resolveUse24HourFormat(),
                  minuteInterval: widget.minuteInterval,
                  onChanged: (time) {
                    _pendingPopoverSelection = time;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) => _buildPanelOverlay(context);
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared panel + modal shells
// ─────────────────────────────────────────────────────────────────────────────

class _TimePickerPanel extends StatelessWidget {
  final double width;
  final TimeOfDay initialTime;
  final bool use24HourFormat;
  final int minuteInterval;
  final ValueChanged<TimeOfDay>? onChanged;

  const _TimePickerPanel({
    required this.width,
    required this.initialTime,
    required this.use24HourFormat,
    required this.minuteInterval,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(KasyRadius.lg),
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(KasySpacing.md),
          child: KasyTimePickerFace(
            initialTime: initialTime,
            use24HourFormat: use24HourFormat,
            minuteInterval: minuteInterval,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

/// Commits the current wheel selection whenever the route is dismissed
/// (barrier tap, drag-down, system back). No Cancel / OK chrome.
class _TimePickerDismissScope extends StatefulWidget {
  final TimeOfDay initialTime;
  final Widget Function(
    BuildContext context,
    ValueChanged<TimeOfDay> onChanged,
  ) builder;

  const _TimePickerDismissScope({
    required this.initialTime,
    required this.builder,
  });

  @override
  State<_TimePickerDismissScope> createState() =>
      _TimePickerDismissScopeState();
}

class _TimePickerDismissScopeState extends State<_TimePickerDismissScope> {
  late TimeOfDay _selected = widget.initialTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        Navigator.of(context).pop(_selected);
      },
      child: widget.builder(
        context,
        (TimeOfDay time) => _selected = time,
      ),
    );
  }
}

class _KasyTimePickerDialog extends StatelessWidget {
  final String title;
  final TimeOfDay initialTime;
  final bool use24HourFormat;
  final int minuteInterval;

  const _KasyTimePickerDialog({
    required this.title,
    required this.initialTime,
    required this.use24HourFormat,
    required this.minuteInterval,
  });

  @override
  Widget build(BuildContext context) {
    return _TimePickerDismissScope(
      initialTime: initialTime,
      builder: (context, onChanged) {
        return Material(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(KasyRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: _kDialogTimePickerWidth,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                KasySpacing.md,
                KasySpacing.lg,
                KasySpacing.md,
                KasySpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: context.kasyTextTheme.titleLarge.copyWith(
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: KasySpacing.md),
                  KasyTimePickerFace(
                    initialTime: initialTime,
                    use24HourFormat: use24HourFormat,
                    minuteInterval: minuteInterval,
                    onChanged: onChanged,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimePickerBottomSheetContent extends StatelessWidget {
  final String title;
  final TimeOfDay initialTime;
  final bool use24HourFormat;
  final int minuteInterval;

  const _TimePickerBottomSheetContent({
    required this.title,
    required this.initialTime,
    required this.use24HourFormat,
    required this.minuteInterval,
  });

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return _TimePickerDismissScope(
      initialTime: initialTime,
      builder: (context, onChanged) {
        return Material(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(KasyRadius.xl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const KasyDragHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KasySpacing.md,
                  KasySpacing.sm,
                  KasySpacing.md,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: context.kasyTextTheme.titleLarge.copyWith(
                      color: c.onSurface,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: KasySpacing.md,
                  right: KasySpacing.md,
                  top: KasySpacing.md,
                  bottom: KasySpacing.md + bottomInset,
                ),
                child: KasyTimePickerFace(
                  initialTime: initialTime,
                  use24HourFormat: use24HourFormat,
                  minuteInterval: minuteInterval,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KasyTimePickerFace — scroll wheels (hour · minute · period)
// ─────────────────────────────────────────────────────────────────────────────

/// The interactive time-selection surface. Embed in dialogs, sheets, popovers
/// or custom layouts. Read the final value from [selectedTime] (via a
/// [GlobalKey] on this widget), or listen via [onChanged].
class KasyTimePickerFace extends StatefulWidget {
  const KasyTimePickerFace({
    super.key,
    required this.initialTime,
    required this.use24HourFormat,
    this.minuteInterval = 1,
    this.onChanged,
  });

  final TimeOfDay initialTime;
  final bool use24HourFormat;
  final int minuteInterval;
  final ValueChanged<TimeOfDay>? onChanged;

  @override
  State<KasyTimePickerFace> createState() => KasyTimePickerFaceState();
}

class KasyTimePickerFaceState extends State<KasyTimePickerFace> {
  late int _hour24 = widget.initialTime.hour;
  late int _minute =
      _snapMinute(widget.initialTime.minute, widget.minuteInterval);

  TimeOfDay get selectedTime => TimeOfDay(hour: _hour24, minute: _minute);

  DayPeriod get _period => _hour24 >= 12 ? DayPeriod.pm : DayPeriod.am;

  int get _hourWheel12 {
    final int h = _hour24 % 12;
    return h == 0 ? 12 : h;
  }

  void _emit() => widget.onChanged?.call(selectedTime);

  void _setHour24(int hour) {
    setState(() => _hour24 = hour.clamp(0, 23));
    _emit();
  }

  void _setHour12(int hour12) {
    var hour = hour12 % 12;
    if (_period == DayPeriod.pm) {
      hour += 12;
    }
    _setHour24(hour);
  }

  void _setMinute(int minute) {
    setState(() => _minute = minute.clamp(0, 59));
    _emit();
  }

  void _setPeriod(DayPeriod period) {
    if (period == _period) return;
    setState(() {
      if (period == DayPeriod.pm && _hour24 < 12) {
        _hour24 += 12;
      } else if (period == DayPeriod.am && _hour24 >= 12) {
        _hour24 -= 12;
      }
    });
    _emit();
  }

  String _pad(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final List<int> hourValues = widget.use24HourFormat
        ? [for (int h = 0; h < 24; h++) h]
        : [for (int h = 1; h <= 12; h++) h];
    final List<int> minuteValues = _minuteValues(widget.minuteInterval);
    final int columnCount = widget.use24HourFormat ? 2 : 3;
    final double groupWidth = columnCount * _kWheelColumnWidth;

    return SizedBox(
      height: _kWheelHeight,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: _kWheelItemExtent,
            width: groupWidth,
            decoration: BoxDecoration(
              color: context.colors.muted.withValues(
                alpha: context.isDark ? 0.22 : 0.12,
              ),
              borderRadius: BorderRadius.circular(KasyRadius.md),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: _kWheelColumnWidth,
                child: _TimeWheelColumn(
                  key: ValueKey(
                    widget.use24HourFormat
                        ? 'hour-24'
                        : 'hour-12-${_period.name}',
                  ),
                  values: hourValues,
                  initialValue:
                      widget.use24HourFormat ? _hour24 : _hourWheel12,
                  label: _pad,
                  onChanged:
                      widget.use24HourFormat ? _setHour24 : _setHour12,
                ),
              ),
              SizedBox(
                width: _kWheelColumnWidth,
                child: _TimeWheelColumn(
                  key: ValueKey('minute-${widget.minuteInterval}'),
                  values: minuteValues,
                  initialValue: _minute,
                  label: _pad,
                  onChanged: _setMinute,
                ),
              ),
              if (!widget.use24HourFormat)
                SizedBox(
                  width: _kWheelColumnWidth,
                  child: _TimeWheelColumn(
                    key: const ValueKey('period'),
                    values: const [0, 1],
                    initialValue: _period == DayPeriod.am ? 0 : 1,
                    label: (int v) =>
                        v == 0 ? t.time_picker.am : t.time_picker.pm,
                    onChanged: (int v) => _setPeriod(
                      v == 0 ? DayPeriod.am : DayPeriod.pm,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeWheelColumn extends StatefulWidget {
  const _TimeWheelColumn({
    super.key,
    required this.values,
    required this.initialValue,
    required this.label,
    required this.onChanged,
  });

  final List<int> values;
  final int initialValue;
  final String Function(int value) label;
  final ValueChanged<int> onChanged;

  @override
  State<_TimeWheelColumn> createState() => _TimeWheelColumnState();
}

class _TimeWheelColumnState extends State<_TimeWheelColumn> {
  late final FixedExtentScrollController _controller;
  late int _selected;

  int _indexOf(int value) {
    final int exact = widget.values.indexOf(value);
    if (exact >= 0) return exact;
    // Nearest value when the incoming minute is off-interval.
    int best = 0;
    int bestDelta = (widget.values.first - value).abs();
    for (int i = 1; i < widget.values.length; i++) {
      final int delta = (widget.values[i] - value).abs();
      if (delta < bestDelta) {
        best = i;
        bestDelta = delta;
      }
    }
    return best;
  }

  @override
  void initState() {
    super.initState();
    final int index = _indexOf(widget.initialValue);
    _selected = widget.values[index];
    _controller = FixedExtentScrollController(initialItem: index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0.0, 0.18, 0.82, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: ListWheelScrollView.useDelegate(
        controller: _controller,
        itemExtent: _kWheelItemExtent,
        diameterRatio: 1.4,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          final int next = widget.values[index];
          setState(() => _selected = next);
          widget.onChanged(next);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: widget.values.length,
          builder: (context, index) {
            final int value = widget.values[index];
            final bool selected = value == _selected;
            return Center(
              child: Text(
                widget.label(value),
                style: context.textTheme.titleMedium?.copyWith(
                  color: selected
                      ? context.colors.primary
                      : context.colors.muted,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
