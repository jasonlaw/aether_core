part of 'app_http_client.dart';

extension AppHttpClientResponseNullExtensions on Response? {}

extension AppHttpClientResponseExtensions on Response {
  E toEntity<E extends Entity>(EntityBuilder<E> createEntity) {
    return createEntity()..load(data);
  }

  List<T> toList<T extends Entity>(EntityBuilder<T> createEntity) {
    return (data as List).map((item) => createEntity()..load(item)).toList();
  }

  bool isUnauthorized() {
    return !(extra['RENEW_CREDENTIAL'] ?? false) &&
        ((statusCode == 401) ||
            ((extra['GQL'] ?? false) &&
                data != null &&
                data['errors'] != null &&
                data['errors'].any((e) => e['code'] == 'UNAUTHORIZED_ACCESS')));
  }
}

extension AppHttpClientApiOnStringExtensions on String {
  GraphQLQuery gql(List<dynamic> fields, {Map<String, dynamic>? params}) {
    return GraphQLQuery(this, fields, params: params);
  }

  RestQuery api({
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) {
    return RestQuery(this, body: body, queryParameters: queryParameters);
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