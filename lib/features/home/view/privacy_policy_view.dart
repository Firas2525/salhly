import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import '../controller/privacy_controller.dart';

class PrivacyPolicyView extends StatefulWidget {
  const PrivacyPolicyView({super.key});

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> {
  final PrivacyController controller = Get.put(PrivacyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blue, Colors.blue.withOpacity(0.6)],
            ),
          ),
        ),
        title: const Text(
          'سياسة الخصوصية',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: GetBuilder<PrivacyController>(
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.four),
            );
          }

          final content = ctrl.privacyPolicyModel?.description ?? '';

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.four,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'سياسة الخصوصية',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (content.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.four,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    content,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Center(
                  child: Text(
                    'لا توجد بيانات لعرضها',
                    style: GoogleFonts.cairo(color: Colors.black54),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
