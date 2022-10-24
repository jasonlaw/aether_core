import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app.dart';

Future<void> safeLaunchUrl(String url,
    {LaunchMode mode = LaunchMode.platformDefault,
    bool showError = false,
    String? defaultErrorText}) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    if (showError) {
      App.error('Invalid url format.');
    }
    return;
  }
  await safeLaunchUri(uri,
      mode: mode, showError: showError, defaultErrorText: defaultErrorText);
}

Future<void> safeLaunchUri(Uri uri,
    {LaunchMode mode = LaunchMode.platformDefault,
    bool showError = false,
    String? defaultErrorText}) async {
  try {
    await launchUrl(uri, mode: mode);
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


// Future<void> launchEmail(String recipients,
//     {String bcc = '',
//     String subject = '',
//     String body = '',
//     bool showError = false}) async {
//   String? encodeQueryParameters(Map<String, String> params) {
//     return params.entries
//         .map((e) =>
//             '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
//         .join('&');
//   }

//   final emailLaunchUri = Uri(
//     scheme: 'mailto',
//     path: recipients,
//     query: encodeQueryParameters(
//         <String, String>{'bcc': bcc, 'subject': subject, 'body': body}),
//   );

//   return safeLaunchUri(
//       emailLaunchUri, //'mailto:$recipients?bcc=$bcc&body=${Uri.encodeComponent(body)}&subject=${Uri.encodeComponent(subject)}',
//       showError: showError,
//       defaultErrorText: 'No email client found');
// }