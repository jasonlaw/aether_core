import 'words.dart';

class EnumUtils {
  static bool isEnumItem(dynamic enumItem) {
    final splitEnum = enumItem.toString().split('.');
    return splitEnum.length > 1 &&
        splitEnum[0] == enumItem.runtimeType.toString();
  }

  /// Convert an enum to a string
  ///
  /// Pass in the enum value, so TestEnum.valueOne into [enumItem]
  /// It will return the striped off value so "valueOne".
  ///
  /// If you pass in the option [camelCase]=true it will convert it to words
  /// So TestEnum.valueOne will become Value One
  static String convertToString(dynamic enumItem, {bool camelCase = false}) {
    assert(enumItem != null);
    assert(isEnumItem(enumItem),
        '$enumItem of type ${enumItem.runtimeType.toString()} is not an enum item');
    final tmp = enumItem.toString().split('.')[1];
    return !camelCase ? tmp : camelCaseToWords(tmp);
  }

  /// Convert an enum to a word for gql query
  ///
  /// Pass in the enum value, so TestEnum.valueOne into [enumItem]
  /// It will return the striped off value so "VALUE_ONE".
  static String convertToGqlWords(dynamic enumItem) {
    assert(enumItem != null);
    assert(isEnumItem(enumItem),
        '$enumItem of type ${enumItem.runtimeType.toString()} is not an enum item');
    final tmp = enumItem.toString().split('.')[1];
    return camelCaseToWords(tmp, separator: '_').toUpperCase();
  }

  /// Given a string, find and return its matching enum value
  ///
  /// You need to pass in the values of the enum object. So TestEnum.values
  /// in the first argument. The matching value is the second argument.
  ///
  /// Example final result = EnumToString.fromString(TestEnum.values, "valueOne")
  /// result == TestEnum.valueOne //true
  ///
  static T? fromString<T>(List<T> enumValues, String value,
      {bool camelCase = false}) {
    try {
      return enumValues.singleWhere((enumItem) =>
          convertToString(enumItem, camelCase: camelCase).toLowerCase() ==
          value.toLowerCase());
      // ignore: avoid_catching_errors
    } on StateError catch (_) {
      return null;
    }
  }

  /// Get the index of the enum value
  ///
  /// Pass in the enum values to argument one, so TestEnum.values
  /// Pass in the matching string to argument 2, so "valueOne"
  ///
  /// Eg. final index = EnumToString.indexOf(TestEnum.values, "valueOne")
  /// index == 0 //true
  static int indexOf<T>(List<T> enumValues, String value) {
    final fromStringResult = fromString<T>(enumValues, value);
    if (fromStringResult == null) {
      return -1;
    } else {
      return enumValues.indexOf(fromStringResult);
    }
  }

  /// Bulk convert enum values to a list
  ///
  static List<String> toList<T>(List<T> enumValues, {bool camelCase = false}) {
    final enumList = enumValues
        .map((t) => !camelCase
            ? convertToString(t)
            : convertToString(t, camelCase: true))
        .toList();

    // I am sure there is a better way to convert a nullable list to a
    // non-nullable one, but this will do until I find out how. Happy if
    // someone want to do a PR in the meantime to correct this.
    var output = <String>[];
    for (var value in enumList) {
      output.add(value);
    }
    return output;
  }

  /// Get a list of enums given a list of strings.
  /// Basically just EnumToString.fromString, but using lists
  ///
  /// As with fromString it is not case sensitive
  ///
  /// Eg. EnumToString.fromList(TestEnum.values, ["valueOne", "value2"]
  static List<T?> fromList<T>(List<T> enumValues, List valueList) {
    return List<T?>.from(
        valueList.map<T?>((item) => fromString(enumValues, item)));
  }
}
