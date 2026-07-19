import 'package:shared_preferences/shared_preferences.dart';

enum ReminderType { daily, weekly, specificDate }

class ReminderState {
  final bool enabled;
  final ReminderType type;
  final int hour;
  final int minute;
  final int dayOfWeek;
  final DateTime? date;

  const ReminderState({
    this.enabled = false,
    this.type = ReminderType.daily,
    this.hour = 9,
    this.minute = 0,
    this.dayOfWeek = 1,
    this.date,
  });

  ReminderState copyWith({
    bool? enabled,
    ReminderType? type,
    int? hour,
    int? minute,
    int? dayOfWeek,
    DateTime? date,
    bool clearDate = false,
  }) =>
      ReminderState(
        enabled: enabled ?? this.enabled,
        type: type ?? this.type,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        date: clearDate ? null : (date ?? this.date),
      );
}

// ignore: avoid_classes_with_only_static_members
class ReminderPreferences {
  static const _enabledKey = 'reminder_enabled';
  static const _typeKey = 'reminder_type';
  static const _hourKey = 'reminder_hour';
  static const _minuteKey = 'reminder_minute';
  static const _dayOfWeekKey = 'reminder_day_of_week';
  static const _dateKey = 'reminder_date_ms';

  static Future<ReminderState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final dateMs = prefs.getInt(_dateKey);
    return ReminderState(
      enabled: prefs.getBool(_enabledKey) ?? false,
      type: ReminderType.values[prefs.getInt(_typeKey) ?? 0],
      hour: prefs.getInt(_hourKey) ?? 9,
      minute: prefs.getInt(_minuteKey) ?? 0,
      dayOfWeek: prefs.getInt(_dayOfWeekKey) ?? 1,
      date: dateMs != null ? DateTime.fromMillisecondsSinceEpoch(dateMs) : null,
    );
  }

  static Future<void> save(ReminderState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, state.enabled);
    await prefs.setInt(_typeKey, state.type.index);
    await prefs.setInt(_hourKey, state.hour);
    await prefs.setInt(_minuteKey, state.minute);
    await prefs.setInt(_dayOfWeekKey, state.dayOfWeek);
    if (state.date != null) {
      await prefs.setInt(_dateKey, state.date!.millisecondsSinceEpoch);
    } else {
      await prefs.remove(_dateKey);
    }
  }
}
