part of 'entity.dart';

extension AetherEntityFieldExtensions<T> on EntityField<T> {
  void onLoading({required ValueTransform<T> transform}) =>
      this._fieldOnLoading = (value) => transform(value);
}

// Entity
extension AetherEntityFieldEntityExtensions<E extends Entity>
    on EntityField<E> {
  void onLoading(
    EntityBuilder<E> createEntity,
  ) {
    this._fieldOnLoading = (value) => createEntity()..load(value);
    //this._fieldEntityBuilder = createEntity;
  }

  void load(Map<String, dynamic> rawData) {
    assert(!isComputed, "Not allowed to load data into a computed field $name");
    this._load(rawData);
  }

  void nil() {
    this.entity[name] = null;
  }
}

extension AetherRxEntityFieldExtensions<E> on Rx<EntityField<E>> {
  E? get fieldValue => this.value.value;
}
