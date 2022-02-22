part of 'entity.dart';

/// Example:
/// late final EntityField<String> someField = this.field("someFieldName");
class Field<T> extends FieldBase<T> {
  Field._(
    Entity entity, {
    required String name,
    String? label,
    T? defaultValue,
  })  : assert(T is! List),
        assert(T is! Entity || defaultValue == null),
        super(entity, name: name, label: label) {
    final _value = defaultValue ?? T.getDefault();
    if (_value != null) _createDefault = () => _value;
  }

  T Function()? _createDefault;

  @override
  T? innerDefaultValue() =>
      _compute == null ? _createDefault?.call() : _compute!.call();

  @override
  T? get value {
    _getDefault() {
      if (this.isLoaded) return null;
      final _value = innerDefaultValue();
      entity.data[name] = _value;
      return _value;
    }

    return entity[name] ?? _getDefault();
  }

  set value(T? value) {
    assert(!isComputed, "Not allowed to set value into a computed field $name");
    if (value is Entity?) {
      value?._parentRef = this;
    }
    entity[name] = value;
  }

  /// Parameter with Null value will be ignored
  /// In order to assign null value, use [value] instead.
  T call([T? value]) {
    if (value != null) this.value = value;
    final _value = this.value;
    assert(
        _value != null, '${this.entity.runtimeType}.$name() has a null value!');
    return this.value!;
  }

  Rx<Field<T>> get rx => _rx ??= Rx<Field<T>>(this);
  Rx<Field<T>>? _rx;

  @override
  void updateState() {
    super.updateState();
    _rx?.refresh();
  }

  void computed({
    required List<FieldBase> bindings,
    required Computed<T?> compute,
  }) {
    bindings.forEach((bindingField) {
      var list = bindingField._computeBindings ??= Set();
      list.add(this);
    });
    _compute = compute;
  }

  bool get valueIsNull => this.value == null;
  bool get valueIsNotNull => this.value != null;
}

// Specific for standard EntityField
extension FieldExtensions<T> on Field<T> {
  void onLoading({required ValueTransform<T> transform}) =>
      this._fieldOnLoading = (value) => transform(value);
}

// Specific for EntityField of Entity
extension FieldOfEntityExtensions<E extends Entity> on Field<E> {
  Field<E> register(
    EntityBuilder<E> createEntity, {
    bool auto = false,
  }) {
    if (auto) _createDefault = () => createEntity().._parentRef = this;
    this._fieldOnLoading = (rawData) {
      final instance = this.value ?? createEntity()
        .._parentRef = this;
      return instance..load(rawData);
    };
    return this;
  }

  void load(Map<String, dynamic> rawData) {
    assert(!isComputed, "Not allowed to load data into a computed field $name");
    this.innerLoad(rawData);
  }

  void nil() {
    this.entity[name] = null;
  }
}
