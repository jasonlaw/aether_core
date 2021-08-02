part of 'entity.dart';

typedef ValueTransform<T> = T Function(dynamic value);
typedef ValueChanging<T> = T Function(T value);
typedef Computed<T> = T Function();

abstract class FieldBase<T> {
  FieldBase(
    this.entity, {
    required this.name,
    String? label,
  }) : _label = label ?? name {
    entity.fields[name] = this;
  }

  final Entity entity;
  final String name;

  String _label;
  String get label => _label.tr;
  set label(String val) => _label = val;

  @protected
  late final T? Function()? defaultBuilder;

  @protected
  T? getDefaultValue() => null;

  ValueTransform<T>? _fieldOnLoading;
  ValueChanged<T?>? _fieldOnLoaded;
  ValueChanged<T?>? _fieldOnChanged;

  Computed<T?>? _compute;
  Set<FieldBase>? _computeBindings;
  bool get isComputed => _compute != null;

  T? get value;

  void onLoaded({required ValueChanged<T?> action}) => _fieldOnLoaded = action;

  void onChanged({required ValueChanged<T?> action}) =>
      _fieldOnChanged = action;

  void propagate() {
    if (this.isComputed) {
      entity[name] = _compute!();
    }
  }

  @protected
  void innerLoad(dynamic rawData, {bool copy = false}) {
    if (isComputed) return;
    if (rawData == null) {
      if (copy && T is! List<Entity>) entity[name] = null;
    } else {
      final transformer = _fieldOnLoading ?? ValueTransformers.system();
      entity[name] = transformer(rawData);
    }
    if (!copy) _fieldOnLoaded?.call(value);
  }

  @override
  String toString() => "$value";

  // /// This equality override works for EntityField instances and the internal values.
  // bool operator ==(o) {
  //   // Todo, find a common implementation for the hashCode of different Types.
  //   if (o is T) return this.value == o;
  //   if (o is EntityField<T>) return this.value == o.value;
  //   return false;
  // }

  // @override
  // int get hashCode => this.value.hashCode;
  @mustCallSuper
  void reset() {
    if (isComputed) return;
    entity.data.remove(name);
    updateState();
  }

  @mustCallSuper
  void updateState() {
    _fieldOnChanged?.call(value);
    //_rx?.refresh();
    entity.updateState();
    _computeBindings?.forEach((computedField) {
      computedField.propagate();
    });
  }
}