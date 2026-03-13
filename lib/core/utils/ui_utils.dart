import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

void showAppSnackbar(String title, String message, {bool isError = false}) {
  Get.rawSnackbar(
    titleText: Text(
      title,
      style: GoogleFonts.cairo(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    messageText: Text(message, style: GoogleFonts.cairo(color: Colors.white)),
    snackStyle: SnackStyle.FLOATING,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: isError ? Colors.redAccent : AppColors.four,
    borderRadius: 8,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    animationDuration: const Duration(milliseconds: 300),
    duration: const Duration(seconds: 3),
  );
}

void showConfirmDialog({
  required String title,
  required String middleText,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  String confirmText = 'نعم',
  String cancelText = 'لا',
}) {
  Get.defaultDialog(
    title: title,
    titleStyle: GoogleFonts.cairo(
      color: AppColors.four,
      fontWeight: FontWeight.bold,
    ),
    middleText: middleText,
    middleTextStyle: GoogleFonts.cairo(color: Colors.black87),
    backgroundColor: Colors.white,
    radius: 12,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    actions: [
      TextButton(
        onPressed: () {
          Get.back();
          if (onCancel != null) onCancel();
        },
        child: Text(
          cancelText,
          style: GoogleFonts.cairo(color: Colors.black87, fontSize: 15),
        ),
      ),
      ElevatedButton(
        onPressed: () {
          Get.back();
          onConfirm();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.four,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text(
            confirmText,
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 15),
          ),
        ),
      ),
    ],
  );
}
