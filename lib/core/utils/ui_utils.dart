import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:salhly/app.dart';
import 'package:salhly/configs/app_colors.dart';

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
    backgroundColor: isError ? Colors.redAccent : Colors.blue,
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
      color: Colors.blue,
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
          backgroundColor: Colors.blue,
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

void showComplaintBottomSheet({int? requestId, String? contextTitle}) {
  final complaintController = TextEditingController();
  bool isSending = false;

  Get.dialog(
    StatefulBuilder(
      builder: (context, setDialogState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.feedback_rounded,
                                color: Color(0xFFDC2626),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تقديم شكوى أو ملاحظة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (contextTitle != null || requestId != null)
                                    Text(
                                      contextTitle ?? 'طلب صيانة رقم #$requestId',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Message Input
                  Text(
                    'تفاصيل الشكوى أو الملاحظة:',
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: complaintController,
                    maxLines: 4,
                    minLines: 3,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'يرجى كتابة تفاصيل الشكوى أو الملاحظة بوضوح لنتمكن من معالجتها...',
                      hintStyle: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: const Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFDC2626),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Actions row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSending ? null : () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'إلغاء',
                            style: GoogleFonts.cairo(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: isSending
                              ? null
                              : () async {
                                  final text = complaintController.text.trim();
                                  if (text.isEmpty) {
                                    showAppSnackbar(
                                      'تنبيه',
                                      'يرجى كتابة نص الشكوى أو الملاحظة قبل الإرسال',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  setDialogState(() => isSending = true);

                                  try {
                                    final fullMessage = requestId != null
                                        ? 'طلب صيانة رقم #$requestId (${contextTitle ?? ''}): $text'
                                        : (contextTitle != null
                                            ? '[$contextTitle]: $text'
                                            : text);

                                    final uri = Uri.parse(
                                      'https://www.salhly.lareenmedco.com/api/complaints/store',
                                    ).replace(
                                      queryParameters: {'message': fullMessage},
                                    );

                                    String? token = App.prefs.getString('token');
                                    final response = await http.post(
                                      uri,
                                      headers: {
                                        'Accept': 'application/json',
                                        'Accept-Language': 'en',
                                        if (token != null)
                                          'Authorization': 'Bearer $token',
                                      },
                                      body: {
                                        'message': fullMessage,
                                      },
                                    );

                                    if (response.statusCode == 200 ||
                                        response.statusCode == 201) {
                                      Get.back();
                                      showAppSnackbar(
                                        'تم الإرسال',
                                        'تم إرسال شكواك بنجاح، سيقوم فريقنا بمراجعتها والتواصل معك بأقرب وقت.',
                                      );
                                    } else {
                                      dynamic resData;
                                      try {
                                        resData = jsonDecode(response.body);
                                      } catch (_) {}
                                      showAppSnackbar(
                                        'خطأ',
                                        resData?['message'] ??
                                            'فشل في إرسال الشكوى، يرجى المحاولة لاحقاً',
                                        isError: true,
                                      );
                                    }
                                  } catch (e) {
                                    showAppSnackbar(
                                      'خطأ',
                                      'حدث خطأ أثناء الاتصال بالخادم',
                                      isError: true,
                                    );
                                  } finally {
                                    setDialogState(() => isSending = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSending
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.send_rounded, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'إرسال الشكوى',
                                      style: GoogleFonts.cairo(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
    barrierDismissible: true,
  );
}
