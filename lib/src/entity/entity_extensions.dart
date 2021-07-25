part of 'entity.dart';

extension AetherRxEntityExtensions on Rx<Entity> {
  T of<T extends Entity>() => this.value as T;
}

// extension AetherRxnEntityExtensions on Rxn<Entity> {
//   T of<T extends Entity>() => this.value as T;
// }

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

extension AetherEntityListExtensions<T extends Entity> on List<T> {
  void load(EntityBuilder<T> createEntity, List<dynamic> rawData) {
    var list = rawData.map((data) => createEntity()..load(data));
    this.clear();
    this.addAll(list);
  }
}
