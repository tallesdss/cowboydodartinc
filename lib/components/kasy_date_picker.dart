import 'dart:math' as math;

import 'package:cowboydodartinc/components/kasy_bottom_sheet.dart';
import 'package:cowboydodartinc/components/kasy_calendar.dart';
import 'package:cowboydodartinc/components/kasy_dialog.dart';
import 'package:cowboydodartinc/components/kasy_text_field.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data helpers
// ─────────────────────────────────────────────────────────────────────────────
const List<String> _kMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const List<String> _kWeekdayAbbreviations = [
  'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat',
];

// ─────────────────────────────────────────────────────────────────────────────
// KasyDateFormat — built-in regional formatting presets
// ─────────────────────────────────────────────────────────────────────────────

/// Built-in date display formats. Pick the one that matches the user's region,
/// or pass [KasyDatePicker.formatDate] for a fully custom layout.
enum KasyDateFormat {
  /// MM / DD / YYYY — United States (en-US).
  us,

  /// DD / MM / YYYY — South America, UK, France, Italy, Spain, Portugal, and
  /// most of Europe. Default for the [KasyDatePickerLocale.es] and
  /// [KasyDatePickerLocale.pt] locales.
  southAmerican,

  /// DD.MM.YYYY — Germany, Austria, Switzerland, Netherlands.
  european,

  /// YYYY-MM-DD — ISO 8601 international standard, common in APIs and logs.
  iso,

  /// YYYY / MM / DD — Japan, China, Korea (East Asian convention).
  eastAsian,
}

String _formatWithPreset(DateTime date, KasyDateFormat preset) {
  final String mm = date.month.toString().padLeft(2, '0');
  final String dd = date.day.toString().padLeft(2, '0');
  final String yyyy = date.year.toString();
  switch (preset) {
    case KasyDateFormat.us:
      return '$mm / $dd / $yyyy';
    case KasyDateFormat.southAmerican:
      return '$dd / $mm / $yyyy';
    case KasyDateFormat.european:
      return '$dd.$mm.$yyyy';
    case KasyDateFormat.iso:
      return '$yyyy-$mm-$dd';
    case KasyDateFormat.eastAsian:
      return '$yyyy / $mm / $dd';
  }
}

