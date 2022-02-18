import 'package:aether_core/aether_core.dart';

class MediaFile extends Entity {
  late final Field<String> id = this.field("id");
  late final Field<String> name = this.field("name");
  final XFile? file;

  MediaFile([this.file]);

  bool get isNew => id.value.isNullOrEmpty;
  bool get canUpload => isNew && file != null;
}
