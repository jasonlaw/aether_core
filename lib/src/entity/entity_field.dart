part of 'entity.dart';

typedef ValueTransform<T> = T Function(dynamic value);
typedef ValueChanging<T> = T Function(T value);
typedef Computed<T> = T Function();

/// Example:
/// late final EntityField<String> someField = this.field("someFieldName");
class EntityField<T> {
  EntityField._(
    this.entity, {
    required this.name,
    String? label,
    T Function()? defaultValue,
  })  : assert(T is! List || defaultValue == null),
        _label = label ?? name {
    entity.fields[name] = this;
    if (defaultValue == null) {
      final val = T.defaultValue();
      if (val != null) {
        this._defaultValue = () => val as T;
      } else {
        this._defaultValue = () => null;
      }
    } else {
      this._defaultValue = defaultValue;
    }
  }

  final Entity entity;
  final String name;
  String _label;
  String get label => _label.tr;
  set label(String val) => _label = val;

  late final T? Function() _defaultValue;

  Rx<EntityField<T>> get rx => _rx ??= Rx<EntityField<T>>(this);
  Rx<EntityField<T>>? _rx;

  ValueTransform<T>? _fieldOnLoading;
  ValueChanged<T?>? _fieldOnLoaded;
  ValueChanged<T?>? _fieldOnChanged;

  Computed<T?>? _compute;
  Set<EntityField>? _computeBindings;
  bool get isComputed => _compute != null;

  T? get value {
    defaultValue() {
      if (entity.hasField(name)) return null;
      return entity.data[name] =
          _compute == null ? _defaultValue() : _compute!.call();
    }

    return entity[name] ?? defaultValue();
  }

  set value(T? value) {
    assert(!isComputed, "Not allowed to set value into a computed field $name");
    assert(T is! List, "Not allowed to set value for ListField");

    entity[name] = value;
  }

  @protected
  T call([T? value]) {
    if (value != null) this.value = value;
    return this.value!;
  }

  bool get valueIsNull => this.value == null;
  bool get valueIsNotNull => this.value != null;

  void onLoaded({required ValueChanged<T?> action}) => _fieldOnLoaded = action;

  void onChanged({required ValueChanged<T?> action}) =>
      _fieldOnChanged = action;

  void computed({
    required List<EntityField> bindings,
    required Computed<T?> compute,
  }) {
    bindings.forEach((bindingField) {
      var list = bindingField._computeBindings ??= Set();
      list.add(this);
    });
    _compute = compute;
  }

  void propagate() {
    if (this.isComputed) {
      entity[name] = _compute!();
    }
  }

  void _load(dynamic rawData, {bool copy = false}) {
    if (isComputed) return;
    if (rawData == null) {
      entity[name] = _defaultValue();
    } else {
      final transformer = _fieldOnLoading ?? ValueTransformers.system();
      entity[name] = transformer(rawData);
    }
    if (!copy) _fieldOnLoaded?.call(value);
  }

  @override
  String toString() => "$value";

  /// This equality override works for EntityField instances and the internal values.
  bool operator ==(o) {
    // Todo, find a common implementation for the hashCode of different Types.
    if (o is T) return this.value == o;
    if (o is EntityField<T>) return this.value == o.value;
    return false;
  }

  @override
  int get hashCode => this.value.hashCode;

  void reset() {
    if (isComputed) return;
    entity.data.remove(name);
    updateState();
  }

  void updateState() {
    _fieldOnChanged?.call(value);
    _rx?.refresh();
    entity.updateState();
    _computeBindings?.forEach((computedField) {
      computedField.propagate();
    });
    //entity.updateState();
  }
}

class EntityListField<E extends Entity> extends EntityField<List<E>> {
  EntityListField._(
    Entity entity, {
    required String name,
    String? label,
  }) : super._(
          entity,
          name: name,
          label: label,
          defaultValue: () => <E>[],
        );

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

  int get length => this.value!.length;
  E get first => this.value!.first;
  E? get firstOrDefault => this.value!.firstOrDefault;
  E get last => this.value!.last;
  void sort([int compare(E a, E b)?]) {
    this.value!.sort(compare);
    this.updateState();
  }

  bool get isEmpty => this.value!.isEmpty;

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

  Iterable<E> where(bool Function(E) test) {
    return value!.where(test);
  }

  bool any(bool Function(E) test) {
    return value!.any(test);
  }

  E firstWhere(bool test(E element), {E orElse()?}) {
    return value!.firstWhere(test, orElse: orElse);
  }
}
