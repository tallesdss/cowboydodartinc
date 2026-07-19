import 'package:cowboydodartinc/components/kasy_card.dart';
import 'package:cowboydodartinc/components/kasy_date_picker.dart';
import 'package:cowboydodartinc/components/kasy_spinner.dart';
import 'package:cowboydodartinc/components/kasy_tabs.dart';
import 'package:cowboydodartinc/components/kasy_time_picker.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/features/local_reminders/providers/reminder_notifier.dart';
import 'package:cowboydodartinc/features/local_reminders/repositories/reminder_preferences.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/settings_subpage_scaffold.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/settings_tile.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ReminderPage extends ConsumerWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(reminderProvider);
    final tr = Translations.of(context).reminderPage;

    return SettingsSubpageScaffold(
      title: tr.title,
      body: asyncState.when(
        loading: () => const Center(child: KasySpinner()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (state) => _ReminderForm(state: state),
      ),
    );
  }
}

class _ReminderForm extends ConsumerWidget {
  final ReminderState state;

  const _ReminderForm({required this.state});

  // Tab order mirrors the type selector left-to-right.
  static const List<ReminderType> _types = <ReminderType>[
    ReminderType.daily,
    ReminderType.weekly,
    ReminderType.specificDate,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).reminderPage;
    final notifier = ref.read(reminderProvider.notifier);

    // Width + horizontal gutter + the top gap below the chrome are owned by
    // [SettingsSubpageScaffold] / [KasyOverlayScaffold].
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The master toggle reads like a Settings row: a colored icon
          // badge, the label, and a live one-line summary of when the
          // reminder fires (or a hint when it's off) as the subtitle.
          KasyCard(
            borderRadius: KasyRadius.lgBorderRadius,
            child: SettingsSwitchTile(
              icon: KasyIcons.notification,
              iconBackgroundColor: context.colors.primary,
              title: tr.toggleLabel,
              subtitle: _scheduleSummary(context, state),
              value: state.enabled,
              onChanged: notifier.setEnabled,
            ),
          ),
          if (state.enabled) ...[
            const SizedBox(height: KasySpacing.xl),
            _FieldLabel(tr.typeLabel),
            const SizedBox(height: KasySpacing.sm),
            // Fill mode so the three options split the width equally
            // (a segmented control), instead of hug mode where each tab
            // only takes its own text width and the spacing looks uneven.
            KasyTabs(
              tabs: [tr.daily, tr.weekly, tr.specificDate],
              selectedIndex: _types.indexOf(state.type),
              onTabSelected: (i) => notifier.setType(_types[i]),
              mode: KasyTabsMode.fill,
            ),
            // Pick the day/date BEFORE the time so the schedule reads in a
            // natural order (which day → at what time).
            if (state.type == ReminderType.weekly) ...[
              const SizedBox(height: KasySpacing.lg),
              _FieldLabel(tr.dayLabel),
              const SizedBox(height: KasySpacing.sm),
              _DaySelector(
                current: state.dayOfWeek,
                onChanged: notifier.setDayOfWeek,
              ),
            ],
            if (state.type == ReminderType.specificDate) ...[
              const SizedBox(height: KasySpacing.lg),
              _FieldLabel(tr.dateLabel),
              const SizedBox(height: KasySpacing.sm),
              KasyDatePicker(
                value: state.date,
                minDate: DateTime.now(),
                onChanged: (picked) {
                  // Keep the previously chosen time when the day changes.
                  final DateTime? base = state.date;
                  notifier.setDate(
                    DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      base?.hour ?? 9,
                      base?.minute ?? 0,
                    ),
                  );
                },
              ),
            ],
            // Time is shared by every type. daily / weekly schedule by a
            // wall-clock time (hour + minute); specificDate carries its own
            // time inside the chosen date.
            const SizedBox(height: KasySpacing.lg),
            _FieldLabel(tr.timeLabel),
            const SizedBox(height: KasySpacing.sm),
            if (state.type == ReminderType.specificDate)
              KasyTimePicker(
                value: TimeOfDay(
                  hour: state.date?.hour ?? 9,
                  minute: state.date?.minute ?? 0,
                ),
                onChanged: (picked) {
                  // Keep the previously chosen day when the time changes.
                  final DateTime base = state.date ?? DateTime.now();
                  notifier.setDate(
                    DateTime(
                      base.year,
                      base.month,
                      base.day,
                      picked.hour,
                      picked.minute,
                    ),
                  );
                },
              )
            else
              KasyTimePicker(
                value: TimeOfDay(hour: state.hour, minute: state.minute),
                onChanged: (picked) =>
                    notifier.setTime(picked.hour, picked.minute),
              ),
          ],
        ],
    );
  }
}

