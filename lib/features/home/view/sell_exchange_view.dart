import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../exchange_pieces/exchange_piece_view.dart';
import 'sell_piece_view.dart';

class SellExchangeView extends StatelessWidget {
  const SellExchangeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF4682A9),
        foregroundColor: Colors.white,
        title: Text(
          'بيع واستبدال',
          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 18),
            Text(
              'ماذا تريد أن تفعل؟',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: const Color(0xFF263238),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اختر الخدمة المناسبة لإرسال طلبك بسهولة',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: const Color(0xFF78909C),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),
            _ActionCard(
              icon: Icons.sell_outlined,
              title: 'بيع قطعة',
              subtitle: 'اعرض قطعتك للبيع',
              color: const Color(0xFF4682A9),
              onTap: () => Get.to(() => const SellPieceView()),
            ),
            const SizedBox(height: 16),
            _ActionCard(
              icon: Icons.sync_alt_rounded,
              title: 'استبدال قطعة',
              subtitle: 'بدّل قطعتك بقطعة أخرى',
              color: const Color(0xFF2A9D8F),
              onTap: () => Get.to(() => const ExchangePieceView()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.14)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 27),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF263238),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF78909C),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_back_ios_new_rounded, color: color, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}
