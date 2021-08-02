import 'package:aether_core/src/app/app.dart';
import 'package:url_launcher/url_launcher.dart';
export 'package:url_launcher/url_launcher.dart';

Future<void> launchUrl(String url,
    {bool showError: false, String? defaultErrorText}) async {
  try {
    if (await canLaunch(url)) {
      await launch(url);
    } else if (showError && defaultErrorText != null) {
      App.snackbar.showError(defaultErrorText);
    }
  } catch (error) {
    if (showError) {
      App.snackbar.showError(error);
    }
  }
}

Future<void> launchPhoneCall(String phoneNumber,
    {bool showError: false}) async {
  return launchUrl('tel:$phoneNumber', showError: showError);
}

Future<void> launchEmail(String recipients,
    {String bcc = "",
    String subject = "",
    String body = "",
    bool showError: false}) async {
  return launchUrl(
      'mailto:$recipients?bcc=$bcc&body=${Uri.encodeComponent(body)}&subject=${Uri.encodeComponent(subject)}',
      showError: showError,
      defaultErrorText: "No email client found");
}
