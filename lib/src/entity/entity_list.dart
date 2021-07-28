part of 'entity.dart';

class EntityList<E extends Entity> extends Entity {
  final EntityBuilder<E> createEntity;
  EntityList(this.createEntity) {
    list.register(createEntity);
  }

  @protected
  late final ListField<E> list = this.fieldList("data");

  Iterator<E> get iterator => list.iterator;
  int get length => list.length;
  E get first => list.first;
  E? get firstOrDefault => list.firstOrDefault;
  E get last => list.last;
  void sort([int compare(E a, E b)?]) => list.sort(compare);
  bool get isEmpty => list.isEmpty;
  void clear() => list.clear();
  void add(E entity) => list.add(entity);
  void addAll(Iterable<E> entities) => list.addAll(entities);
  void assignAll(Iterable<E> entities) => list.assignAll(entities);
  void insert(int index, E entity) => list.insert(index, entity);
  void remove(E entity) => list.remove(entity);
  void removeAt(int index) => list.removeAt(index);
  void removeLast() => list.removeLast();
  E item(int index) => list[index];
  Iterable<E> where(bool Function(E) test) => list.where(test);
  bool any(bool Function(E) test) => list.any(test);
  E firstWhere(bool test(E element), {E orElse()?}) =>
      list.firstWhere(test, orElse: orElse);
}
