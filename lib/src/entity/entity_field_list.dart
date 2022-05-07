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
    _rx?.forceRefresh();
    if (exclusive) _rxEx?.forceRefresh();
  }

  void register(
    EntityBuilder<E> createEntity,
  ) {
    _createEntity = createEntity;
    _fieldOnLoading = (rawData) {
      final list = <E>[];
      rawData.forEach((data) {
        final entity = _createEntity();
        entity.load(data);
        entity._parentRef = this;
        list.add(entity);
      });
      return list;
    };
    //return this;
  }

  void load(List rawData) {
    assert(!isComputed, 'Not allowed to load data into a computed field $name');
    innerLoad(rawData);
  }

  E operator [](int index) => value[index];

  void sort([int Function(E a, E b)? compare]) {
    value.sort(compare);
    updateState(exclusive: true);
  }

  void clear() {
    value.clear();
    updateState(exclusive: true);
  }

  void add(E entity) {
    value.add(entity);
    entity._parentRef = this;
    updateState(exclusive: true);
  }

  void addAll(Iterable<E> entities) {
    for (var entity in entities) {
      entity._parentRef = this;
    }
    value.addAll(entities);
    updateState(exclusive: true);
  }

  void assignAll(Iterable<E> entities) {
    value.clear();
    addAll(entities);
  }

  void insert(int index, E entity) {
    value.insert(index, entity);
    entity._parentRef = this;
    updateState(exclusive: true);
  }

  bool remove(E entity) {
    var foundAndRemoved = value.remove(entity);
    if (foundAndRemoved) {
      entity._parentRef = null;
      updateState(exclusive: true);
    }
    return foundAndRemoved;
  }

  void removeAt(int index) {
    value.removeAt(index);
    updateState(exclusive: true);
  }

  void removeLast() {
    value.removeLast();
    updateState(exclusive: true);
  }

  void removeWhere(bool Function(E element) test) {
    value.removeWhere(test);
    updateState(exclusive: true);
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

  E firstWhere(bool Function(E element) test, {E Function()? orElse}) =>
      value.firstWhere(test, orElse: orElse);
  E? firstWhereOrDefault(bool Function(E element) test) {
    try {
      return value.firstWhere(test);
    } on Exception catch (_) {
      return null;
    }
  }

  bool every(bool Function(E element) test) => value.every(test);

  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) =>
      value.fold<T>(initialValue, combine);

  void forEach(void Function(E element) f) => value.forEach(f);

  static ListField<E> create<E extends Entity>({EntityBuilder<E>? register}) {
    final list = Entity().fieldList<E>(E.runtimeType.toString());
    if (register != null) list.register(register);
    return list;
  }

  /// Get the ListField (parent) of the entity
  static ListField<E>? of<E extends Entity>(E child) {
    final lf = child._parentRef;
    if (lf is ListField<E>) return lf;
    return null;
  }
}
