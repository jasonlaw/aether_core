part of 'entity.dart';

extension AetherRxEntityExtensions on Rx<Entity> {
  T of<T extends Entity>() => this.value as T;
}

extension AetherEntityExtensions<E extends Entity> on E {
  GraphQLEntity<E> gql(
    String name,
    List<dynamic> query(E entity), {
    Map<String, dynamic>? params,
    Map<String, String>? paramTypes,
  }) {
    return GraphQLEntity<E>._(name, this, query(this), params, paramTypes);
  }
}
