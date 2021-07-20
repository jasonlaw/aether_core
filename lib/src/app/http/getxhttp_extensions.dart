part of 'getxhttp.dart';

extension AetherGetxHttpGQLResponseExtensions on GraphQLResponse {
  String? get errorText {
    if (this.isOk) return null;
    if (this.graphQLErrors == null || this.graphQLErrors!.isEmpty)
      return this.statusText;
    return this.graphQLErrors!.first.message;
  }
}

extension AetherGetxHttpResponseExtensions on Response {
  String? get errorText {
    if (this.isOk) return null;
    var body = this.body;
    if (body == null || body.toString() == "") return this.statusText;
    if (body is List) body = body.first;
    if (body is! Map) return "$body";
    return body["message"] ?? "Unknown error occur".tr;
  }

  E? toEntity<E extends Entity>(EntityBuilder<E> createEntity) {
    if (this.hasError || this.statusCode != 200) return null;
    return createEntity()..load(this.body);
  }

  List<T>? toList<T extends Entity>(EntityBuilder<T> createEntity) {
    if (this.hasError || this.statusCode != 200) return null;
    var list = this.body.addMap((data) => createEntity()..load(data));
    return <T>[]..assignAll(list);
  }
}
