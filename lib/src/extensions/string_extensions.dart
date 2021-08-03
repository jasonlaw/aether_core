import '../app.dart';

extension AetherStringNullableExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}

extension AetherStringExtensions on String {
  /// check if the string is a date
  bool get isDate {
    try {
      DateTime.parse(this);
      return true;
    } catch (e) {
      return false;
    }
  }

  GraphQLQuery gql(
    List<dynamic> fields, {
    Map<String, dynamic>? params,
    Map<String, String>? paramTypes,
  }) {
    return GraphQLQuery(this, fields, params: params, paramTypes: paramTypes);
  }

  RestQuery api({
    dynamic body,
    Map<String, dynamic>? query,
  }) {
    return RestQuery(this, body: body, query: query);
  }
}
