import 'dart:io';
import 'package:aether_core/aether_core.dart';

class UploadFile extends Entity {
  late final EntityField<String> id = this.field("id");
  late final EntityField<String> name = this.field("name");
  final File? file;

  UploadFile([this.file]);

  bool get isNew => id.value.isNullOrEmpty;
}
