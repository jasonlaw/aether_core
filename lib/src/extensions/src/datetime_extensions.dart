extension AetherDateTimeExtensions on DateTime {
  bool get isToday =>
      this.startOfDay.isAtSameMomentAs(DateTime.now().startOfDay);

  bool get isBeforeToday => this.startOfDay.isBefore(DateTime.now().startOfDay);

  bool isSameDay(DateTime other) =>
      this.year == other.year &&
      this.month == other.month &&
      this.day == other.day;

  DateTime get startOfWeek {
    final sod = this.startOfDay;
    return sod.subtract(Duration(days: sod.weekday));
  }

  DateTime get startOfDay => DateTime(this.year, this.month, this.day);
  DateTime get startOfNextDay => this.startOfDay.add(Duration(days: 1));
  DateTime get startOfPreviousDay =>
      this.startOfDay.subtract(Duration(days: 1));

  DateTime withTime(DateTime time) => DateTime(
        this.year,
        this.month,
        this.day,
        time.hour,
        time.minute,
        time.second,
        time.microsecond,
        time.microsecond,
      );
}
