import 'package:cowboydodartinc/components/kasy_bottom_sheet.dart' show KasyDragHandle;
import 'package:cowboydodartinc/components/kasy_date_picker.dart'
    show KasyDatePickerLocale, KasyDateRange, KasyDateSelectionMode;
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show KeyDownEvent, KeyEvent, LogicalKeyboardKey;

// ─────────────────────────────────────────────────────────────────────────────
// KasyCalendar — standalone month/year date grid (HeroUI "Calendar")
// ─────────────────────────────────────────────────────────────────────────────
//
// This is the inline calendar that, until now, only lived embedded inside
// [KasyDatePicker]'s popover/sheet. Promoted to a public component so it can be
// dropped directly into a page, a card, or composed inside a popover to rebuild
// the Figma "CalendarPopover" (which only exists in Figma — the docs say to
// compose it with a popover in code).
//
// Faithful to the Figma "Calendar" page:
//   - Day cell  36×36, full-radius, Inter Medium 14/20.
//   - today     soft primary pill (primarySoft fill + primarySoftForeground text).
//   - selected  solid primary circle, on-primary text.
//   - out       outside-month / out-of-range days at 50% opacity.
//   - indicator small 3px dot under days flagged via [markedDates] (events).
//   - month nav with an expand chevron that flips to a year-grid picker.
//   - multi-month layout (2–3 months side by side) for range selection.
//
// It reuses [KasyDatePicker]'s public date types ([KasyDateRange],
// [KasyDateSelectionMode], [KasyDatePickerLocale]) so the two components share
// one vocabulary instead of inventing a parallel one.
// ─────────────────────────────────────────────────────────────────────────────
// Data helpers
// ─────────────────────────────────────────────────────────────────────────────
/// Number of days in [month] of [year].
int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _firstOfMonth(DateTime d) => DateTime(d.year, d.month);

bool _isDayDisabled(DateTime date, DateTime? min, DateTime? max) {
  final DateTime d = DateTime(date.year, date.month, date.day);
  if (min != null && d.isBefore(DateTime(min.year, min.month, min.day))) {
    return true;
  }
  if (max != null && d.isAfter(DateTime(max.year, max.month, max.day))) {
    return true;
  }
  return false;
}

/// Internal model for a single calendar cell.
class _DayData {
  const _DayData({
    required this.date,
    required this.isCurrentMonth,
    this.isToday = false,
    this.isDisabled = false,
  });

  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isDisabled;
}

/// Builds the 42-cell (6 × 7) grid for [viewMonth]. Cells before day 1 are
/// filled from the previous month; trailing cells from the next month.
List<_DayData> _buildDayGrid(
  DateTime viewMonth, {
  DateTime? minDate,
  DateTime? maxDate,
  int weekStartDay = 0,
}) {
  final DateTime today = DateTime.now();
  final int daysInCurrent = _daysInMonth(viewMonth.year, viewMonth.month);

  // Dart weekday: Mon=1 … Sun=7. Convert to Sunday-origin then shift by
  // weekStartDay (0 = Sunday-first, 1 = Monday-first).
  final DateTime firstOfMonth = DateTime(viewMonth.year, viewMonth.month);
  final int offset = (firstOfMonth.weekday % 7 - weekStartDay + 7) % 7;

  final int prevYear =
      viewMonth.month == 1 ? viewMonth.year - 1 : viewMonth.year;
  final int prevMonth = viewMonth.month == 1 ? 12 : viewMonth.month - 1;
  final int daysInPrev = _daysInMonth(prevYear, prevMonth);

  final List<_DayData> grid = [];

  // Prev-month trailing days.
  for (int i = 0; i < offset; i++) {
    final int d = daysInPrev - offset + 1 + i;
    final DateTime date = DateTime(prevYear, prevMonth, d);
    grid.add(_DayData(
      date: date,
      isCurrentMonth: false,
      isDisabled: _isDayDisabled(date, minDate, maxDate),
    ));
  }

  // Current-month days.
  for (int d = 1; d <= daysInCurrent; d++) {
    final DateTime date = DateTime(viewMonth.year, viewMonth.month, d);
    grid.add(_DayData(
      date: date,
      isCurrentMonth: true,
      isToday: _isSameDay(date, today),
      isDisabled: _isDayDisabled(date, minDate, maxDate),
    ));
  }

  // Next-month leading days.
  final int nextYear =
      viewMonth.month == 12 ? viewMonth.year + 1 : viewMonth.year;
  final int nextMonth = viewMonth.month == 12 ? 1 : viewMonth.month + 1;
  int nextDay = 1;
  while (grid.length < 42) {
    final DateTime date = DateTime(nextYear, nextMonth, nextDay++);
    grid.add(_DayData(
      date: date,
      isCurrentMonth: false,
      isDisabled: _isDayDisabled(date, minDate, maxDate),
    ));
  }

  return grid;
}

