part of 'app_http_client.dart';

//extension AppHttpClientResponseNullExtensions on Response? {}

extension DioRequestOptionsHelper on RequestOptions {
  bool get isGQL => extra.hasFlag('GQL');
  bool get isExternal => extra.hasFlag('EXTERNAL');
  bool get isRenewCredential => extra.hasFlag('RENEW_CREDENTIAL');
  bool get isLoadingIndicator => extra.hasFlag('LOADING_INDICATOR');
  bool get isSignOut => extra.hasFlag('SIGN_OUT');
  bool get isRetry => extra.hasFlag('RETRY');
  void setRetryFlag() => extra['RETRY'] = true;
}

extension DioResponseHelper on Response {
  E toEntity<E extends Entity>(EntityBuilder<E> createEntity) {
    return createEntity()..load(data);
  }

  List<T> toList<T extends Entity>(EntityBuilder<T> createEntity) {
    return (data as List).map((item) => createEntity()..load(item)).toList();
  }

  bool get gqlErrors => requestOptions.isGQL && data['errors'] != null;

  String? get gqlErrorCode => data['errors']?.first?['extensions']?['code'];

  String? get gqlErrorMessage => data['errors']?.first?['message'];

  bool get isUnauthorized {
    return !extra.hasFlag('RENEW_CREDENTIAL') &&
        ((statusCode == 401) ||
            (gqlErrors && gqlErrorCode == 'UNAUTHORIZED_ACCESS'));
  }

  bool get noContent => statusCode == 204;
}

extension AppHttpClientQuickApiOnStringExtensions on String {
  GraphQLQuery gql(List<dynamic> fields, {Map<String, dynamic>? params}) {
    return GraphQLQuery(this, fields, input: params);
  }

  GraphQLQuery gqlFr<T extends Entity>(
      EntityBuilder<T> source, List Function(T source) fn,
      {Map<String, dynamic>? params}) {
    return GraphQLQuery(this, fn(source()), input: params);
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
    return GraphQLQuery(name, fields, input: params);
  }

  GraphQLQuery gqlFr<T extends Entity>(
      EntityBuilder<T> source, List Function(T source) fn,
      {Map<String, dynamic>? params}) {
    return GraphQLQuery(name, fn(source()), input: params);
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
