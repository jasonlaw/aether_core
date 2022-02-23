import 'package:flutter/material.dart';

import '../app/app.dart';
import '../extensions/extensions.dart';

part 'entity_field.dart';
part 'entity_field_base.dart';
part 'entity_field_list.dart';
part 'entity_graphql.dart';
part 'entity_utils.dart';
part 'extensions.dart';

typedef EntityBuilder<E extends Entity> = E Function();

// RECOMMENDED:
// Equality checking => https://pub.dev/packages/equatable
class Entity {
  @protected
  final Map<String, dynamic> data = {};

  Map<String, dynamic>? _committedData;

  // @Deprecated('Use field instead')
  Rx<Entity> get rx => _rx ??= Rx<Entity>(this);
  Rx<Entity>? _rx;

  final Map<String, FieldBase> fields = {};

  /// Flag for empty content.
  bool get isEmpty => data.isEmpty;

  /// Flag for non-empty content.
  bool get isNotEmpty => data.isNotEmpty;

  bool containsKey(String fieldName) => data.containsKey(fieldName);
  //Iterable<String> get fieldNames => data.keys;

  dynamic operator [](String fieldName) => data[fieldName];

  /// This entity is onwed by a list field
  FieldBase? _parentRef;
  FieldBase? get parent => _parentRef;

  void Function()? _onLoaded;
  void onLoaded(void Function() action) => _onLoaded = action;

  static void removeFromParentList(Entity entity) {
    if (entity.parent == null) return;
    var list = entity.parent as ListField?;
    list?.remove(entity);
  }

  void operator []=(String fieldName, dynamic value) {
    final oldValue = data[fieldName];

    // value has changed or first time
    final valueChanged = oldValue != value;
    final firstAssignment = !data.containsKey(fieldName);
    if (valueChanged || (firstAssignment && value != null)) {
      if (value == null) {
        data.remove(fieldName);
      } else {
        data[fieldName] = value;
      }
      fields[fieldName]?.updateState();
    }
  }

  Field<T> field<T>(String name, {String? label, T? defaultValue}) {
    var instance = fields[name] as Field<T>?;
    if (instance == null) {
      instance = Field<T>._(this,
          name: name, label: label, defaultValue: defaultValue);
    }
    return instance;
  }

  ListField<E> fieldList<E extends Entity>(String name, {String? label}) {
    var instance = fields[name] as ListField<E>?;
    if (instance == null) {
      instance = ListField<E>._(this, name: name, label: label);
    }
    return instance;
  }

  /// Load entity data.
  /// Normally this is called to set the data from repository.
  bool _isLoading = false;
  void load(Map<String, dynamic> rawData, {bool ignoreNullField = false}) {
    _isLoading = true;
    rawData.forEach((fieldName, value) {
      if (value == null && (ignoreNullField || !data.containsKey(fieldName))) {
        // value is null, do nothing if empty field or specified to ignore
      } else {
        // if (value != null) {
        // don't remove, to allow trigger field updateState
        data.remove(fieldName);
        var field = fields[fieldName];
        // NOTES: Be careful, sometime the late final Field has not been called, hence
        // the Field is not instantiated, which could have missed the default value
        // assignment.
        if (field != null) {
          field.innerLoad(value);
        } else {
          final transformer = ValueTransformers.system();
          this[fieldName] = transformer(value);
        }
      }
    });
    _isLoading = false;
    commit();
    updateState();
    _onLoaded?.call();
  }

  bool _isCopying = false;
  void copy(Entity source) {
    assert(runtimeType == source.runtimeType, "Type mismatched");
    commit();
    _isCopying = true;
    try {
      data.clear();
      source.toMap().forEach((key, value) {
        final field = fields[key];
        if (field != null) {
          field.innerLoad(value, copy: true);
        } else {
          this[key] = value;
        }
      });
    } on Exception catch (_) {
      rollback();
      rethrow;
    } finally {
      _isCopying = false;
    }
    commit();
    updateState();
  }

  void updateState() {
    if (_isUpdatingValues || _isCopying || _isLoading || _isReseting) {
      return;
    }
    _rx?.refresh();
    _parentRef?.updateState();
    //_rxRefresh();
  }

  bool _isUpdatingValues = false;
  void updateValues(Map<String, dynamic> values) {
    _isUpdatingValues = true;
    try {
      values.forEach((fieldName, value) {
        if (value != null) {
          this[fieldName] = value;
        }
      });
    } on Exception catch (_) {
      return;
    } finally {
      _isUpdatingValues = false;
    }
    updateState();
  }

  void commit() {
    _committedData = Map.unmodifiable(data);
  }

  /// Rollback to the last commit
  void rollback() {
    if (_committedData == null) return;
    data.clear();
    data.addAll(_committedData!);
    _committedData = null;
  }

  bool _isReseting = false;
  @mustCallSuper
  void reset() {
    _isReseting = true;
    for (final field in fields.values) {
      field.reset();
    }
    data.clear();
    _committedData = null;
    //_updated.clear();
    _isReseting = false;
    updateState();
  }

  Map<String, dynamic> toMap() {
    return data.map<String, dynamic>((key, value) {
      if (value is Entity) return MapEntry(key, value.toMap());
      if (value is List<Entity>) {
        final list = <Map<String, dynamic>>[];
        for (final entity in value) {
          list.add(entity.toMap());
        }
        return MapEntry(key, list);
      }
      return MapEntry(key, value);
    });
  }

  @override
  String toString() => toMap().toString();

  T of<T extends Entity>() => this as T;
}
