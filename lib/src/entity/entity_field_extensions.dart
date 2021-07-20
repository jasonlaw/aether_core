part of 'entity.dart';

extension AetherRxEntityFieldExtensions<E> on Rx<EntityField<E>> {
  E? get fieldValue => this.value.value;
}

extension AetherEntityFieldExtensions<E> on EntityField<E> {
  void onLoading({required ValueTransform<E> transform}) =>
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

  bool get isEmpty => this.value == null;

  void nil() {
    this.entity[this.name] = null;
  }

  void load(Map<String, dynamic> rawData) {
    assert(!isComputed, "Not allowed to load data into a computed field $name");
    this._load(rawData);
  }

  // GraphQLEntity<T> gql(
  //   List<dynamic> query(T entity), {
  //   Map<String, dynamic> variables,
  //   Map<String, String> variablesType,
  // }) {
  //   final entity = this.value ?? this._createEntity();
  //   return GraphQLEntity<T>._(
  //       this.name, entity, query(entity), variables, variablesType);
  // }
}

extension AetherEntityFieldListExtensions<E extends Entity>
    on EntityField<List<E>> {
  void onLoading(
    EntityBuilder<E> createEntity,
  ) {
    this._fieldOnLoading = (rawData) {
      final list = <E>[];
      rawData.forEach((data) {
        final E entity = createEntity();
        entity.load(data);
        entity._fieldOwner = this;
        list.add(entity);
      });
      return list;
    };
    this._defaultListBuilder = () => <E>[];
  }

  void load(List rawData) {
    assert(!isComputed, "Not allowed to load data into a computed field $name");
    this._load(rawData);
  }

  // GraphQLEntity<T> gql(
  //   List<dynamic> query(T entity), {
  //   Map<String, dynamic> variables,
  //   Map<String, String> variablesType,
  // }) {
  //   final entity = this._createEntity();
  //   return GraphQLEntity<T>._(
  //       this.name, entity, query(entity), variables, variablesType);
  // }

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
    entity._fieldOwner = this;
    this.updateState();
  }

  void addAll(Iterable<E> entities) {
    entities.forEach((entity) => entity._fieldOwner = this);
    this.value!.addAll(entities);
    this.updateState();
  }

  void assignAll(Iterable<E> entities) {
    this.value!.clear();
    this.addAll(entities);
  }

  void insert(int index, E entity) {
    this.value!.insert(index, entity);
    entity._fieldOwner = this;
    this.updateState();
  }

  void remove(E entity) {
    if (this.value!.remove(entity)) {
      entity._fieldOwner = null;
      this.updateState();
    }
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
