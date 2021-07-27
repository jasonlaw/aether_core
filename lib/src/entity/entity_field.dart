part of 'entity.dart';

/// Example:
/// late final EntityField<String> someField = this.field("someFieldName");
class EntityField<T> extends EntityFieldBase<T> {
  EntityField._(
    Entity entity, {
    required String name,
    String? label,
    T? defaultValue,
  })  : assert(T is! List),
        assert(T is! Entity || defaultValue == null),
        super(entity, name: name, label: label) {
    final defVal = defaultValue ?? T.defaultValue();
    if (defVal != null) this.defaultBuilder = () => defaultValue;
  }

  set value(T? value) {
    assert(!isComputed, "Not allowed to set value into a computed field $name");
    entity[name] = value;
  }

  /// Parameter with Null value will be ignored
  /// In order to assign null value, use [value] instead.
  T call([T? value]) {
    if (value != null) this.value = value;
    return this.value!;
  }

  Rx<EntityField<T>> get rx => _rx ??= Rx<EntityField<T>>(this);
  Rx<EntityField<T>>? _rx;

  @override
  void updateState() {
    super.updateState();
    _rx?.refresh();
  }

  bool get valueIsNull => this.value == null;
  bool get valueIsNotNull => this.value != null;
}

// Specific for standard EntityField
extension EntityFieldExtensions<T> on EntityField<T> {
  void onLoading({required ValueTransform<T> transform}) =>
      this._fieldOnLoading = (value) => transform(value);
}

// Specific for EntityField of Entity
extension EntityFieldOfEntityExtensions<E extends Entity> on EntityField<E> {
  void onLoading(
    EntityBuilder<E> createEntity,
  ) {
    this._fieldOnLoading = (value) => createEntity()..load(value);
  }

  void load(Map<String, dynamic> rawData) {
    assert(!isComputed, "Not allowed to load data into a computed field $name");
    this._load(rawData);
  }

  void nil() {
    this.entity[name] = null;
  }
}