String _placeholderFor(KasyDateFormat preset) {
  switch (preset) {
    case KasyDateFormat.us:
      return 'mm / dd / yyyy';
    case KasyDateFormat.southAmerican:
      return 'dd / mm / yyyy';
    case KasyDateFormat.european:
      return 'dd.mm.yyyy';
    case KasyDateFormat.iso:
      return 'yyyy-mm-dd';
    case KasyDateFormat.eastAsian:
      return 'yyyy / mm / dd';
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// KasyDatePickerLocale — calendar display locale
// ─────────────────────────────────────────────────────────────────────────────

/// Controls month names, weekday labels, week start, and month/year separator
/// inside the [KasyDatePicker] calendar overlay.
///
/// Three built-in presets are provided: [KasyDatePickerLocale.en],
/// [KasyDatePickerLocale.pt] and [KasyDatePickerLocale.es]. By default the
/// picker auto-selects one from the app's active language; pass an explicit
/// instance to override (or construct a custom one for another locale).
class KasyDatePickerLocale {
  const KasyDatePickerLocale({
    required this.monthNames,
    required this.weekdayAbbreviations,
    this.weekStartDay = 0,
    this.monthYearSeparator = ' ',
    this.defaultDateFormat = KasyDateFormat.us,
  });

  /// Full month names — 12 entries (January … December order).
  final List<String> monthNames;

  /// Weekday header abbreviations — 7 entries ordered from [weekStartDay].
  /// For Sunday-start: Sun Mon Tue Wed Thu Fri Sat.
  /// For Monday-start: Mon Tue Wed Thu Fri Sat Sun.
  final List<String> weekdayAbbreviations;

  /// First day of the week shown in the calendar grid.
  /// 0 = Sunday (default, en-US), 1 = Monday (most of the world).
  final int weekStartDay;

  /// String inserted between the month name and year in the calendar header.
  /// English: ' ' → "May 2026". Spanish: ' de ' → "mayo de 2026".
  final String monthYearSeparator;

  /// Region-appropriate display format used when [KasyDatePicker.dateFormat]
  /// and [KasyDatePicker.formatDate] are both null. Defaults to
  /// [KasyDateFormat.us] for English and [KasyDateFormat.southAmerican] for
  /// Spanish and Portuguese.
  final KasyDateFormat defaultDateFormat;

  /// English locale — Sunday-first week, US date format.
  static const KasyDatePickerLocale en = KasyDatePickerLocale(
    monthNames: _kMonthNames,
    weekdayAbbreviations: _kWeekdayAbbreviations,
  );

  /// Spanish locale — Monday-first week, South-American date format.
  static const KasyDatePickerLocale es = KasyDatePickerLocale(
    monthNames: [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ],
    weekdayAbbreviations: ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'],
    weekStartDay: 1,
    monthYearSeparator: ' de ',
    defaultDateFormat: KasyDateFormat.southAmerican,
  );

  /// Portuguese (Brazil) locale — Monday-first week, South-American date format.
  static const KasyDatePickerLocale pt = KasyDatePickerLocale(
    monthNames: [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ],
    weekdayAbbreviations: ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'],
    weekStartDay: 1,
    monthYearSeparator: ' de ',
    defaultDateFormat: KasyDateFormat.southAmerican,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// KasyDatePickerPresentation — controls how the calendar is shown
// ─────────────────────────────────────────────────────────────────────────────

/// Comfortable fixed width for the calendar when shown as a centered dialog, so
/// it does not stretch to the dialog inset (nearly full screen) on desktop.
const double _kDialogCalendarWidth = 360;

/// Controls how the calendar is presented when the date field is tapped.
///
/// When [KasyDatePicker.presentation] is omitted, the picker picks
/// [popover] on desktop (>= [DeviceType.large]) and [bottomSheet] on phone
/// and tablet. Pass an explicit value to override.
enum KasyDatePickerPresentation {
  /// Floating overlay anchored below the trigger field.
  /// Adaptive default on desktop.
  popover,

  /// Modal dialog centered on screen.
  dialog,

  /// Modal bottom sheet sliding up from the bottom.
  /// Adaptive default on phone and tablet.
  bottomSheet,
}

// ─────────────────────────────────────────────────────────────────────────────
// KasyDateSelectionMode + KasyDateRange — single vs. start/end selection
// ─────────────────────────────────────────────────────────────────────────────

/// How the user selects dates inside the calendar.
enum KasyDateSelectionMode {
  /// One tap commits a single date (default — back-compat with [value]).
  single,

  /// Two taps commit a start + end date (Airbnb-style range selection). The
  /// calendar stays open until both endpoints are picked, then auto-closes.
  range,
}

/// Immutable start/end pair used in [KasyDateSelectionMode.range]. Either
/// endpoint can be null while the user is still picking.
class KasyDateRange {
  const KasyDateRange({this.start, this.end});

  final DateTime? start;
  final DateTime? end;

  /// True when both endpoints are set — used by the picker to know it can
  /// close the calendar.
  bool get isComplete => start != null && end != null;

  /// True when at least the start is set.
  bool get hasStart => start != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KasyDateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

// ─────────────────────────────────────────────────────────────────────────────
// KasyDatePicker
// ─────────────────────────────────────────────────────────────────────────────

/// Date picker combining a text-field trigger with a floating calendar overlay.
///
/// The trigger reuses [KasyTextField] in read-only mode so it inherits the
/// design-system input look (label, hint, suffix-icon slot, padding, border,
/// shadow). Any change made to [KasyTextField] (e.g. label or placeholder
/// styling) propagates automatically to this component. Tapping the field
/// opens a calendar below the trigger via [OverlayPortal] (popover mode),
/// inside a [showKasyDialog] (dialog mode) or [showKasyBottomSheet] (bottom
/// sheet mode). Selecting a day calls [onChanged] and closes the calendar.
///
/// Usage:
/// ```dart
/// KasyDatePicker(
///   label: 'Date',
///   value: _date,
///   onChanged: (d) => setState(() => _date = d),
/// )
/// ```
class KasyDatePicker extends StatefulWidget {
  const KasyDatePicker({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.range,
    this.onRangeChanged,
    this.selectionMode = KasyDateSelectionMode.single,
    this.minDate,
    this.maxDate,
    this.enabled = true,
    this.placeholder,
    this.presentation,
    this.showRequiredIndicator = false,
    this.errorText,
    this.isInvalid = false,
    this.description,
    this.dateFormat,
    this.formatDate,
    this.locale,
    this.variant = KasyTextFieldVariant.primary,
    this.focusBorder = true,
    this.showSuffix = true,
    this.showBarrier = true,
    this.monthsToShow,
  });

  /// Label displayed above the field. Omit to hide.
  final String? label;

  /// Currently selected date — only used in [KasyDateSelectionMode.single].
  /// Pass null for no selection.
  final DateTime? value;

  /// Called when the user picks a date in [KasyDateSelectionMode.single].
  final ValueChanged<DateTime>? onChanged;

  /// Currently selected start/end pair — only used in
  /// [KasyDateSelectionMode.range]. Pass null for no selection. The picker
  /// keeps the calendar open while the range is still being built, then
  /// closes once both endpoints are set.
  final KasyDateRange? range;

  /// Called when the user updates the range. Fires twice: once with only
  /// [KasyDateRange.start] set (after the first tap), then again with both
  /// endpoints (after the second tap, just before the popover closes).
  final ValueChanged<KasyDateRange>? onRangeChanged;

  /// Whether the picker selects a single date or a start/end range.
  /// Defaults to [KasyDateSelectionMode.single].
  final KasyDateSelectionMode selectionMode;

  /// Earliest selectable date (inclusive).
  final DateTime? minDate;

  /// Latest selectable date (inclusive).
  final DateTime? maxDate;

  final bool enabled;

  /// Placeholder text shown when no date is selected. When null, the
  /// placeholder is derived from the active [KasyDateFormat] preset
  /// (e.g. "mm / dd / yyyy" for [KasyDateFormat.us]).
  final String? placeholder;

  /// How the calendar is presented when the field is tapped.
  ///
  /// When null (the default), uses [KasyDatePickerPresentation.popover] on
  /// desktop and [KasyDatePickerPresentation.bottomSheet] on phone / tablet.
  /// Pass an explicit value to force one presentation on every breakpoint.
  final KasyDatePickerPresentation? presentation;

  /// When true, shows a red `*` after the label.
  final bool showRequiredIndicator;

  /// Error message displayed below the field. Also triggers red border.
  final String? errorText;

  /// When true, shows a red border without an error message.
  final bool isInvalid;

  /// Helper text displayed below the field in muted color.
  final String? description;

  /// Built-in regional format preset. When null (default), falls back to
  /// [KasyDatePickerLocale.defaultDateFormat] so the date follows the locale's
  /// regional convention. Ignored when [formatDate] is provided.
  final KasyDateFormat? dateFormat;

  /// Fully custom date formatter. When provided, overrides [dateFormat] and
  /// the locale default.
  final String Function(DateTime)? formatDate;

  /// Calendar display locale — controls month names, weekday labels, week
  /// start day, and the regional [defaultDateFormat]. When null (default), it
  /// follows the app's active language (pt / es / en) via
  /// [Localizations.localeOf]; pass an explicit preset to override.
  final KasyDatePickerLocale? locale;

  /// Visual variant of the trigger field. Defaults to
  /// [KasyTextFieldVariant.primary] (white surface + soft shadow on mobile).
  /// Use [KasyTextFieldVariant.secondary] for a flat filled look without
  /// shadow, matching the "filled" KasyTextField style.
  final KasyTextFieldVariant variant;

  /// When true (default), the trigger field shows a focus border while the
  /// calendar is open — mirroring the [KasyTextField] focus affordance so
  /// the user clearly sees the field is "active". Set to false to suppress
  /// the focus border in every state.
  final bool focusBorder;

  /// When true (default), the calendar icon is rendered in the trigger's
  /// suffix slot. Set to false to hide the icon (useful for very compact
  /// layouts where the field width is the only affordance).
  final bool showSuffix;

  /// Popover only: when true (default), a dimmed scrim is shown behind the
  /// calendar (matching the dialog/bottom-sheet barriers). Set to false for
  /// a lighter, "tooltip"-style overlay with no backdrop — the page stays
  /// visible and tap-outside still closes the popover.
  final bool showBarrier;

  /// Number of calendar months shown side by side. Defaults to a single
  /// month on every platform — pass an explicit 2 or 3 to opt in to the
  /// multi-month layout (typical on wide web canvases).
  ///
  /// The nav-row layout follows automatically: a single-month picker uses
  /// the compact "month/year left, arrows clustered right" style; a
  /// multi-month picker uses "one arrow per edge, captions centered above
  /// each grid". Callers don't choose the nav style explicitly.
  final int? monthsToShow;

  @override
  State<KasyDatePicker> createState() => _KasyDatePickerState();
}

class _KasyDatePickerState extends State<KasyDatePicker>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _portalController = OverlayPortalController();

  /// Full-screen scrim + panel as sibling [OverlayEntry]s (barrier first, panel
  /// on top). A single barrier entry cannot sit between page content and an
  /// [OverlayPortal] child on the same overlay, so both are manual entries.
  OverlayEntry? _barrierEntry;
  OverlayEntry? _panelEntry;

  // Unique ID so TapRegion knows "field + calendar" form one group.
  final Object _tapGroupId = Object();

  // Key on the trigger field — used to measure its width when opening the popover.
  final GlobalKey _fieldKey = GlobalKey();

  // Drives the trigger's "active" (focused-look) border while the calendar or
  // overlay is open. We deliberately do NOT focus the field for this: real
  // focus would (a) light the wrapping KasyFocusRing's keyboard ring on a mouse
  // click — a second outline — and (b) get stolen by the overlay after a
  // moment, dropping the border. KasyTextField.forceFocusBorder paints it from
  // this flag instead, so it stays put for as long as the calendar is open.
  bool _triggerActive = false;

  // Controller backing the trigger KasyTextField — text mirrors the formatted
  // date (or stays empty so the hint renders).
  late final TextEditingController _displayController;

  bool _isOpen = false;

  // Selection picked inside the popover but not yet committed to the parent.
  // We keep it parked while the close animation runs so the cell does NOT
  // flip to its primary state mid-fade — the press feedback stays visible on
  // the original (non-selected) cell, matching the dialog/bottom sheet UX.
  // The actual commit happens at the end of the fade-out, so no artificial
  // delay is introduced (we just piggy-back on the existing 180ms animation).
  DateTime? _pendingPopoverSelection;

  /// Same trick as [_pendingPopoverSelection] but for range-mode completion:
  /// we park the completed range and commit it only after the fade-out so the
  /// press feedback stays visible on the second-tap cell during the close.
  KasyDateRange? _pendingPopoverRange;

  // Width of the trigger field, read at open time.
  double _calendarWidth = 288;

  // When true, the popover renders ABOVE the trigger instead of below.
  // Computed at open time based on available space.
  bool _openUp = false;

  // Conservative estimate of the calendar panel height. Kept on the high side
  // (real layout measures ~460px) so the flip-up logic in _open() errs on the
  // safe side — if there's any doubt, prefer opening above to avoid being
  // clipped by the bottom of the screen.
  static const double _kEstimatedCalendarHeight = 460;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    // Empty here: the display text depends on the locale (Localizations), which
    // can't be read in initState. It's set in didChangeDependencies below.
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
    // Reads the locale (legal here, not in initState) to format the field, and
    // re-runs if the app language changes so the displayed date follows it.
    _displayController.text = _displayText();
  }

  @override
  void didUpdateWidget(KasyDatePicker old) {
    super.didUpdateWidget(old);
    final bool selectionChanged = old.value != widget.value ||
        old.range != widget.range ||
        old.selectionMode != widget.selectionMode;
    // Re-format the displayed text whenever the formatting inputs change too,
    // not just the value — otherwise switching dateFormat/formatDate/locale
    // leaves the field showing the previous format's string.
    final bool formatChanged = old.dateFormat != widget.dateFormat ||
        old.formatDate != widget.formatDate ||
        old.locale != widget.locale;
    if (!selectionChanged && !formatChanged) return;
    _displayController.text = _displayText();
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
    // Root overlay so the scrim covers app chrome. Panel is a second entry on
    // top, still glued with [CompositedTransformFollower] (manual Positioned
    // drifts under the web viewport scale).
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);

    _barrierEntry = OverlayEntry(
      builder: (BuildContext context) => SizedBox.expand(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
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

  /// Effective calendar locale: the explicit [KasyDatePicker.locale] when set,
  /// otherwise resolved from the app's active language (pt / es / en) so the
  /// calendar always renders in the language the user is using the app in.
  KasyDatePickerLocale get _effectiveLocale {
    if (widget.locale != null) return widget.locale!;
    switch (Localizations.localeOf(context).languageCode) {
      case 'pt':
        return KasyDatePickerLocale.pt;
      case 'es':
        return KasyDatePickerLocale.es;
      default:
        return KasyDatePickerLocale.en;
    }
  }

  /// Resolved formatting preset: respects an explicit override on the widget
  /// and falls back to the locale's regional default.
  KasyDateFormat get _resolvedFormat =>
      widget.dateFormat ?? _effectiveLocale.defaultDateFormat;

  String _formatDate(DateTime date) =>
      widget.formatDate?.call(date) ?? _formatWithPreset(date, _resolvedFormat);

  /// Picks the most relevant date for opening the calendar view: the single
  /// value if present, otherwise the range start (range mode), otherwise
  /// null (the calendar then anchors on today).
  DateTime? _initialAnchorDate() {
    if (widget.selectionMode == KasyDateSelectionMode.range) {
      return widget.range?.start;
    }
    return widget.value;
  }

  /// Text shown in the trigger field. Single mode renders the picked date;
  /// range mode renders "start - end" once both endpoints are set, or just
  /// "start - ..." while waiting for the end so the user sees progress.
  String _displayText() {
    if (widget.selectionMode == KasyDateSelectionMode.range) {
      final KasyDateRange? r = widget.range;
      if (r == null || r.start == null) return '';
      final String startStr = _formatDate(r.start!);
      if (r.end == null) return '$startStr  -  ...';
      return '$startStr  -  ${_formatDate(r.end!)}';
    }
    if (widget.value == null) return '';
    return _formatDate(widget.value!);
  }

  /// Placeholder shown when no date is picked. Uses the explicit
  /// [KasyDatePicker.placeholder] when provided, otherwise derives the hint
  /// from the active preset so it matches what the user will eventually see.
  String get _resolvedPlaceholder =>
      widget.placeholder ?? _placeholderFor(_resolvedFormat);

  /// Adaptive default: popover on desktop, bottom sheet on phone / tablet.
  /// Explicit [KasyDatePicker.presentation] always wins.
  KasyDatePickerPresentation get _presentation {
    if (widget.presentation != null) return widget.presentation!;
    final bool desktop = MediaQuery.sizeOf(context).width >=
        DeviceType.large.breakpoint;
    return desktop
        ? KasyDatePickerPresentation.popover
        : KasyDatePickerPresentation.bottomSheet;
  }

  // ── Calendar toggle ────────────────────────────────────────────────────────

  void _toggleCalendar() {
    if (!widget.enabled) return;
    if (_presentation == KasyDatePickerPresentation.popover) {
      if (_isOpen) {
        _close();
      } else {
        _open();
      }
    } else if (_presentation == KasyDatePickerPresentation.dialog) {
      _openDialog();
    } else {
      _openBottomSheet();
    }
  }

  void _open() {
    // Read the actual field width and global position so the calendar matches
    // it and we can decide whether to open above or below the trigger.
    final RenderBox? fieldBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final Size viewport = MediaQuery.sizeOf(context);
    final EdgeInsets safe = MediaQuery.viewPaddingOf(context);
    final double rawWidth = fieldBox?.size.width ?? 288;
    _calendarWidth = math.min(rawWidth, viewport.width - safe.left - safe.right);

    bool openUp = false;
    if (fieldBox != null) {
      final Offset fieldTopLeft = fieldBox.localToGlobal(Offset.zero);
      // viewPaddingOf returns the system safe-area insets even when an
      // ancestor SafeArea has already consumed them — paddingOf would
      // return 0 in that case and overestimate the available room.
      final double fieldBottom = fieldTopLeft.dy + fieldBox.size.height;
      final double spaceBelow = viewport.height - safe.bottom - fieldBottom;
      final double spaceAbove = fieldTopLeft.dy - safe.top;
      // Flip up only when below doesn't fit AND above fits better.
      if (spaceBelow < _kEstimatedCalendarHeight + 8 &&
          spaceAbove > spaceBelow) {
        openUp = true;
      }
    }
    _openUp = openUp;

    if (widget.showBarrier) {
      _showBarrierAndPanel();
    } else {
      _portalController.show();
    }
    _animCtrl.forward();
    // Paint the trigger's "active" border while the calendar is open — driven
    // by state, not real focus (see _triggerActive).
    setState(() {
      _isOpen = true;
      _triggerActive = true;
    });
  }

  void _close() {
    _animCtrl.reverse().then((_) {
      if (!mounted) return;
      _removeOverlayEntries();
      if (_portalController.isShowing) {
        _portalController.hide();
      }
      // Commit any selection picked inside the popover only after the fade-out
      // completes. This keeps the press feedback on the original cell during
      // the close, instead of flashing the cell to primary mid-animation.
      final DateTime? pendingSingle = _pendingPopoverSelection;
      if (pendingSingle != null) {
        _pendingPopoverSelection = null;
        widget.onChanged?.call(pendingSingle);
      }
      final KasyDateRange? pendingRange = _pendingPopoverRange;
      if (pendingRange != null) {
        _pendingPopoverRange = null;
        widget.onRangeChanged?.call(pendingRange);
      }
      setState(() => _triggerActive = false);
    });
    setState(() => _isOpen = false);
  }

  /// Single-date pick coming from [KasyCalendar.onChanged]. In popover mode the
  /// commit is parked and fired from [_close] after the fade-out (so the press
  /// feedback stays visible during the close); otherwise it commits and pops.
  void _selectDate(DateTime date) {
    if (_presentation == KasyDatePickerPresentation.popover) {
      _pendingPopoverSelection = date;
      _close();
      return;
    }
    widget.onChanged?.call(date);
    _closeOverlayRoute();
  }

  /// Range update coming from [KasyCalendar.onRangeChanged]. The calendar owns
  /// the incremental start/end logic; here we only forward the partial range
  /// (so the start endpoint paints) and close once both endpoints are set.
  void _onCalendarRange(KasyDateRange range) {
    if (!range.isComplete) {
      widget.onRangeChanged?.call(range);
      return;
    }
    if (_presentation == KasyDatePickerPresentation.popover) {
      _pendingPopoverRange = range;
      _close();
      return;
    }
    widget.onRangeChanged?.call(range);
    _closeOverlayRoute();
  }

  /// Pops the dialog/bottom sheet route opened by this picker. No-op for
  /// popover mode (which closes via [_close]).
  void _closeOverlayRoute() {
    if (_presentation == KasyDatePickerPresentation.popover) return;
    Navigator.of(context, rootNavigator: true).maybePop();
  }

  void _openDialog() {
    setState(() => _triggerActive = true);
    // [KasyCalendar] owns its own visible month + range, so the dialog no longer
    // needs to mirror that state — it just forwards picks and pops when done.
    showKasyDialog<void>(
      context: context,
      builder: (ctx) => KasyCalendar(
        // Cap the width so the calendar doesn't stretch to the dialog inset
        // (nearly full screen on desktop). A fixed comfortable card width.
        width: _kDialogCalendarWidth,
        value: widget.value,
        range: widget.range,
        selectionMode: widget.selectionMode,
        initialMonth: _initialAnchorDate(),
        monthsToShow: widget.monthsToShow,
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        locale: _effectiveLocale,
        onChanged: (date) {
          widget.onChanged?.call(date);
          Navigator.of(ctx).pop();
        },
        onRangeChanged: (range) {
          widget.onRangeChanged?.call(range);
          if (range.isComplete) Navigator.of(ctx).pop();
        },
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _triggerActive = false);
    });
  }

  void _openBottomSheet() {
    setState(() => _triggerActive = true);
    showKasyBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BottomSheetContent(
        value: widget.value,
        range: widget.range,
        initialMonth: _initialAnchorDate(),
        selectionMode: widget.selectionMode,
        onChanged: widget.onChanged,
        onRangeChanged: widget.onRangeChanged,
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        locale: _effectiveLocale,
        monthsToShow: widget.monthsToShow,
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _triggerActive = false);
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // For popover presentation, wrap with OverlayPortal.
    // For dialog/bottomSheet, just the field — no overlay portal needed.
    if (_presentation == KasyDatePickerPresentation.popover) {
      return TapRegion(
        groupId: _tapGroupId,
        child: OverlayPortal(
          controller: _portalController,
          overlayChildBuilder: _buildOverlay,
          child: _buildField(context),
        ),
      );
    }

    return _buildField(context);
  }

  // ── DateField trigger ──────────────────────────────────────────────────────
  //
  // Label and footer (description / errorText) are rendered HERE — not passed
  // into KasyTextField — so the CompositedTransformTarget can wrap only the
  // KasyTextField's field rectangle. This way the popover anchors to the
  // input box itself, not to the full widget area (which would push the
  // calendar below the helper text).
  //
  // Visual styling for label/footer mirrors KasyTextField's own rendering so
  // the trigger keeps looking like any other input in the kit.

  Widget _buildField(BuildContext context) {
    final KasyColors c = context.colors;
    final bool isDisabled = !widget.enabled;
    final bool hasErrorText =
        widget.errorText != null && widget.errorText!.isNotEmpty;
    final bool hasInvalidState = widget.isInvalid || hasErrorText;
    final String? footerText =
        hasErrorText ? widget.errorText : widget.description;
    final Color labelColor = hasInvalidState ? c.error : c.fieldLabel;

    // Kit-wide rule: disabled colors are softened by blending toward the
    // surface (opaque), never by raw opacity. See KasyButton / KasyTextField.
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label!,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: dimDisabled(labelColor),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.showRequiredIndicator)
                  Text(
                    ' *',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: c.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: KasySpacing.xs),
        ],
        // Only this rectangle is the popover anchor — label and footer are
        // siblings, so they don't shift the calendar's open position.
        CompositedTransformTarget(
          link: _layerLink,
          child: MouseRegion(
            // The trigger looks like a text input but BEHAVES like a button —
            // override the I-beam cursor that the inner [TextField] would
            // otherwise show on web/desktop. The IgnorePointer below already
            // blocks taps from reaching the field, so the GestureDetector
            // wrapping us owns the click.
            cursor: widget.enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: KasyFocusRing(
              onActivate: _toggleCalendar,
              // Match the text field corner radius so the ring hugs the trigger.
              borderRadius: BorderRadius.circular(KasyRadius.md),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleCalendar,
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
                    // "Active" border while the calendar is open — painted from
                    // state, not real focus, so it never doubles the wrapping
                    // KasyFocusRing's keyboard ring on click and never gets
                    // dropped when the overlay steals focus.
                    forceFocusBorder: widget.focusBorder && _triggerActive,
                    // No caret, no selection handles, no "blue text" — keeps the
                    // field reading as a button, not an editable input.
                    enableInteractiveSelection: false,
                    suffix: widget.showSuffix
                        ? const Icon(KasyIcons.calendar)
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
                // Soften the helper text via the kit's blend-toward-surface
                // rule so the field as a whole reads as disabled without any
                // transparency.
                color:
                    dimDisabled(hasErrorText ? c.error : c.muted, alpha: 0.45),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Calendar overlay (popover only) ───────────────────────────────────────

  Widget _buildCalendarCard() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        alignment: _openUp ? Alignment.bottomCenter : Alignment.topCenter,
        child: KasyCalendar(
          width: _calendarWidth,
          value: widget.value,
          range: widget.range,
          selectionMode: widget.selectionMode,
          initialMonth: _initialAnchorDate(),
          monthsToShow: widget.monthsToShow,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
          locale: _effectiveLocale,
          onChanged: _selectDate,
          onRangeChanged: _onCalendarRange,
        ),
      ),
    );
  }

  Widget _buildPanelOverlay(BuildContext context) {
    // Overlay entries lay out with tight full-screen constraints. Stack
    // absorbs them so the card shrink-wraps; LayerLink keeps the anchor.
    return TapRegion(
      groupId: _tapGroupId,
      onTapOutside: (_) => _close(),
      child: Stack(
        children: [
          CompositedTransformFollower(
            link: _layerLink,
            targetAnchor:
                _openUp ? Alignment.topLeft : Alignment.bottomLeft,
            followerAnchor:
                _openUp ? Alignment.bottomLeft : Alignment.topLeft,
            // 8px gap between trigger edge and calendar — per Figma spec.
            offset: _openUp ? const Offset(0, -8) : const Offset(0, 8),
            child: _buildCalendarCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) => _buildPanelOverlay(context);
}

// ─────────────────────────────────────────────────────────────────────────────
// _BottomSheetContent — KasyBottomSheet-style wrapper for the calendar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomSheetContent extends StatelessWidget {
  const _BottomSheetContent({
    required this.value,
    required this.range,
    required this.initialMonth,
    required this.selectionMode,
    this.onChanged,
    this.onRangeChanged,
    this.minDate,
    this.maxDate,
    this.locale = KasyDatePickerLocale.en,
    this.monthsToShow,
  });

  final DateTime? value;
  final KasyDateRange? range;
  final DateTime? initialMonth;
  final KasyDateSelectionMode selectionMode;
  final ValueChanged<DateTime>? onChanged;
  final ValueChanged<KasyDateRange>? onRangeChanged;
  final DateTime? minDate;
  final DateTime? maxDate;
  final KasyDatePickerLocale locale;
  final int? monthsToShow;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: c.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(KasyRadius.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle — the single shared component.
          const KasyDragHandle(),
          // Calendar content — no card decoration (sheet surface is already white).
          Padding(
            padding: EdgeInsets.only(
              left: KasySpacing.md,
              right: KasySpacing.md,
              top: KasySpacing.sm,
              bottom: KasySpacing.md + bottomInset,
            ),
            child: KasyCalendar(
              showCard: false,
              value: value,
              range: range,
              selectionMode: selectionMode,
              initialMonth: initialMonth,
              monthsToShow: monthsToShow,
              minDate: minDate,
              maxDate: maxDate,
              locale: locale,
              onChanged: (date) {
                onChanged?.call(date);
                Navigator.of(context).pop();
              },
              onRangeChanged: (r) {
                onRangeChanged?.call(r);
                if (r.isComplete) Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
