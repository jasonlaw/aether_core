part of 'entity.dart';

/// Example:
/// late final EntityListField<Entity> entities = this.fieldList("entities");
class EntityListField<E extends Entity> extends EntityFieldBase<List<E>> {
  EntityListField._(
    Entity entity, {
    required String name,
    String? label,
  }) : super(entity, name: name, label: label) {
    this.defaultBuilder = () => <E>[];
  }

  List<E> call() => this.value!;

  Rx<EntityListField<E>> get rx => _rx ??= Rx<EntityListField<E>>(this);
  Rx<EntityListField<E>>? _rx;

  @override
  void updateState() {
    super.updateState();
    _rx?.refresh();
  }

  void onLoading(
    EntityBuilder<E> createEntity,
  ) {
    this._fieldOnLoading = (rawData) {
      final list = <E>[];
      rawData.forEach((data) {
        final E entity = createEntity();
        entity.load(data);
        entity._listFieldRef = this;
        list.add(entity);
      });
      return list;
    };
  }

  void load(List rawData) {
    assert(!isComputed, "Not allowed to load data into a computed field $name");
    this._load(rawData);
  }

  E operator [](int index) => this.value![index];

  void sort([int compare(E a, E b)?]) {
    this.value!.sort(compare);
    this.updateState();
  }

  bool get isEmpty => this.value!.isEmpty;
  bool get isNotEmpty => this.value!.isNotEmpty;

  void clear() {
    this.value!.clear();
    this.updateState();
  }

  void add(E entity) {
    this.value!.add(entity);
    entity._listFieldRef = this;
    this.updateState();
  }

  void addAll(Iterable<E> entities) {
    entities.forEach((entity) => entity._listFieldRef = this);
    this.value!.addAll(entities);
    this.updateState();
  }

  void assignAll(Iterable<E> entities) {
    this.value!.clear();
    this.addAll(entities);
  }

  void insert(int index, E entity) {
    this.value!.insert(index, entity);
    entity._listFieldRef = this;
    this.updateState();
  }

  bool remove(E entity) {
    var foundAndRemoved = this.value!.remove(entity);
    if (foundAndRemoved) {
      entity._listFieldRef = null;
      this.updateState();
    }
    return foundAndRemoved;
  }

  void removeAt(int index) {
    this.value!.removeAt(index);
    this.updateState();
  }

  void removeLast() {
    this.value!.removeLast();
    this.updateState();
  }

  Iterator<E> get iterator => this.value!.iterator;
  int get length => this.value!.length;
  E get first => this.value!.first;
  E? get firstOrDefault => this.value!.firstOrDefault;
  E get last => this.value!.last;
  Iterable<E> where(bool Function(E) test) => value!.where(test);
  bool any(bool Function(E) test) => value!.any(test);
  E firstWhere(bool test(E element), {E orElse()?}) =>
      value!.firstWhere(test, orElse: orElse);
}
