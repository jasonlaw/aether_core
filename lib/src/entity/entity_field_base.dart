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

  ValueTransform<T>? _fieldOnLoading;
  ValueChanged<T?>? _fieldOnLoaded;
  ValueChanged<T?>? _fieldOnChanged;
  void Function()? _fieldOnReset;

  Computed<T?>? _compute;
  Set<FieldBase>? _computeBindings;
  bool get isComputed => _compute != null;
  bool get isLoaded => entity.containsKey(name);

  T? get value;

  void onLoaded({required ValueChanged<T?> action, void Function()? reset}) {
    _fieldOnLoaded = action;
    _fieldOnReset = reset;
  }

  void onChanged({required ValueChanged<T?> action}) =>
      _fieldOnChanged = action;

  void propagate() {
    if (isComputed) {
      try {
        entity[name] = _compute!();
      } on Exception catch (_) {
        printError(info: 'ComputedError on $runtimeType.$name');
        rethrow;
      }
    }
  }

  @protected
  T? innerDefaultValue() => null;

  @protected
  void innerLoad(dynamic rawData, {bool copy = false}) {
    if (isComputed) return;
    if (rawData == null) {
      if (copy) {
        entity[name] = null;
      } else {
        //final defaultValue = this.value;
        //entity.data.remove(name);
        entity[name] = innerDefaultValue();
      }
    } else {
      final transformer = _fieldOnLoading ?? ValueTransformers.system();
      entity[name] = transformer(rawData);
    }
    if (!copy) _fieldOnLoaded?.call(value);
  }

  @override
  String toString() => '$value';

  // /// This equality override works for EntityField instances and the internal values.
  // bool operator ==(o) {
  //   // Todo, find a common implementation for the hashCode of different Types.
  //   if (o is T) return this.value == o;
  //   if (o is FieldBase<T>) return this.value == o.value;
  //   return false;
  // }

  // @override
  // int get hashCode => this.hashCode;

  @mustCallSuper
  void reset() {
    if (isComputed) return;
    if (entity.containsKey(name)) {
      entity.data.remove(name);
      updateState();
    }
    _fieldOnReset?.call();
  }

  @mustCallSuper
  void updateState() {
    _fieldOnChanged?.call(value);
    entity.updateState();
    _computeBindings?.forEach((computedField) {
      computedField.propagate();
    });
  }
}
