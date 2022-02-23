import 'package:cross_file/cross_file.dart';

import '../../entity/entity.dart';

class MediaFile extends Entity {
  late final Field<String> id = field('id');
  late final Field<String> name = field('name');
  late final Field<String> url = field('url');
  final XFile? file;

  MediaFile([this.file]);

  bool get isNew => id.valueIsNullOrEmpty;
  bool get canUpload => isNew && file != null;
}
