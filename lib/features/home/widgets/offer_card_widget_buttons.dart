import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/phone_utils.dart';

class OfferCardWidgetButtons extends StatelessWidget {
  const OfferCardWidgetButtons({
    super.key,
    required this.phone,
    required this.whatsapp,
  });

  final String phone;
  final String whatsapp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              if (phone.isNotEmpty) {
                await dialPhoneNumber(phone);
              }
            },
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.phone, size: 14, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: InkWell(
            onTap: () async {
              String normalize(String raw) {
                var value = raw.replaceAll(RegExp(r'[\s\-\(\)+]'), '');
                if (value.startsWith('00')) value = value.substring(2);
                if (value.startsWith('0')) value = value.substring(1);
                if (!value.startsWith('963')) {
                  value = '963$value';
                }
                return value;
              }

              final normalized = normalize(whatsapp);
              final whatsappUri = Uri.parse(
                'whatsapp://send?phone=$normalized',
              );
              final waMeUri = Uri.parse('https://wa.me/$normalized');
              try {
                if (await canLaunchUrl(whatsappUri)) {
                  await launchUrl(
                    whatsappUri,
                    mode: LaunchMode.externalApplication,
                  );
                  return;
                }
                if (await canLaunchUrl(waMeUri)) {
                  await launchUrl(
                    waMeUri,
                    mode: LaunchMode.externalApplication,
                  );
                }
              } catch (error) {
                print('Error launching WhatsApp: $error');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              height: 35,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset('assets/images/whatsapp.png', width: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