/// Human-readable, one-line description of the active schedule used as the
/// toggle subtitle. Reads "Every day at 09:00" / "Monday at 09:00" /
/// "On June 15 at 09:00", and falls back to a hint while the reminder is off
/// (or asks for a date when a specific-date reminder has none yet).
String _scheduleSummary(BuildContext context, ReminderState state) {
  final tr = Translations.of(context).reminderPage;
  if (!state.enabled) return tr.hint;

  final String locale = Localizations.localeOf(context).toString();
  String pad(int v) => v.toString().padLeft(2, '0');

  switch (state.type) {
    case ReminderType.daily:
      return tr.summaryDaily(time: '${pad(state.hour)}:${pad(state.minute)}');
    case ReminderType.weekly:
      // January 2024 starts on a Monday, so day-of-month N maps to weekday N.
      // DateFormat already cases the weekday per locale (e.g. "Tuesday" vs the
      // lowercase "terça-feira"), so we use it as-is inside the summary.
      final String day = DateFormat.EEEE(
        locale,
      ).format(DateTime(2024, 1, state.dayOfWeek));
      return tr.summaryWeekly(
        day: day,
        time: '${pad(state.hour)}:${pad(state.minute)}',
      );
    case ReminderType.specificDate:
      final DateTime? date = state.date;
      if (date == null) return tr.selectDate;
      return tr.summaryDate(
        date: DateFormat.MMMMd(locale).format(date),
        time: '${pad(date.hour)}:${pad(date.minute)}',
      );
  }
}

/// Quiet group eyebrow above each field — the design-system section label
/// (small, gently tracked, muted), matching the Settings / sidebar pattern.
/// The small left inset aligns it with the Settings section labels.
class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: KasySpacing.xs),
      child: Text(
        label,
        style: context.kasyTextTheme.sectionLabel.copyWith(
          color: context.colors.muted,
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  final int current;
  final ValueChanged<int> onChanged;

  const _DaySelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // 1=Monday ... 7=Sunday (matches DateTime.weekday). Short weekday names are
    // localized via intl, so the chips read correctly in every app language
    // instead of being hardcoded to one locale.
    final DateFormat format = DateFormat.E(
      Localizations.localeOf(context).toString(),
    );
    // January 2024 starts on a Monday, so day-of-month N maps to weekday N (1..7).
    String shortName(int weekday) => format.format(DateTime(2024, 1, weekday));
    // Equal-width strip: the 7 days split the row so they fill the width on a
    // single line (no left-cramped pills with a trailing gap), matching the
    // "Repeat" segmented control above. Text stays 12 (on the type ladder) — the
    // bigger feel comes from the wider segments + taller tap targets, not a font
    // bump that would wrap the row to a second line.
    return Row(
      children: [
        for (int i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: KasySpacing.xs),
          Expanded(
            child: _DayPill(
              label: shortName(i + 1),
              selected: current == i + 1,
              onTap: () => onChanged(i + 1),
            ),
          ),
        ],
      ],
    );
  }
}

/// One equal-width day segment in the [_DaySelector] strip. Mirrors the KasyChip
/// accent/neutral colours, but fills its slot — KasyChip's padding is too wide
/// to fit seven across a phone, so a compact segment keeps the row on one line.
class _DayPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DayPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final Color background = selected
        ? c.primary
        : c.neutral.withValues(alpha: 0.5);
    final Color foreground = selected
        ? c.primaryForeground
        : c.neutralForeground;
    return KasyHover(
      onTap: onTap,
      focusable: true,
      borderRadius: BorderRadius.circular(KasyRadius.full),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(KasyRadius.full),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          // 12 / w500 — same as the chip it replaces (on the type ladder).
          style: context.textTheme.bodySmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
