import 'package:intl/intl.dart';

extension DateExt on DateTime {
  String toDateString() => DateFormat('yyyy-MM-dd').format(this);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// check if this date is after the other date without taking into account the time
  bool isAfterDay(DateTime other) =>
      year > other.year ||
      (year == other.year && month > other.month) ||
      (year == other.year && month == other.month && day > other.day);

  /// check if this date is before the other date without taking into account the time
  bool isBeforeDay(DateTime other) =>
      year < other.year ||
      (year == other.year && month < other.month) ||
      (year == other.year && month == other.month && day < other.day);

  /// Get the previous week's same weekday (subtract 7 days)
  DateTime get previousWeek => subtract(const Duration(days: 7));

  DateTime get toStartOfDay => DateTime(year, month, day);

  String toIso8601SecondsString() {
    final res = DateFormat('yyyy-MM-ddTHH:mm').format(toUtc());
    return '$res:00Z';
  }
}
