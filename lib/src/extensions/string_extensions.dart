import 'package:aether_core/aether_core.dart';
import 'package:url_launcher/url_launcher.dart';

extension AetherNullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}

extension AetherStringExtensions on String {
  /// Parses the specified URL string and delegates handling of it to the
  /// underlying platform.
  ///
  /// Returned false on invalid URLs and schemes which cannot be handled,
  /// that is when [canLaunch] would complete with false.
  Future<bool> launchUrl() async =>
      await canLaunch(this) ? await launch(this) : false;

  /// check if the string is a date
  bool get isDate {
    try {
      DateTime.parse(this);
      return true;
    } catch (e) {
      return false;
    }
  }

  GraphQLQuery gql(
    List<dynamic> fields, {
    Map<String, dynamic>? params,
    Map<String, String>? paramTypes,
  }) {
    return GraphQLQuery(this, fields, params: params, paramTypes: paramTypes);
  }

  RestQuery api({
    dynamic body,
    Map<String, dynamic>? query,
  }) {
    return RestQuery(this, body: body, query: query);
  }
}
