import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app.dart';

Future<void> safeLaunchUrl(String url,
    {bool showError = false, String? defaultErrorText}) async {
  try {
    await launchUrl(Uri.parse(url));
  } on Exception catch (error) {
    if (showError) {
      if (kDebugMode) {
        App.error(error);
      } else {
        App.error(defaultErrorText ?? error);
      }
    }
  }
}

Future<void> launchPhoneCall(String phoneNumber,
    {bool showError = false}) async {
  return safeLaunchUrl('tel:$phoneNumber', showError: showError);
}

Future<void> launchEmail(String recipients,
    {String bcc = '',
    String subject = '',
    String body = '',
    bool showError = false}) async {
  return safeLaunchUrl(
      'mailto:$recipients?bcc=$bcc&body=${Uri.encodeComponent(body)}&subject=${Uri.encodeComponent(subject)}',
      showError: showError,
      defaultErrorText: 'No email client found');
}
