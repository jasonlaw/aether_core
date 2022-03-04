extension AetherDateTimeExtensions on DateTime {
  bool get isToday => startOfDay.isAtSameMomentAs(DateTime.now().startOfDay);

  bool get isBeforeToday => startOfDay.isBefore(DateTime.now().startOfDay);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime get startOfWeek {
    final sod = startOfDay;
    return sod.subtract(Duration(days: sod.weekday));
  }

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get startOfNextDay => startOfDay.add(const Duration(days: 1));
  DateTime get startOfPreviousDay =>
      startOfDay.subtract(const Duration(days: 1));

  DateTime withTime(DateTime time) => DateTime(
        year,
        month,
        day,
        time.hour,
        time.minute,
        time.second,
        time.microsecond,
        time.microsecond,
      );
}
