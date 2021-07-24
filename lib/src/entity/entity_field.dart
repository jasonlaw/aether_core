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
    T? defaultValue,
  })  : _label = label ?? name,
        _defaultValue = defaultValue ?? T.defaultValue() {
    entity.fields[name] = this;
  }

  final Entity entity;
  final T? _defaultValue;
  final String name;
  final String _label;
  String get label => _label.tr;

  T Function()? _defaultListBuilder;

  Rx<EntityField<T>>? get rx => _rx ??= Rx<EntityField<T>>(this);
  Rx<EntityField<T>>? _rx;

  ValueTransform<T>? _fieldOnLoading;
  ValueChanged<T?>? _fieldOnLoaded;
  ValueChanged<T?>? _fieldOnChanged;

  Computed<T>? _compute;
  Set<EntityField>? _computeBindings;
  bool get isComputed => _compute != null;

  @protected
  T? defaultBuilder() =>
      _defaultListBuilder != null ? _defaultListBuilder!() : _defaultValue;

  T? get value {
    defaultValue() {
      if (entity.hasField(name)) return null;
      final val = entity.data[name] =
          _compute == null ? defaultBuilder() : _compute!.call();
      return val;
    }

    return entity[name] ?? defaultValue();
  }

  set value(T? value) {
    assert(!isComputed, "Not allowed to set value into a computed field $name");

    entity[name] = value;
  }

  @protected
  T? call([T? value]) {
    if (value != null) this.value = value;
    return this.value;
  }

  void onLoaded({required ValueChanged<T?> action}) => _fieldOnLoaded = action;

  void onChanged({required ValueChanged<T?> action}) =>
      _fieldOnChanged = action;

  void computed({
    required List<EntityField> bindings,
    required Computed<T> compute,
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
      entity[name] = defaultBuilder();
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
