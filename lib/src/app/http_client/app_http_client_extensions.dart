part of 'app_http_client.dart';

extension AppHttpClientResponseExtensions on Response? {
  bool hasDataErrorCode(String code) {
    return this?.data != null &&
        this!.data['errors']?.any((e) => e['code'] == code);
  }
}

extension AppHttpClientApiOnStringExtensions on String {
  GraphQLQuery gql(List<dynamic> fields, {Map<String, dynamic>? params}) {
    return GraphQLQuery(this, fields, params: params);
  }

  RestQuery api({
    dynamic body,
    Map<String, dynamic>? query,
  }) {
    return RestQuery(this, body: body, query: query);
  }
}

extension AppHttpClientApiOnFieldExtensions on FieldBase {
  GraphQLQuery gql(List<dynamic> fields, {Map<String, dynamic>? params}) {
    return GraphQLQuery(name, fields, params: params);
  }
}

extension AppHttpClientApiOnMapExtensions on Map<String, dynamic> {
  RestBody get asFormData => RestBody(formData: true)..addMap(this);
}

extension AppHttpClientMapExtensions on Map<String, dynamic>? {
  Map<String, dynamic> union(Map<String, dynamic> other) {
    final map = <String, dynamic>{};
    if (this != null) map.addAll(this!);
    map.addAll(other);
    return map;
  }
}
