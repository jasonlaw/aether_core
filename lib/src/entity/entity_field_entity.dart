// part of 'entity.dart';

// /// Example:
// /// late final EntityField<String> someField = this.field("someFieldName");
// class EntityFieldEntity<E extends Entity> extends FieldBase<E> {
//   EntityFieldEntity._(
//     Entity entity, {
//     required String name,
//     String? label,
//   }) : super(entity, name: name, label: label);

//   late final EntityBuilder<E> _createEntity;

//   @override
//   E get value {
//     _getDefault() {
//       return entity.data[name] = _createEntity();
//     }

//     return entity[name] ?? _getDefault();
//   }

//   void register(
//     EntityBuilder<E> createEntity,
//   ) {
//     _createEntity = createEntity;
//     this._fieldOnLoading = (rawData) => this.value..load(rawData);
//   }

//   /// Parameter with Null value will be ignored
//   E call() => this.value;

//   Rx<EntityFieldEntity<E>> get rx => _rx ??= Rx<EntityFieldEntity<E>>(this);
//   Rx<EntityFieldEntity<E>>? _rx;

//   @override
//   void updateState() {
//     super.updateState();
//     _rx?.refresh();
//   }
// }
