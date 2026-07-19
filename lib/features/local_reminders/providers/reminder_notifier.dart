import 'package:cowboydodartinc/core/states/translations.dart';
import 'package:cowboydodartinc/features/local_reminders/repositories/reminder_preferences.dart';
import 'package:cowboydodartinc/features/notifications/api/local_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reminder_notifier.g.dart';

const _kReminderId = 42;

@Riverpod(keepAlive: true)
class ReminderNotifier extends _$ReminderNotifier {
  @override
  Future<ReminderState> build() {
    return ReminderPreferences.load();
  }

  Future<void> setEnabled(bool value) async {
    final current = state.requireValue;
    await _applyAndSave(current.copyWith(enabled: value));
  }

  Future<void> setType(ReminderType type) async {
    final current = state.requireValue;
    // Leaving "specific date" drops the stored one-off date so it doesn't
    // linger (and silently come back) if the user returns to that mode later.
    await _applyAndSave(
      current.copyWith(
        type: type,
        clearDate: type != ReminderType.specificDate,
      ),
    );
  }

  Future<void> setTime(int hour, int minute) async {
    final current = state.requireValue;
    await _applyAndSave(current.copyWith(hour: hour, minute: minute));
  }

  Future<void> setDayOfWeek(int day) async {
    final current = state.requireValue;
    await _applyAndSave(current.copyWith(dayOfWeek: day));
  }

  Future<void> setDate(DateTime date) async {
    final current = state.requireValue;
    await _applyAndSave(current.copyWith(date: date));
  }

  Future<void> _applyAndSave(ReminderState next) async {
    state = AsyncData(next);
    final notifier = ref.read(localNotifierProvider);
    await notifier.cancel(_kReminderId);

    if (next.enabled) {
      final tr = ref.read(translationsProvider).dailyReminder;
      switch (next.type) {
        case ReminderType.daily:
          await notifier.scheduleDailyAt(
            notificationId: _kReminderId,
            title: tr.title,
            body: tr.body,
            hour: next.hour,
            minute: next.minute,
          );
        case ReminderType.weekly:
          await notifier.scheduleWeekly(
            notificationId: _kReminderId,
            title: tr.title,
            body: tr.body,
            dayOfWeekIndex: next.dayOfWeek,
            hour: next.hour,
            minute: next.minute,
          );
        case ReminderType.specificDate:
          if (next.date != null) {
            await notifier.scheduleAt(
              notificationId: _kReminderId,
              title: tr.title,
              body: tr.body,
              date: next.date!,
            );
          }
      }
    }

    await ReminderPreferences.save(next);
  }
}
