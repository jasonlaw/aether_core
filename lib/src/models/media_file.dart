import 'dart:io';
import 'package:aether_core/aether_core.dart';

class MediaFile extends Entity {
  late final Field<String> id = this.field("id");
  late final Field<String> name = this.field("name");
  final File? file;

  MediaFile([this.file]);

  bool get isNew => id.value.isNullOrEmpty;
}