// ─────────────────────────────────────────────────────────────────────────────
// _RangePosition — where a day sits inside a selection (Airbnb-style highlight)
// ─────────────────────────────────────────────────────────────────────────────

enum _RangePosition { none, start, middle, end, single }

_RangePosition _positionFor(DateTime day, KasyDateRange? range) {
  if (range == null || range.start == null) return _RangePosition.none;
  final DateTime start = range.start!;
  final DateTime? end = range.end;
  if (end == null) {
    return _isSameDay(day, start) ? _RangePosition.single : _RangePosition.none;
  }
  if (_isSameDay(start, end)) {
    return _isSameDay(day, start) ? _RangePosition.single : _RangePosition.none;
  }
  if (_isSameDay(day, start)) return _RangePosition.start;
  if (_isSameDay(day, end)) return _RangePosition.end;
  final DateTime d = DateTime(day.year, day.month, day.day);
  final DateTime s = DateTime(start.year, start.month, start.day);
  final DateTime e = DateTime(end.year, end.month, end.day);
  if (d.isAfter(s) && d.isBefore(e)) return _RangePosition.middle;
  return _RangePosition.none;
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar overlay shadow — from Figma variable defs (3 layers).
// ─────────────────────────────────────────────────────────────────────────────

// Calendar overlay shadow — same stack as [KasyShadows.overlayPanel] (light).
const List<BoxShadow> _kCalendarShadows = KasyShadows.overlay;

enum _CalendarViewMode { month, year }

/// Which view the calendar opens on: the day grid or the year picker.
enum KasyCalendarView { month, year }

// ─────────────────────────────────────────────────────────────────────────────
// KasyCalendar
// ─────────────────────────────────────────────────────────────────────────────

/// Inline calendar for picking a single date or a start/end range.
///
/// ```dart
/// // Single date
/// KasyCalendar(
///   value: _date,
///   onChanged: (d) => setState(() => _date = d),
/// )
///
/// // Range, two months side by side
/// KasyCalendar(
///   selectionMode: KasyDateSelectionMode.range,
///   range: _stay,
///   onRangeChanged: (r) => setState(() => _stay = r),
///   monthsToShow: 2,
/// )
/// ```
///
/// The widget owns its own visible month and view mode (month grid vs. year
/// picker); selection is controlled via [value]/[range]. Compose it inside a
/// popover/sheet (or use [KasyDatePicker]) to reproduce the Figma
/// "CalendarPopover", which only exists in the Figma file.
class KasyCalendar extends StatefulWidget {
  const KasyCalendar({
    super.key,
    this.value,
    this.onChanged,
    this.range,
    this.onRangeChanged,
    this.selectionMode = KasyDateSelectionMode.single,
    this.initialMonth,
    this.minDate,
    this.maxDate,
    this.monthsToShow,
    this.locale,
    this.markedDates = const <DateTime>{},
    this.initialView = KasyCalendarView.month,
    this.topContent,
    this.bottomContent,
    this.showTime = false,
    this.time,
    this.onTimeChanged,
    this.timeZoneLabel,
    this.timeInvalid = false,
    this.showDragHandle = false,
    this.showCard = true,
    this.width,
  });

  /// Selected date in [KasyDateSelectionMode.single].
  final DateTime? value;

  /// Called when the user picks a date in single mode.
  final ValueChanged<DateTime>? onChanged;

  /// Selected start/end pair in [KasyDateSelectionMode.range].
  final KasyDateRange? range;

  /// Called when the range changes: once with only [KasyDateRange.start] after
  /// the first tap, then again with both endpoints after the second.
  final ValueChanged<KasyDateRange>? onRangeChanged;

  /// Whether the calendar selects a single date or a start/end range.
  final KasyDateSelectionMode selectionMode;

  /// Month shown on first build. Defaults to the selected date's month (or
  /// today's month when there is no selection).
  final DateTime? initialMonth;

  /// Earliest selectable date (inclusive).
  final DateTime? minDate;

  /// Latest selectable date (inclusive).
  final DateTime? maxDate;

  /// Number of months rendered side by side (1–3). Defaults to 1.
  final int? monthsToShow;

  /// Display locale — month names, weekday labels, week start. Defaults to the
  /// English (Sunday-first) preset.
  final KasyDatePickerLocale? locale;

  /// Days that should show a small indicator dot under the number (e.g. days
  /// with events). Only the year/month/day are compared.
  final Set<DateTime> markedDates;

  /// Which view the calendar opens on (day grid or year picker). Maps to the
  /// Figma "years" calendar type when set to [KasyCalendarView.year].
  final KasyCalendarView initialView;

  /// Optional content rendered above the navigation row — the Figma "top
  /// content" slot (e.g. a Today / Week / Month [KasyToggleButtonGroup]).
  final Widget? topContent;

  /// Optional content rendered below the grid (and the time row) — the Figma
  /// "bottom content" slot (e.g. a row of range-preset [KasyTag]s).
  final Widget? bottomContent;

  /// When true, shows the "Time" selector row below the grid (Figma "show
  /// time"). Pair with [time]/[onTimeChanged].
  final bool showTime;

  /// Current time shown in the time row. Defaults to 10:30 when [showTime] is
  /// on and this is null.
  final TimeOfDay? time;

  /// Called when the user edits the time in the time row.
  final ValueChanged<TimeOfDay>? onTimeChanged;

  /// Trailing time-zone label shown muted after the time (e.g. "EDT"). Omit to
  /// hide it.
  final String? timeZoneLabel;

  /// Renders the time row in its invalid (error) state — red segments. Mirrors
  /// the Figma "invalid" time-value state for form validation.
  final bool timeInvalid;

  /// When true, shows a centered drag handle at the top — the Figma "mobile"
  /// calendar type, for when the calendar is presented as a bottom sheet.
  final bool showDragHandle;

  /// When true (default) the calendar is wrapped in a rounded surface with a
  /// soft shadow. Set to false when the parent already provides the surface
  /// (e.g. a bottom sheet) — the calendar then expands to the parent's width.
  final bool showCard;

  /// Fixed width of the calendar. Defaults to a comfortable single-month width
  /// (or the multi-month equivalent). Ignored in [showCard]==false + null,
  /// where the calendar fills the parent.
  final double? width;

  @override
  State<KasyCalendar> createState() => _KasyCalendarState();
}

class _KasyCalendarState extends State<KasyCalendar> {
  // Card geometry — matches Figma "CalendarPopover": 288 wide, 16 inner inset,
  // 256 grid (7 × 36 day cells justified across the row).
  static const double _kInset = KasySpacing.md; // 16
  static const double _kGridWidth = 256;
  static const double _kMonthGap = KasySpacing.lg; // 16

  late DateTime _viewMonth;
  late _CalendarViewMode _viewMode;
  KasyDateRange? _range;
  late Set<int> _markedKeys;

  KasyDatePickerLocale get _locale => widget.locale ?? KasyDatePickerLocale.en;

  int get _monthCount => (widget.monthsToShow ?? 1).clamp(1, 3);

  @override
  void initState() {
    super.initState();
    _viewMonth = _firstOfMonth(
      widget.value ?? widget.range?.start ?? widget.initialMonth ?? DateTime.now(),
    );
    _viewMode = widget.initialView == KasyCalendarView.year
        ? _CalendarViewMode.year
        : _CalendarViewMode.month;
    _range = widget.range;
    _markedKeys = _buildMarkedKeys();
  }

  @override
  void didUpdateWidget(covariant KasyCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.range != oldWidget.range) {
      _range = widget.range;
    }
    if (widget.markedDates != oldWidget.markedDates) {
      _markedKeys = _buildMarkedKeys();
    }
  }

  Set<int> _buildMarkedKeys() => {
        for (final DateTime d in widget.markedDates) _markKey(d),
      };

  // ── Selection state for rendering ──────────────────────────────────────────

  /// The selection painted by the day cells. Single mode wraps [value] in a
  /// range with `start == end` so one widget tree renders both modes.
  KasyDateRange? get _renderRange {
    if (widget.selectionMode == KasyDateSelectionMode.range) return _range;
    final DateTime? v = widget.value;
    return v == null ? null : KasyDateRange(start: v, end: v);
  }

  /// Normalised lookup key for a marked date.
  int _markKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  bool _isMarked(DateTime d) => _markedKeys.contains(_markKey(d));

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _previousMonth() => setState(() {
        _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1);
      });

  void _toggleViewMode() => setState(() {
        _viewMode = _viewMode == _CalendarViewMode.month
            ? _CalendarViewMode.year
            : _CalendarViewMode.month;
      });

  DateTime _shiftMonth(DateTime base, int delta) =>
      DateTime(base.year, base.month + delta);

  // ── Tap handling ─────────────────────────────────────────────────────────

  void _onDateTapped(DateTime date) {
    // Keep the grid focused on the tapped day's month so picking a trailing /
    // leading day from an adjacent month brings that month into view.
    final DateTime targetMonth = _firstOfMonth(date);
    if (widget.selectionMode == KasyDateSelectionMode.range) {
      final KasyDateRange current = _range ?? const KasyDateRange();
      final bool isFirstPick = current.start == null ||
          current.isComplete ||
          date.isBefore(current.start!);
      final KasyDateRange next = isFirstPick
          ? KasyDateRange(start: date)
          : KasyDateRange(start: current.start, end: date);
      setState(() {
        _range = next;
        _viewMonth = targetMonth;
      });
      widget.onRangeChanged?.call(next);
      return;
    }
    setState(() => _viewMonth = targetMonth);
    widget.onChanged?.call(date);
  }

  // ── Layout ─────────────────────────────────────────────────────────────────

  String _monthYearLabel(DateTime m) =>
      '${_locale.monthNames[m.month - 1]}${_locale.monthYearSeparator}${m.year}';

  double? get _resolvedWidth {
    if (widget.width != null) return widget.width;
    if (!widget.showCard) return null; // fill parent
    final int months = _monthCount;
    final double inner =
        months * _kGridWidth + (months - 1) * _kMonthGap;
    return inner + _kInset * 2;
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = _buildContent();

    if (!widget.showCard) {
      return widget.width != null
          ? SizedBox(width: widget.width, child: content)
          : content;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        width: _resolvedWidth,
        decoration: BoxDecoration(
          color: context.colors.surface,
          // 24px radius — Figma rounded-3xl.
          borderRadius: BorderRadius.circular(KasyRadius.xl),
          boxShadow: _kCalendarShadows,
        ),
        // No top inset — the nav row owns its own vertical spacing (56px).
        padding: const EdgeInsets.only(
          left: _kInset,
          right: _kInset,
          bottom: _kInset,
        ),
        child: content,
      ),
    );
  }

  /// Assembles the full calendar: optional drag handle + top content, the
  /// grid/year core, the optional time row, and optional bottom content.
  Widget _buildContent() {
    final List<Widget> children = <Widget>[];
    if (widget.showDragHandle) {
      children.add(const KasyDragHandle());
    }
    if (widget.topContent != null) {
      children.add(Padding(
        // Pull the top content in line with the nav row's internal rhythm.
        padding: const EdgeInsets.only(top: KasySpacing.sm),
        child: widget.topContent,
      ));
    }
    children.add(_buildCore());
    if (widget.showTime) {
      children.add(_CalendarTimeRow(
        time: widget.time ?? const TimeOfDay(hour: 10, minute: 30),
        onChanged: widget.onTimeChanged,
        timeZoneLabel: widget.timeZoneLabel,
        invalid: widget.timeInvalid,
      ));
    }
    if (widget.bottomContent != null) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: KasySpacing.md),
        child: widget.bottomContent,
      ));
    }

    if (children.length == 1) return children.first;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildCore() {
    if (_viewMode == _CalendarViewMode.year) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CalendarNavRow(
            label: _monthYearLabel(_viewMonth),
            viewMode: _viewMode,
            onToggleMode: _toggleViewMode,
            onPrevious: null,
            onNext: null,
          ),
          _YearPickerContent(
            currentYear: _viewMonth.year,
            onYearSelected: (year) {
              setState(() {
                _viewMonth = DateTime(year, _viewMonth.month);
                _viewMode = _CalendarViewMode.month;
              });
            },
          ),
        ],
      );
    }

    final int months = _monthCount;
    if (months == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CalendarNavRow(
            label: _monthYearLabel(_viewMonth),
            viewMode: _viewMode,
            onToggleMode: _toggleViewMode,
            onPrevious: _previousMonth,
            onNext: _nextMonth,
          ),
          _monthGrid(_viewMonth),
        ],
      );
    }

    // Multi-month: arrows on the outer edges, month captions between them, and
    // each grid aligned below its caption (the caption row and the grid row
    // share the same column proportions: arrow + Expanded grids + arrow).
    const double navArrowWidth = 28;
    final TextStyle? headerStyle = context.textTheme.labelLarge?.copyWith(
      color: context.colors.onSurface,
      fontWeight: FontWeight.w700,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 56,
          child: Row(
            children: [
              _NavArrowButton(
                icon: KasyIcons.arrowBackIos,
                onTap: _previousMonth,
              ),
              for (int i = 0; i < months; i++) ...[
                if (i > 0) const SizedBox(width: _kMonthGap),
                Expanded(
                  child: Center(
                    child: Text(
                      _monthYearLabel(_shiftMonth(_viewMonth, i)),
                      style: headerStyle,
                    ),
                  ),
                ),
              ],
              _NavArrowButton(
                icon: KasyIcons.arrowForwardIos,
                onTap: _nextMonth,
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: navArrowWidth),
            for (int i = 0; i < months; i++) ...[
              if (i > 0) const SizedBox(width: _kMonthGap),
              Expanded(child: _monthGrid(_shiftMonth(_viewMonth, i))),
            ],
            const SizedBox(width: navArrowWidth),
          ],
        ),
      ],
    );
  }

  Widget _monthGrid(DateTime month) {
    final List<_DayData> days = _buildDayGrid(
      month,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      weekStartDay: _locale.weekStartDay,
    );
    final KasyDateRange? range = _renderRange;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WeekdayHeaderRow(locale: _locale),
        const SizedBox(height: 8),
        for (int row = 0; row < 6; row++) ...[
          if (row > 0) const SizedBox(height: 2),
          Row(
            children: days.sublist(row * 7, row * 7 + 7).map((day) {
              return Expanded(
                child: _DayCell(
                  data: day,
                  position: _positionFor(day.date, range),
                  marked: _isMarked(day.date),
                  onTap: day.isDisabled ? null : () => _onDateTapped(day.date),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CalendarNavRow — month/year caption (with expand chevron) + prev/next arrows
// ─────────────────────────────────────────────────────────────────────────────

class _CalendarNavRow extends StatelessWidget {
  const _CalendarNavRow({
    required this.label,
    required this.viewMode,
    required this.onToggleMode,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final _CalendarViewMode viewMode;
  final VoidCallback onToggleMode;

  /// Null in year mode — arrows render disabled (the user picks from the list).
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;

    final Widget caption = KasyHover(
      onTap: onToggleMode,
      borderRadius: BorderRadius.circular(KasyRadius.sm),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: c.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            viewMode == _CalendarViewMode.month
                ? KasyIcons.chevronRight
                : KasyIcons.chevronDown,
            size: KasyIconSize.md,
            weight: 700,
            color: c.primary,
          ),
        ],
      ),
    );

    // Label on the left, prev/next clustered on the right (compact iOS layout).
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(child: caption),
          _NavArrowButton(icon: KasyIcons.arrowBackIos, onTap: onPrevious),
          const SizedBox(width: 12),
          _NavArrowButton(icon: KasyIcons.arrowForwardIos, onTap: onNext),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NavArrowButton — 28×28 rounded navigation arrow
// ─────────────────────────────────────────────────────────────────────────────

class _NavArrowButton extends StatelessWidget {
  const _NavArrowButton({required this.icon, required this.onTap});

  final IconData icon;

  /// When null the button renders disabled (muted icon, no hover, no action).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final bool disabled = onTap == null;

    final Widget body = SizedBox(
      width: 28,
      height: 28,
      child: Center(
        child: Icon(
          icon,
          size: KasyIconSize.lg,
          weight: 700,
          color: disabled ? c.muted.withValues(alpha: 0.45) : c.primary,
        ),
      ),
    );

    if (disabled) return body;

    return KasyHover(
      onTap: onTap!,
      borderRadius: BorderRadius.circular(6),
      child: body,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _YearPickerContent — scrollable 3-column year list (1900–2099)
// ─────────────────────────────────────────────────────────────────────────────

class _YearPickerContent extends StatefulWidget {
  const _YearPickerContent({
    required this.currentYear,
    required this.onYearSelected,
  });

  final int currentYear;
  final ValueChanged<int> onYearSelected;

  @override
  State<_YearPickerContent> createState() => _YearPickerContentState();
}

class _YearPickerContentState extends State<_YearPickerContent> {
  static const int _kFirstYear = 1900;
  static const int _kLastYear = 2099;
  static const int _kCols = 3;
  static const double _kRowHeight = 36;
  // Matches the month grid's intrinsic height (weekday header 36 + 8 gap +
  // 6 day rows × 36 + 5 gaps × 2 = 270) so the panel height stays constant.
  static const double _kViewportHeight = 270;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final int index = widget.currentYear - _kFirstYear;
    final int row = index ~/ _kCols;
    final double targetOffset =
        (row * _kRowHeight) - (_kViewportHeight - _kRowHeight) / 2;
    final int totalRows = ((_kLastYear - _kFirstYear + 1) / _kCols).ceil();
    final double maxOffset = (totalRows * _kRowHeight) - _kViewportHeight;
    _scrollController = ScrollController(
      initialScrollOffset: targetOffset.clamp(0.0, maxOffset),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    const int totalYears = _kLastYear - _kFirstYear + 1;
    final int rowCount = (totalYears / _kCols).ceil();
    final BorderRadius yearRadius = BorderRadius.circular(KasyRadius.xl);

    return Container(
      height: _kViewportHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(KasyRadius.md),
        border: Border.all(color: c.outline.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: rowCount,
        itemExtent: _kRowHeight,
        itemBuilder: (context, row) {
          return Row(
            children: List.generate(_kCols, (col) {
              final int index = row * _kCols + col;
              if (index >= totalYears) {
                return const Expanded(child: SizedBox.shrink());
              }
              final int year = _kFirstYear + index;
              final bool isCurrent = year == widget.currentYear;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: KasyHover(
                    onTap: () => widget.onYearSelected(year),
                    borderRadius: yearRadius,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isCurrent ? c.primary : Colors.transparent,
                        borderRadius: yearRadius,
                        boxShadow:
                            isCurrent ? [KasyShadows.component(context)] : null,
                      ),
                      child: Center(
                        child: Text(
                          year.toString(),
                          style: context.textTheme.labelLarge?.copyWith(
                            color: isCurrent ? c.onPrimary : c.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WeekdayHeaderRow — Sun Mon Tue Wed Thu Fri Sat
// ─────────────────────────────────────────────────────────────────────────────

class _WeekdayHeaderRow extends StatelessWidget {
  const _WeekdayHeaderRow({required this.locale});

  final KasyDatePickerLocale locale;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    return Row(
      children: locale.weekdayAbbreviations.map((abbr) {
        return Expanded(
          child: SizedBox(
            height: 36,
            child: Center(
              child: Text(
                abbr,
                style: context.textTheme.labelLarge?.copyWith(
                  color: c.muted,
                  fontWeight: FontWeight.w600,
                  height: 1.43,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DayCell — individual calendar day (default / today / selected / range / out)
// ─────────────────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.data,
    required this.position,
    required this.marked,
    required this.onTap,
  });

  final _DayData data;
  final _RangePosition position;

  /// Whether to draw the small event indicator dot under the number.
  final bool marked;
  final VoidCallback? onTap;

  bool get _isEndpoint =>
      position == _RangePosition.start ||
      position == _RangePosition.end ||
      position == _RangePosition.single;

  bool get _isInRange => position != _RangePosition.none;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final BorderRadius cellRadius = BorderRadius.circular(KasyRadius.xl);
    final bool isToday = data.isToday && !_isEndpoint;

    // ── Text + indicator color ────────────────────────────────────────────
    final Color textColor;
    if (_isEndpoint) {
      textColor = c.onPrimary;
    } else if (position == _RangePosition.middle) {
      textColor = c.onSurface;
    } else if (isToday) {
      textColor = c.primarySoftForeground;
    } else if (!data.isCurrentMonth || data.isDisabled) {
      textColor = c.muted;
    } else {
      textColor = c.onSurface;
    }

    final double opacity =
        (!data.isCurrentMonth || data.isDisabled) ? 0.5 : 1.0;

    // ── Range connecting bar (start / middle / end) ───────────────────────
    Widget? rangeBar;
    if (_isInRange && position != _RangePosition.single) {
      final Color barColor = c.primary.withValues(alpha: 0.10);
      const double ballSize = 36;
      const Radius ballR = Radius.circular(ballSize / 2);
      rangeBar = LayoutBuilder(
        builder: (context, constraints) {
          final double sideGutter = ((constraints.maxWidth - ballSize) / 2)
              .clamp(0.0, double.infinity);
          switch (position) {
            case _RangePosition.start:
              return Padding(
                padding: EdgeInsets.only(left: sideGutter),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: ballR,
                      bottomLeft: ballR,
                    ),
                  ),
                ),
              );
            case _RangePosition.end:
              return Padding(
                padding: EdgeInsets.only(right: sideGutter),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: const BorderRadius.only(
                      topRight: ballR,
                      bottomRight: ballR,
                    ),
                  ),
                ),
              );
            case _RangePosition.middle:
              return ColoredBox(color: barColor);
            case _RangePosition.single:
            case _RangePosition.none:
              return const SizedBox.shrink();
          }
        },
      );
    }

    // ── Background circle (selected endpoint = solid; today = soft pill) ───
    Widget? background;
    if (_isEndpoint) {
      background = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c.primary,
          borderRadius: cellRadius,
          boxShadow: [KasyShadows.component(context)],
        ),
      );
    } else if (isToday) {
      background = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c.primarySoft,
          borderRadius: cellRadius,
        ),
      );
    }

    final Widget dayNumber = Text(
      data.date.day.toString(),
      style: context.textTheme.labelLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
        height: 1.43,
      ),
    );

    // Event indicator: 3px dot pinned near the bottom of the cell (Figma).
    final Widget? indicator = marked
        ? Positioned(
            bottom: 4,
            child: Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: textColor,
                borderRadius: BorderRadius.circular(KasyRadius.md),
              ),
            ),
          )
        : null;

    final Widget cellInner = Stack(
      alignment: Alignment.center,
      children: [
        if (background != null) background,
        dayNumber,
        if (indicator != null) indicator,
      ],
    );

    // The interactive bit is always a 36×36 circle so hover/press feedback is
    // a perfect bola, even on range cells where the bar extends past it.
    final Widget interactive = Center(
      child: SizedBox(
        width: 36,
        height: 36,
        child: onTap == null
            ? cellInner
            : KasyHover(
                onTap: onTap!,
                borderRadius: cellRadius,
                child: cellInner,
              ),
      ),
    );

    final Widget composed = SizedBox(
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (rangeBar != null) Positioned.fill(child: rangeBar),
          interactive,
        ],
      ),
    );

    return Opacity(opacity: opacity, child: composed);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CalendarTimeRow — "Time" label + editable hour:minute AM/PM pill (+ zone)
// ─────────────────────────────────────────────────────────────────────────────
//
// Mirrors the Figma "_CalendarTime" row. Each value is a focusable segment with
// the documented states: filled (default), hover, focus (primary), and invalid
// (danger). Edit with typing, ↑/↓ arrows, or by tapping the AM/PM segment.

class _CalendarTimeRow extends StatefulWidget {
  const _CalendarTimeRow({
    required this.time,
    required this.onChanged,
    required this.timeZoneLabel,
    required this.invalid,
  });

  final TimeOfDay time;
  final ValueChanged<TimeOfDay>? onChanged;
  final String? timeZoneLabel;
  final bool invalid;

  @override
  State<_CalendarTimeRow> createState() => _CalendarTimeRowState();
}

class _CalendarTimeRowState extends State<_CalendarTimeRow> {
  late TimeOfDay _time;
  final FocusNode _hourFocus = FocusNode(debugLabel: 'calendar-time-hour');
  final FocusNode _minuteFocus = FocusNode(debugLabel: 'calendar-time-minute');
  final FocusNode _periodFocus = FocusNode(debugLabel: 'calendar-time-period');

  /// Transient digit buffer for the focused numeric segment (reset on blur).
  String _buffer = '';

  @override
  void initState() {
    super.initState();
    _time = widget.time;
    for (final FocusNode n in [_hourFocus, _minuteFocus, _periodFocus]) {
      n.addListener(_onFocusChanged);
    }
  }

  @override
  void didUpdateWidget(covariant _CalendarTimeRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.time != oldWidget.time) _time = widget.time;
  }

  @override
  void dispose() {
    for (final FocusNode n in [_hourFocus, _minuteFocus, _periodFocus]) {
      n
        ..removeListener(_onFocusChanged)
        ..dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    _buffer = '';
    setState(() {});
  }

  // ── Value math ─────────────────────────────────────────────────────────────

  int get _hour12 {
    final int h = _time.hourOfPeriod;
    return h == 0 ? 12 : h;
  }

  bool get _isPm => _time.period == DayPeriod.pm;

  void _commit(TimeOfDay next) {
    setState(() => _time = next);
    widget.onChanged?.call(next);
  }

  void _setHour12(int h) {
    final int clamped = h.clamp(1, 12);
    final int h24 = (clamped % 12) + (_isPm ? 12 : 0);
    _commit(TimeOfDay(hour: h24, minute: _time.minute));
  }

  void _setMinute(int m) =>
      _commit(TimeOfDay(hour: _time.hour, minute: m.clamp(0, 59)));

  void _setPeriod({required bool pm}) {
    if (pm == _isPm) return;
    final int h24 = (_hour12 % 12) + (pm ? 12 : 0);
    _commit(TimeOfDay(hour: h24, minute: _time.minute));
  }

  void _bumpHour(int delta) =>
      _setHour12(((_hour12 - 1 + delta) % 12 + 12) % 12 + 1);

  void _bumpMinute(int delta) =>
      _setMinute((_time.minute + delta + 60) % 60);

  // ── Keyboard ─────────────────────────────────────────────────────────────

  bool _isDigit(String? ch) =>
      ch != null &&
      ch.length == 1 &&
      ch.codeUnitAt(0) >= 0x30 &&
      ch.codeUnitAt(0) <= 0x39;

  KeyEventResult _onNumericKey(KeyEvent event, {required bool isHour}) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      isHour ? _bumpHour(1) : _bumpMinute(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      isHour ? _bumpHour(-1) : _bumpMinute(-1);
      return KeyEventResult.handled;
    }
    if (!_isDigit(event.character)) return KeyEventResult.ignored;

    _buffer = _buffer + event.character!;
    if (_buffer.length > 2) _buffer = event.character!;
    final int val = int.parse(_buffer);
    if (isHour) {
      _setHour12(val == 0 ? 12 : val.clamp(1, 12));
      // Advance once the hour is unambiguous (two digits, or a leading digit
      // that can't start a two-digit hour).
      if (_buffer.length == 2 || val > 1) {
        _buffer = '';
        _minuteFocus.requestFocus();
      }
    } else {
      _setMinute(val.clamp(0, 59));
      if (_buffer.length == 2 || val > 5) {
        _buffer = '';
        _periodFocus.requestFocus();
      }
    }
    return KeyEventResult.handled;
  }

  KeyEventResult _onPeriodKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown) {
      _setPeriod(pm: !_isPm);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyA) {
      _setPeriod(pm: false);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyP) {
      _setPeriod(pm: true);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    return Padding(
      // 12px top — Figma _CalendarTime pt.
      padding: const EdgeInsets.only(top: KasySpacing.md),
      child: Row(
        children: [
          Text(
            'Time',
            style: context.textTheme.labelLarge?.copyWith(
              color: c.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            constraints: const BoxConstraints(minHeight: 32),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.neutral,
              // 16px radius — Figma rounded-2xl.
              borderRadius: BorderRadius.circular(KasyRadius.lg),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _segment(
                  text: _hour12.toString().padLeft(2, '0'),
                  focusNode: _hourFocus,
                  onKey: (e) => _onNumericKey(e, isHour: true),
                ),
                _separator(':'),
                _segment(
                  text: _time.minute.toString().padLeft(2, '0'),
                  focusNode: _minuteFocus,
                  onKey: (e) => _onNumericKey(e, isHour: false),
                ),
                const SizedBox(width: 4),
                _segment(
                  text: _isPm ? 'PM' : 'AM',
                  focusNode: _periodFocus,
                  onKey: _onPeriodKey,
                  onTap: () => _setPeriod(pm: !_isPm),
                ),
                if (widget.timeZoneLabel != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    widget.timeZoneLabel!,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: c.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _separator(String s) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Text(
          s,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface,
          ),
        ),
      );

  Widget _segment({
    required String text,
    required FocusNode focusNode,
    required KeyEventResult Function(KeyEvent) onKey,
    VoidCallback? onTap,
  }) {
    return _TimeSegment(
      text: text,
      focusNode: focusNode,
      invalid: widget.invalid,
      onKey: onKey,
      onTap: onTap,
    );
  }
}

/// A single focusable, hoverable time value (hour / minute / period). Renders
/// the Figma states: filled, hover, focus (primary), invalid, invalid+focus.
class _TimeSegment extends StatefulWidget {
  const _TimeSegment({
    required this.text,
    required this.focusNode,
    required this.invalid,
    required this.onKey,
    this.onTap,
  });

  final String text;
  final FocusNode focusNode;
  final bool invalid;
  final KeyEventResult Function(KeyEvent) onKey;
  final VoidCallback? onTap;

  @override
  State<_TimeSegment> createState() => _TimeSegmentState();
}

class _TimeSegmentState extends State<_TimeSegment> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final bool focused = widget.focusNode.hasFocus;

    Color textColor;
    Color? bg;
    if (widget.invalid) {
      textColor = c.error;
      bg = focused ? c.dangerSoft : null;
    } else if (focused) {
      textColor = c.primarySoftForeground;
      bg = c.primarySoft;
    } else {
      textColor = c.onSurface;
      bg = _hovered ? c.neutralHover : null;
    }

    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: (_, event) => widget.onKey(event),
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.focusNode.requestFocus();
            widget.onTap?.call();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.text,
              style: context.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
