import 'dart:io';
import 'package:aether_core/aether_core.dart';

class UploadFileEntity extends Entity {
  late final EntityField<String> id = this.field("id");
  late final EntityField<String> name = this.field("name");
  final File? file;

  UploadFileEntity([this.file]);

  factory UploadFileEntity.fromFile(File file) {
    return UploadFileEntity(file);
  }

  bool get isNew => id.value.isNullOrEmpty;
}
