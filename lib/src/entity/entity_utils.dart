part of 'entity.dart';

class ValueTransformers {
  ValueTransformers._();

  // static final _parseUtcFormat =
  //     RegExp(r'^([+-]?\d{4,6})-?(\d\d)-?(\d\d)' // Day part.
  //         r'(?:[ T](\d\d)(?::?(\d\d)(?::?(\d\d)(?:[.,](\d+))?)?)?' // Time part.
  //         r'( ?[zZ]| ?([-+])(\d\d)(?::?(\d\d))?)?)?$'); // Timezone part.

  // static ValueTransform jsonEncode() {
  //   return (val) {
  //     if (val is DateTime) {
  //       // Convert to Utc format
  //       return "${DateFormat("yyyy-MM-dd").format(val)}T${DateFormat("HH:mm:ss").format(val)}Z";
  //     }
  //     return val?.toString();
  //   };
  // }

  static ValueTransform system() {
    return (val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is! String) return val;
      final dateTimeValue = DateTime.tryParse(val);
      if (dateTimeValue == null) return val;
      if (num.tryParse(val) != null) return val;
      if (dateTimeValue.year == 1) return null;
      return App.useLocalTimezoneInHttp
          ? DateTime(
              dateTimeValue.year,
              dateTimeValue.month,
              dateTimeValue.day,
              dateTimeValue.hour,
              dateTimeValue.minute,
              dateTimeValue.second,
              dateTimeValue.millisecond,
              dateTimeValue.microsecond)
          : dateTimeValue.toLocal();
    };
  }

  // static ValueTransform toLocalDateTime() {
  //   return (val) {
  //     var dateTimeValue = DateTime.tryParse(val);
  //     if (dateTimeValue != null) {
  //       if (dateTimeValue.year == 1) return null;
  //       return dateTimeValue.toLocal();
  //     }
  //     return dateTimeValue;
  //   };
  // }

  // static ValueTransform toDateTime() {
  //   return (val) {
  //     var dateTimeValue = DateTime.tryParse(val);
  //     if (dateTimeValue != null) {
  //       if (dateTimeValue.year == 1) return null;
  //     }
  //     return dateTimeValue;
  //   };
  // }

  // static ValueTransform toDouble({int decimals}) {
  //   return (val) {
  //     double value;
  //     if (val is int)
  //       value = val.toDouble();
  //     else if (val is String)
  //       value = num.tryParse(val);
  //     else
  //       value = val;
  //     if (decimals != null)
  //       value = (value * pow(10, decimals)).round() / pow(10, decimals);
  //     return value;
  //   };
  // }
}
