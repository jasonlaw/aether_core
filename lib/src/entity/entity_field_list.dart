part of 'entity.dart';

/// Example:
/// late final EntityListField<Entity> entities = this.fieldList("entities");
class ListField<E extends Entity> extends FieldBase<List<E>> {
  ListField._(
    Entity entity, {
    required String name,
    String? label,
  }) : super(entity, name: name, label: label);

  //final List<E> _list;
  late final EntityBuilder<E> _createEntity;

  //List<E> call() => this.value;

  /// This will listen to any changes to the list, including its entity
  /// children.
  Rx<ListField<E>> get rx => _rx ??= Rx<ListField<E>>(this);
  Rx<ListField<E>>? _rx;

  /// This will listen to only changes to the list. Changes from its entity
  /// children will be ignored.
  Rx<ListField<E>> get rxEx => _rxEx ??= Rx<ListField<E>>(this);
  Rx<ListField<E>>? _rxEx;

  @override
  List<E> innerDefaultValue() => <E>[];

  @override
  List<E> get value {
    _getDefault() {
      final _value = innerDefaultValue();
      entity.data[name] = _value;
      return _value;
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
  void updateState({bool exclusive = false}) {
    super.updateState();
    _rx?.refresh();
    if (exclusive) _rxEx?.refresh();
  }

  // @override
  // void reset() {
  //   _list.clear();
  //   super.reset();
  // }

  ListField<E> register(
    EntityBuilder<E> createEntity,
  ) {
    _createEntity = createEntity;
    this._fieldOnLoading = (rawData) {
      final list = <E>[];
      rawData.forEach((data) {
        final E entity = _createEntity();
        entity.load(data);
        entity._parentRef = this;
        list.add(entity);
      });
      return list;
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
    this.updateState(exclusive: true);
  }

  void clear() {
    this.value.clear();
    this.updateState(exclusive: true);
  }

  void add(E entity) {
    this.value.add(entity);
    entity._parentRef = this;
    this.updateState(exclusive: true);
  }

  void addAll(Iterable<E> entities) {
    entities.forEach((entity) => entity._parentRef = this);
    this.value.addAll(entities);
    this.updateState(exclusive: true);
  }

  void assignAll(Iterable<E> entities) {
    this.value.clear();
    this.addAll(entities);
  }

  void insert(int index, E entity) {
    this.value.insert(index, entity);
    entity._parentRef = this;
    this.updateState(exclusive: true);
  }

  bool remove(E entity) {
    var foundAndRemoved = this.value.remove(entity);
    if (foundAndRemoved) {
      entity._parentRef = null;
      this.updateState(exclusive: true);
    }
    return foundAndRemoved;
  }

  void removeAt(int index) {
    this.value.removeAt(index);
    this.updateState(exclusive: true);
  }

  void removeLast() {
    this.value.removeLast();
    this.updateState(exclusive: true);
  }

  void removeWhere(bool test(E element)) {
    this.value.removeWhere(test);
    this.updateState(exclusive: true);
  }

  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;

  Iterator<E> get i => value.iterator;
  int get length => value.length;

  E get first => value.first;
  E? get firstOrDefault => value.firstOrDefault;

  E get last => value.last;
  E? get lastOrDefault => value.isEmpty ? null : value.last;

  Iterable<E> where(bool Function(E) test) => value.where(test);
  bool any(bool Function(E) test) => value.any(test);

  E firstWhere(bool test(E element), {E orElse()?}) =>
      value.firstWhere(test, orElse: orElse);
  E? firstWhereOrDefault(bool test(E element)) {
    try {
      return value.firstWhere(test);
    } catch (_) {
      return null;
    }
  }

  bool every(bool test(E element)) => value.every(test);

  T fold<T>(T initialValue, T combine(T previousValue, E element)) =>
      value.fold<T>(initialValue, combine);

  void forEach(void f(E element)) => value.forEach(f);

  static ListField<E> create<E extends Entity>() {
    return Entity().fieldList(E.runtimeType.toString());
  }

  static ListField<E>? of<E extends Entity>(E child) {
    final lf = child._parentRef;
    if (lf is ListField<E>) return lf;
    return null;
  }
}
