import 'package:flutter/material.dart';
import 'dart:io';

import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../core/utils/ui_utils.dart';

class UpdateRequiredScreen extends StatelessWidget {
  final String? androidLink;
  final String? iosLink;

  const UpdateRequiredScreen({super.key, this.androidLink, this.iosLink});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.four.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Image.asset(
                      'assets/images/logo2.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.update,
                        size: 60,
                        color: AppColors.four,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    'تحديث مطلوب',
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Description
                  Text(
                    'يتطلب التطبيق نسخة أحدث للعمل بشكل صحيح.\n\nيرجى تحديث التطبيق من متجر التطبيقات.',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.four.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.four.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 32,
                          color: AppColors.four,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'لا يمكنك متابعة استخدام التطبيق بدون التحديث',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: AppColors.four,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 28),

                  // Prominent Update Button (keeps existing behavior)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        String? url;
                        if (Platform.isAndroid) {
                          url = androidLink ?? iosLink;
                        } else if (Platform.isIOS) {
                          url = iosLink ?? androidLink;
                        } else {
                          url = androidLink ?? iosLink;
                        }

                        if (url == null || url.isEmpty) {
                          showAppSnackbar('خطأ', 'رابط التحديث غير متوفر', isError: true);
                          return;
                        }

                        try {
                          await launchUrlString(url, mode: LaunchMode.externalApplication);
                        } catch (e) {
                          showAppSnackbar('خطأ', 'تعذر فتح الرابط');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.four,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                      ),
                      icon: const Icon(Icons.update, color: Colors.white),
                      label: Text('تحديث الآن', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Short supportive message
                  Text(
                    'ستتم إعادة توجيهك إلى متجر التطبيقات لإكمال التحديث.',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Instruction step builder removed — page simplified to a single update action.
}
