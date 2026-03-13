import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salhly/features/service/controller/request_service_controller.dart';
import 'package:salhly/configs/app_colors.dart';

import '../controller/service_controller.dart';

class ServiceOrderPage extends StatefulWidget {
  final int serviceId;
  final int? subServiceId;

  const ServiceOrderPage({Key? key, required this.serviceId, this.subServiceId}) : super(key: key);

  @override
  State<ServiceOrderPage> createState() => _ServiceOrderPageState();
}

class _ServiceOrderPageState extends State<ServiceOrderPage> {
  late RequestServiceController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RequestServiceController());
    controller.serviceId = widget.serviceId;
    if (widget.subServiceId != null) controller.selectedSubServiceId = widget.subServiceId;
    // fetch subservices for display if needed
    //controller.getService(widget.serviceId);
  }

  @override
  void dispose() {
    // controller will be disposed by Get when appropriate
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = AppColors.four;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text('طلب خدمة', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: mainColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GetBuilder<RequestServiceController>(
        builder: (_) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header card with subtle gradient
                    Container( 
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [mainColor.withOpacity(0.97), mainColor.withOpacity(0.80)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: mainColor.withOpacity(0.13), blurRadius: 10, offset: const Offset(0, 6))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                            child: const Icon(Icons.handshake, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('اطلب خدمتك بسهولة', style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text('املأ البيانات وأرفق صورة أو تسجيل صوتي عند الحاجة', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Personal info card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('البيانات الأساسية', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            TextField(
                              controller: controller.fullNameController,
                              decoration: InputDecoration(
                                labelText: 'الاسم الكامل',
                                prefixIcon: Icon(Icons.person, color: AppColors.four),
                                filled: true,
                                fillColor: AppColors.four.withOpacity(0.04),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.four)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: controller.phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'رقم الهاتف',
                                prefixIcon: Icon(Icons.phone, color: AppColors.four),
                                filled: true,
                                fillColor: AppColors.four.withOpacity(0.04),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.four)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: controller.addressController,
                              decoration: InputDecoration(
                                labelText: 'العنوان',
                                prefixIcon: Icon(Icons.location_on, color: AppColors.four),
                                filled: true,
                                fillColor: AppColors.four.withOpacity(0.04),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.four)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Details card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('تفاصيل إضافية', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: controller.descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'اكتب وصفاً قصيراً لما تحتاجه...',
                                prefixIcon: Icon(Icons.note, color: AppColors.four),
                                filled: true,
                                fillColor: AppColors.four.withOpacity(0.04),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.four)),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Image picker row
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: controller.pickImage,
                                  icon: Icon(Icons.image, color: AppColors.four),
                                  label:  Text('إضافة صورة', style: TextStyle(color: AppColors.four)),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    side:  BorderSide(color: AppColors.four),
                                    foregroundColor: AppColors.four,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 14.0),
                                  child: Text(
                                    'اختياري',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (controller.imageFile != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(controller.imageFile!, height: 80, width: 80, fit: BoxFit.cover),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Audio recorder card (polished)
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('تسجيل صوتي (اختياري)', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),

                            // Recorder area: big circular button + timer + waveform
                            Row(
                              children: [
                                // Big circular record/stop button
                                GestureDetector(
                                  onTap: controller.isRecording ? controller.stopRecording : controller.startRecording,
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: controller.isRecording ? Colors.red : mainColor,
                                      boxShadow: [BoxShadow(color: (controller.isRecording ? Colors.red : mainColor).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                                    ),
                                    child: Center(
                                      child: Icon(controller.isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 32),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Timer and waveform
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(controller.isRecording ? 'التسجيل جارٍ — ${controller.recordingDurationStr}' : (controller.audioFilePath != null ? 'تم التسجيل — ${controller.recordingDurationStr}' : 'اضغط للتسجيل'), style: GoogleFonts.cairo()),
                                      const SizedBox(height: 8),

                                      // Simple waveform-like animated bars
                                      Row(
                                        children: List.generate(8, (i) {
                                          final baseHeight = 6.0 + (i % 3) * 6.0;
                                          final animHeight = controller.isRecording ? baseHeight + ((i + DateTime.now().second) % 6) * 3.0 : baseHeight;
                                          return AnimatedContainer(
                                            duration: const Duration(milliseconds: 400),
                                            margin: const EdgeInsets.symmetric(horizontal: 2),
                                            width: 6,
                                            height: animHeight,
                                            decoration: BoxDecoration(color: controller.isRecording ? Colors.redAccent : Colors.grey.shade400, borderRadius: BorderRadius.circular(3)),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Playback controls + slider
                            if (controller.audioFilePath != null) ...[
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: controller.isPlaying ? controller.stopAudio : controller.playAudio,
                                    icon: Icon(controller.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, size: 32, color: mainColor),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Slider(
                                          value: controller.playbackDuration.inSeconds > 0 ? controller.playbackPosition.inSeconds.clamp(0, controller.playbackDuration.inSeconds).toDouble() : 0.0,
                                          max: controller.playbackDuration.inSeconds > 0 ? controller.playbackDuration.inSeconds.toDouble() : 1.0,
                                          onChanged: (v) {
                                            controller.seekAudio(Duration(seconds: v.round()));
                                          },
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(controller.formatDuration(controller.playbackPosition), style: GoogleFonts.cairo(fontSize: 12)),
                                            Text(controller.formatDuration(controller.playbackDuration), style: GoogleFonts.cairo(fontSize: 12)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: controller.deleteAudio,
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  )
                                ],
                              ),
                            ] else
                              Center(
                                child: Text('لا يوجد تسجيل بعد', style: GoogleFonts.cairo(color: Colors.grey)),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [mainColor.withOpacity(0.97), mainColor.withOpacity(0.80)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: mainColor.withOpacity(0.13), blurRadius: 10, offset: const Offset(0, 6))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                            child: const Icon(Icons.info, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ملاحظة', style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text('عند الوصف بشكل دقيق و ارفاق صورة و صوت يمكننا تخمين تكلفة عملية الصيانة قبل الكشف عليها', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Submit button
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading ? null : controller.submitOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(controller.isLoading ? 'جارٍ الإرسال...' : 'إرسال الطلب', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              if (controller.isLoading)
                Container(
                  color: Colors.black26,
                  child:  Center(child: CircularProgressIndicator(color: AppColors.four,)),
                )
            ],
          );
        },
      ),
    );
  }
}
