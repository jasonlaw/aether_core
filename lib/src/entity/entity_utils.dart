part of 'entity.dart';

class ValueTransformers {
  ValueTransformers._();

  static ValueTransform system() {
    return (val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is! String) return val;
      var dateTimeValue = DateTime.tryParse(val);
      if (dateTimeValue == null) return val;
      if (num.tryParse(val) != null) return val;
      if (dateTimeValue.year == 1) return null;
      if (dateTimeValue.isUtc) return dateTimeValue.toLocal();

      // if (dateTimeValue.isUtc) return dateTimeValue.toLocal();
      // print('isUtc = ${dateTimeValue.isUtc}');
      // print(val);
      // print(dateTimeValue.toLocal());
      // print(dateTimeValue.toUtc());
      // print(dateTimeValue.toString());
      // print(dateTimeValue.toIso8601String());
      // print(dateTimeValue.timeZoneOffset);
      return dateTimeValue;
      //     return DateTime(
      //         dateTimeValue.year,
      //         dateTimeValue.month,
      //         dateTimeValue.day,
      //         dateTimeValue.hour,
      //         dateTimeValue.minute,
      //         dateTimeValue.second,
      //         dateTimeValue.millisecond,
      //         dateTimeValue.microsecond);
    };
  }
}
