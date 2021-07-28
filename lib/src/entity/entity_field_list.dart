part of 'entity.dart';

/// Example:
/// late final EntityListField<Entity> entities = this.fieldList("entities");
class ListField<E extends Entity> extends FieldBase<List<E>> {
  ListField._(
    Entity entity, {
    required String name,
    String? label,
  })  : _list = <E>[],
        super(entity, name: name, label: label);

  final List<E> _list;
  late final EntityBuilder<E> _createEntity;

  List<E> call() => this.value;

  Rx<ListField<E>> get rx => _rx ??= Rx<ListField<E>>(this);
  Rx<ListField<E>>? _rx;

  @override
  List<E> get value {
    _getDefault() {
      return entity.data[name] = entity.data[name] = _list;
    }

    return entity[name] ?? _getDefault();
  }

  @override
  void innerLoad(dynamic rawData, {bool copy = false}) {
    if (isComputed) return;
    if (rawData != null) {
      entity[name] = _fieldOnLoading!.call(rawData);
    }
    if (!copy) _fieldOnLoaded?.call(value);
  }

  @override
  void updateState() {
    super.updateState();
    _rx?.refresh();
  }

  @override
  void reset() {
    _list.clear();
    super.reset();
  }

  ListField<E> register(
    EntityBuilder<E> createEntity,
  ) {
    _createEntity = createEntity;
    this._fieldOnLoading = (rawData) {
      _list.clear();
      rawData.forEach((data) {
        final E entity = _createEntity();
        entity.load(data);
        entity._parentRef = this;
        _list.add(entity);
      });
      return _list;
    };
    return this;
  }

  void load(List rawData) {
    assert(!isComputed, "Not allowed to load data into a computed field $name");
    this.innerLoad(rawData);
  }

  E operator [](int index) => this.value[index];

  void sort([int compare(E a, E b)?]) {
    this.value.sort(compare);
    this.updateState();
  }

  bool get isEmpty => this.value.isEmpty;
  bool get isNotEmpty => this.value.isNotEmpty;

  void clear() {
    this.value.clear();
    this.updateState();
  }

  void add(E entity) {
    this.value.add(entity);
    entity._parentRef = this;
    this.updateState();
  }

  void addAll(Iterable<E> entities) {
    entities.forEach((entity) => entity._parentRef = this);
    this.value.addAll(entities);
    this.updateState();
  }

  void assignAll(Iterable<E> entities) {
    this.value.clear();
    this.addAll(entities);
  }

  void insert(int index, E entity) {
    this.value.insert(index, entity);
    entity._parentRef = this;
    this.updateState();
  }

  bool remove(E entity) {
    var foundAndRemoved = this.value.remove(entity);
    if (foundAndRemoved) {
      entity._parentRef = null;
      this.updateState();
    }
    return foundAndRemoved;
  }

  void removeAt(int index) {
    this.value.removeAt(index);
    this.updateState();
  }

  void removeLast() {
    this.value.removeLast();
    this.updateState();
  }

  Iterator<E> get iterator => this.value.iterator;
  int get length => this.value.length;
  E get first => this.value.first;
  E? get firstOrDefault => this.value.firstOrDefault;
  E get last => this.value.last;
  Iterable<E> where(bool Function(E) test) => value.where(test);
  bool any(bool Function(E) test) => value.any(test);
  E firstWhere(bool test(E element), {E orElse()?}) =>
      value.firstWhere(test, orElse: orElse);
}
