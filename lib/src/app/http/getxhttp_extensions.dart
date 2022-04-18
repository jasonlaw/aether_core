part of 'getxhttp.dart';

extension GetxGQLResponseExtensions on GraphQLResponse {
  String? get errorText {
    if (isOk) return null;
    if (graphQLErrors == null || graphQLErrors!.isEmpty) return statusText;
    return graphQLErrors!.first.message;
  }
}

extension GetxResponseExtensions on Response {
  String get errorText {
    if (isOk) return '';
    var body = this.body;
    if (body == null || body.toString() == '') {
      return statusText ?? 'Unknown error'.tr;
    }
    if (body is List) body = body.first;
    if (body is! Map) return '$body';
    return body['message'] ?? 'Unknown error'.tr;
  }

  E toEntity<E extends Entity>(EntityBuilder<E> createEntity) {
    if (hasError) throw Exception(errorText);
    return createEntity()..load(body);
  }

  List<T> toList<T extends Entity>(EntityBuilder<T> createEntity) {
    if (hasError) throw Exception(errorText);
    return (body as List).map((data) => createEntity()..load(data)).toList();
  }
}

extension QuickApiOnStringExtensions on String {
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

extension QuickApiOnFieldExtensions on FieldBase {
  GraphQLQuery gql(
    List<dynamic> fields, {
    Map<String, dynamic>? params,
    Map<String, String>? paramTypes,
  }) {
    return GraphQLQuery(name, fields, params: params, paramTypes: paramTypes);
  }
}
