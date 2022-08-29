part of 'app_http_client.dart';

extension AppHttpClientResponseNullExtensions on Response? {}

extension AppHttpClientResponseExtensions on Response {
  E toEntity<E extends Entity>(EntityBuilder<E> createEntity) {
    return createEntity()..load(data);
  }

  List<T> toList<T extends Entity>(EntityBuilder<T> createEntity) {
    return (data as List).map((item) => createEntity()..load(item)).toList();
  }

  bool get isUnauthorized {
    return !extra.hasFlag('RENEW_CREDENTIAL') &&
        ((statusCode == 401) ||
            (extra.hasFlag('GQL') &&
                data != null &&
                data['errors'] != null &&
                data['errors'].any((e) => e['code'] == 'UNAUTHORIZED_ACCESS')));
  }

  bool get noContent => statusCode == 204;
}

extension AppHttpClientQuickApiOnStringExtensions on String {
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

extension AppHttpClientQuickApiOnFieldExtensions on FieldBase {
  GraphQLQuery gql(List<dynamic> fields, {Map<String, dynamic>? params}) {
    return GraphQLQuery(name, fields, params: params);
  }
}

extension AppHttpClientQuickApiOnMapExtensions on Map<String, dynamic> {
  RestBody get asFormData => RestBody(formData: true)..addMap(this);
}

extension AppHttpClientQuickApiMapNullExtensions on Map<String, dynamic>? {
  Map<String, dynamic> union(Map<String, dynamic> other) {
    final map = <String, dynamic>{};
    if (this != null) map.addAll(this!);
    map.addAll(other);
    return map;
  }
}
