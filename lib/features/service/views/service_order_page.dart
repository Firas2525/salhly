import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salhly/features/service/controller/request_service_controller.dart';
import 'package:salhly/configs/app_colors.dart';

import '../controller/service_controller.dart';

class ServiceOrderPage extends StatefulWidget {
  final int serviceId;
  final int? subServiceId;

  const ServiceOrderPage({Key? key, required this.serviceId, this.subServiceId})
    : super(key: key);

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
    if (widget.subServiceId != null)
      controller.selectedSubServiceId = widget.subServiceId;
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
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.white)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue,
                    Colors.blue.withOpacity(0.55),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          GetBuilder<RequestServiceController>(
            builder: (_) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header card with subtle gradient

                        SizedBox(height: 40),
                        Row(
                          children: [
                            GestureDetector(
                                onTap: (){
                                  Navigator.of(context).pop();
                                },
                                child: Icon(Icons.arrow_back, color: Colors.white, size: 28)),
                            const SizedBox(width: 12),
                            Text(
                              'طلب خدمة',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 35),

                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image(
                                  image: AssetImage(
                                    'assets/images/12.jpg',
                                  ),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.four.withOpacity(0.6),
                                      AppColors.four,
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  Container(
                                    margin: EdgeInsets.only(right: 15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        25,
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(
                                          0.3,
                                        ),
                                        width: 0.8,
                                      ),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.1),
                                          Colors.white.withOpacity(0.2),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        25,
                                      ),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 10,
                                          sigmaY: 10,
                                        ),
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          child: Row(
                                            mainAxisSize:
                                            MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.send_to_mobile_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                "اطلب خدمتك بسهولة",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                    ),
                                    child: Text(
                                      "املأ البيانات و أرفق صورة أو تسجيل صوتي عند الحاجة",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Personal info card
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'البيانات الأساسية',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: controller.fullNameController,
                                  decoration: InputDecoration(
                                    labelText: 'الاسم الكامل',
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: AppColors.four,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.four.withOpacity(0.04),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: AppColors.four,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: controller.phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'رقم الهاتف',
                                    prefixIcon: Icon(
                                      Icons.phone,
                                      color: AppColors.four,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.four.withOpacity(0.04),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: AppColors.four,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: controller.addressController,
                                  decoration: InputDecoration(
                                    labelText: 'العنوان',
                                    prefixIcon: Icon(
                                      Icons.location_on,
                                      color: AppColors.four,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.four.withOpacity(0.04),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: AppColors.four,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Details card
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تفاصيل إضافية',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                TextField(
                                  controller: controller.descriptionController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: 'اكتب وصفاً قصيراً لما تحتاجه...',
                                    prefixIcon: Icon(
                                      Icons.note,
                                      color: AppColors.four,
                              
                                    ),
                                    filled: true,
                                    fillColor: AppColors.four.withOpacity(0.04),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: AppColors.four,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),
                                Text(
                                  'الصور',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemCount: controller.imageFiles.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == controller.imageFiles.length) {
                                      return GestureDetector(
                                        onTap: controller.pickImage,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  AppColors.four.withOpacity(0.5),
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate,
                                                color: AppColors.four,
                                                size: 32,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'اضافة صورة',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.four,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            controller.imageFiles[index],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              controller.removeImage(index);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red
                                                    .withOpacity(0.9),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                Text(
                                  'تسجيل صوتي (اختياري)',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: controller.isRecording
                                              ? controller.stopRecording
                                              : controller.startRecording,
                                          child: Container(
                                            width: 72,
                                            height: 72,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: AppColors.four.withOpacity(0.5),
                                                width: 2,
                                              ),
                                              color: controller.isRecording
                                                  ? Colors.red.withOpacity(0.1)
                                                  : Colors.grey.shade100,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                controller.isRecording
                                                    ? Icons.stop
                                                    : Icons.mic,
                                                size: 28,
                                                color: controller.isRecording
                                                    ? Colors.red
                                                    : AppColors.four,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (!controller.isRecording && controller.audioFilePath != null) ...[
                                          const SizedBox(width: 10),
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                width: 72,
                                                height: 72,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                  color: Colors.grey.shade100,
                                                  border: Border.all(
                                                    color: AppColors.four.withOpacity(0.5),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: IconButton(
                                                    onPressed: controller.isPlaying
                                                        ? controller.stopAudio
                                                        : controller.playAudio,
                                                    icon: Icon(
                                                      controller.isPlaying
                                                          ? Icons.pause_circle_filled
                                                          : Icons.play_circle_fill,
                                                      color: AppColors.four,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: -6,
                                                right: -6,
                                                child: GestureDetector(
                                                  onTap: controller.deleteAudio,
                                                  child: Container(
                                                    width: 28,
                                                    height: 28,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.red,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      controller.isRecording
                                          ? 'جاري التسجيل: ${controller.recordingDurationStr}'
                                          : controller.audioFilePath != null
                                              ? 'مدة التسجيل: ${controller.recordingDurationStr}'
                                              : 'اضغط على الميكروفون لتسجيل صوت',
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Info/Note box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                mainColor.withOpacity(0.97),
                                mainColor.withOpacity(0.80),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: mainColor.withOpacity(0.13),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.info,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ملاحظة',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'عند الوصف بشكل دقيق و ارفاق صورة و صوت يمكننا تخمين تكلفة عملية الصيانة قبل الكشف عليها',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Submit button
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.isLoading
                                  ? null
                                  : controller.submitOrder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                controller.isLoading
                                    ? 'جارٍ الإرسال...'
                                    : 'إرسال الطلب',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
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
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.four),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
