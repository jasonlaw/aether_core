part of 'entity.dart';

extension RxGenericExtensions on Rx {
  void forceRefresh() {
    // replace the obsoleted refresh method.
    firstRebuild = false;
    trigger(value);
  }
}

extension RxEntityExtensions on Rx<Entity> {
  T of<T extends Entity>() => value as T;
}

extension RxEntityFieldExtensions<E> on Rx<Field<E>> {
  E? get field => value.value;
}

extension RxEntityListFieldExtensions<E extends Entity> on Rx<ListField<E>> {
  List<E> get list => value.value;
}

extension EntityExtensions<E extends Entity> on E {
  GraphQLEntity<E> gql(
    String name,
    List<dynamic> Function(E entity) query, {
    Map<String, dynamic>? params,
    Map<String, String>? paramTypes,
  }) {
    return GraphQLEntity<E>._(name, this, query(this), params, paramTypes);
  }
}

extension EntityFieldStringExtensions on Field<String> {
  bool get valueIsNullOrEmpty => value.isNullOrEmpty;
  bool get valueIsNotNullOrEmpty => value.isNotNullOrEmpty;
}

// extension ListOfEntityExtensions<E extends Entity> on List<E> {
//   void load(EntityBuilder<E> createEntity, List<dynamic> rawData) {
//     var list = rawData.map((data) => createEntity()..load(data));
//     this.clear();
//     this.addAll(list);
//   }
// }
