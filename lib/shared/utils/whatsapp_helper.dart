import 'package:url_launcher/url_launcher.dart';

Future<bool> launchWhatsAppMessage(String phone, String message) async {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return false;
  final uri = Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent(message)}');
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
