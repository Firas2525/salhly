import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import 'package:salhly/features/service/controller/request_service_controller.dart';

class ServiceOrderPage extends StatefulWidget {
  final int serviceId;
  final int? subServiceId;
  final bool isGolden;

  const ServiceOrderPage({
    super.key,
    required this.serviceId,
    this.subServiceId,
    this.isGolden = false,
  });

  @override
  State<ServiceOrderPage> createState() => _ServiceOrderPageState();
}

class _ServiceOrderPageState extends State<ServiceOrderPage> {
  late RequestServiceController controller;
  bool _isGolden = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RequestServiceController());
    controller.serviceId = widget.serviceId;
    if (widget.subServiceId != null) {
      controller.selectedSubServiceId = widget.subServiceId;
    }

    _isGolden = widget.isGolden;
    if (!_isGolden && Get.isRegistered<HomeController>()) {
      _isGolden = Get.find<HomeController>()
          .goldenServices
          .any((g) => g.id == widget.serviceId);
    }
    controller.isGolden = _isGolden;
    controller.autoFillUserData();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.blue;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        title: Text(
          'طلب خدمة صيانة',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GetBuilder<RequestServiceController>(
        builder: (ctrl) {
          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Service Summary Banner Card
                    _buildTopBanner(ctrl, primaryColor),
                    const SizedBox(height: 14),

                    // 2. Personal Information Card
                    _buildPersonalInfoCard(ctrl, primaryColor),
                    const SizedBox(height: 14),

                    // 3. Problem Description Card
                    _buildDescriptionCard(ctrl, primaryColor),
                    const SizedBox(height: 14),

                    // 4. Attachments (Photos & Voice) Card
                    _buildAttachmentsCard(ctrl, primaryColor),
                    const SizedBox(height: 14),

                    // 5. Note / Guarantee Notice Card
                    _buildNoticeCard(primaryColor),
                    const SizedBox(height: 20),

                    // 6. Submit Button
                    _buildSubmitButton(ctrl, primaryColor),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // Loading Overlay
              if (ctrl.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 22,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.blue),
                          const SizedBox(height: 16),
                          Text(
                            'جارٍ إرسال طلبك...',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // 1. Top Summary Banner
  Widget _buildTopBanner(RequestServiceController ctrl, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.handyman_rounded,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تقديم طلب صيانة فوري',
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'املأ البيانات التالية لإرسال الطلب للفنيين المختصين',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Personal Information Card
  Widget _buildPersonalInfoCard(
    RequestServiceController ctrl,
    Color primaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'البيانات الأساسية',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ctrl.autoFillUserData();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.autorenew_rounded, size: 13, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'تعبئة من الحساب',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Name Input
          _buildInputField(
            controller: ctrl.fullNameController,
            label: 'الاسم الكامل',
            hint: 'أدخل اسمك الكامل',
            icon: Icons.person_outline_rounded,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 12),

          // Phone Input
          _buildInputField(
            controller: ctrl.phoneController,
            label: 'رقم الهاتف للتواصل',
            hint: '05xxxxxxxx',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 12),

          // Address Input
          _buildInputField(
            controller: ctrl.addressController,
            label: 'العنوان بالتفصيل',
            hint: 'المدينة، الحي، الشارع أو المعلم القريب',
            icon: Icons.location_on_outlined,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  // 3. Problem Description Card
  Widget _buildDescriptionCard(
    RequestServiceController ctrl,
    Color primaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'وصف العطل أو الصيانة المطلوبة',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: ctrl.descriptionController,
            maxLines: 3,
            style: GoogleFonts.cairo(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'اكتب وصفاً قصيراً لما تحتاجه أو للمشكلة...',
              hintStyle: GoogleFonts.cairo(
                fontSize: 12.5,
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Attachments (Photos & Audio) Card
  Widget _buildAttachmentsCard(
    RequestServiceController ctrl,
    Color primaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photos Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.photo_camera_back_outlined,
                    color: primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الصور المرفقة',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (ctrl.imageFiles.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${ctrl.imageFiles.length} صور',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Photos Grid
          SizedBox(
            height: 75,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: ctrl.imageFiles.length + 1,
              itemBuilder: (context, index) {
                if (index == ctrl.imageFiles.length) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ctrl.pickImage();
                    },
                    child: Container(
                      width: 75,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: primaryColor,
                            size: 24,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'إضافة صورة',
                            style: GoogleFonts.cairo(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final file = ctrl.imageFiles[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          file,
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 3,
                        right: 3,
                        child: GestureDetector(
                          onTap: () => ctrl.removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 14),

          // Audio Header
          Row(
            children: [
              Icon(
                Icons.mic_none_rounded,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'تسجيل صوتي (اختياري)',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Audio Controls
          if (ctrl.audioFilePath != null && !ctrl.isRecording)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: ctrl.isPlaying ? ctrl.stopAudio : ctrl.playAudio,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        ctrl.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تم حفظ التسجيل الصوتي',
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          ctrl.isPlaying
                              ? '${ctrl.formatDuration(ctrl.playbackPosition)} / ${ctrl.formatDuration(ctrl.playbackDuration)}'
                              : 'جاهز للإرسال مع الطلب',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: ctrl.deleteAudio,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                ctrl.isRecording ? ctrl.stopRecording() : ctrl.startRecording();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: ctrl.isRecording
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ctrl.isRecording
                        ? Colors.redAccent
                        : primaryColor.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      ctrl.isRecording
                          ? Icons.stop_circle_rounded
                          : Icons.mic_rounded,
                      color: ctrl.isRecording ? Colors.redAccent : primaryColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ctrl.isRecording
                          ? 'جارٍ التسجيل: ${ctrl.recordingDurationStr} (اضغط للإيقاف)'
                          : 'اضغط لتسجيل صوتي يشرح العطل بدقة',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: ctrl.isRecording
                            ? Colors.redAccent
                            : primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 5. Reassurance Notice Card
  Widget _buildNoticeCard(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Icon(
            _isGolden
                ? Icons.workspace_premium_rounded
                : Icons.info_outline_rounded,
            color: primaryColor,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isGolden
                  ? 'طلب مميز: يتم توجيه طلبك للفنيين ذوي التقييمات الأعلى للمعاينة والإنجاز السريع.'
                  : 'عند الوصف بدقة أو إرفاق صورة/صوت، يمكن للفني تقييم وتخمين التكلفة بدقة أسرع.',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: const Color(0xFF1E40AF),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 6. Primary Action Button
  Widget _buildSubmitButton(
    RequestServiceController ctrl,
    Color primaryColor,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: ctrl.isLoading
            ? null
            : () {
                HapticFeedback.heavyImpact();
                ctrl.submitOrder();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.send_rounded, size: 18),
            const SizedBox(width: 8),
            Text(
              'تأكيد وإرسال الطلب',
              style: GoogleFonts.cairo(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.cairo(fontSize: 13.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(
              fontSize: 12.5,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, color: primaryColor, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
