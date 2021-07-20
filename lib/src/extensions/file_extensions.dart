import 'dart:io';
import 'package:mime_type/mime_type.dart';

extension AetherFileExtensions on File {
  String get name => this.path.split("/").last;
  String get mimeType => mime(this.name) ?? "application/octet-stream";
}
