import 'package:url_launcher/url_launcher.dart';

String _normalizePhoneNumber(String phone) {
  var cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (cleaned.startsWith('00')) {
    cleaned = '+${cleaned.substring(2)}';
  }
  return cleaned;
}

Future<void> dialPhoneNumber(String phone) async {
  if (phone.isEmpty) return;

  final cleanPhone = _normalizePhoneNumber(phone);
  if (cleanPhone.isEmpty) return;

  final uri = Uri(scheme: 'tel', path: cleanPhone);

  try {
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return;
    }

    if (await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      return;
    }

    final fallbackUri = Uri.parse('tel:$cleanPhone');
    await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // ignore errors and let callers handle failures if needed
  }
}
