import 'package:aether_core/src/entity/entity.dart';
import 'package:cross_file/cross_file.dart';

class MediaFile extends Entity {
  late final Field<String> id = this.field("id");
  late final Field<String> name = this.field("name");
  final XFile? file;

  MediaFile([this.file]);

  bool get isNew => id.valueIsNullOrEmpty;
  bool get canUpload => isNew && file != null;
}
