import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/ui_utils.dart';
import '../controller/create_worker_maintenance_controller.dart';

class CreateWorkerMaintenanceView extends StatelessWidget {
  const CreateWorkerMaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateWorkerMaintenanceController>(
      init: CreateWorkerMaintenanceController(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            centerTitle: true,
            elevation: 4,
            shadowColor: Colors.blue.withValues(alpha: 0.25),
            backgroundColor: Colors.blue,
            surfaceTintColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            title: Text(
              'تسجيل طلب صيانة خارجي',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            leadingWidth: 70,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Info Banner
                    _buildInfoBanner(),
                    const SizedBox(height: 14),

                    // 2. Customer Information Card
                    _buildCustomerInfoCard(ctrl),
                    const SizedBox(height: 14),

                    // 3. Service Selection Card
                    _buildServiceSelectionCard(context, ctrl),
                    const SizedBox(height: 14),

                    // 4. Issue & Media Attachments Card
                    _buildIssueDetailsCard(ctrl),
                    const SizedBox(height: 14),

                    // 5. Completion Report & Payment Card
                    _buildReportAndPaymentCard(ctrl),
                    const SizedBox(height: 22),

                    // 6. Submit Button
                    _buildSubmitButton(ctrl),
                  ],
                ),
              ),

              // Loading Overlay
              if (ctrl.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.4),
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
                            'جارٍ تسجيل الطلب وإرسال التقرير...',
                            style: GoogleFonts.cairo(
                              fontSize: 13.5,
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
          ),
        );
      },
    );
  }

  // 1. Info Banner
  Widget _buildInfoBanner() {
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.post_add_rounded,
              color: Colors.blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تسجيل مهمة صيانة خارجية',
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'لتوثيق طلب صيانة قمت بتنفيذه مباشرة خارج المنظومة مع تفاصيل الدفع والإنجاز',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Customer Information Card
  Widget _buildCustomerInfoCard(CreateWorkerMaintenanceController ctrl) {
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.blue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'بيانات العميل',
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Name
          _buildTextField(
            controller: ctrl.fullNameController,
            label: 'اسم العميل الكامل',
            hint: 'مثال: محمد أحمد',
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 12),

          // Phone
          _buildTextField(
            controller: ctrl.phoneController,
            label: 'رقم الهاتف',
            hint: 'مثال: 0937271481',
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),

          // Address
          _buildTextField(
            controller: ctrl.addressController,
            label: 'عنوان موقع الصيانة',
            hint: 'مثال: دمشق - المزة - جانب جامع الهدى',
            icon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  // 3. Service Selection Card
  Widget _buildServiceSelectionCard(BuildContext context, CreateWorkerMaintenanceController ctrl) {
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: Colors.blue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'نوع الخدمة والتصنيف',
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main Service Selector
          Text(
            'الخدمة الأساسية: *',
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          ctrl.isLoadingServices
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tappable Selector Box
                    InkWell(
                      onTap: () => _showServicePickerBottomSheet(context, ctrl),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ctrl.selectedService != null
                                ? Colors.blue.withValues(alpha: 0.5)
                                : const Color(0xFFE2E8F0),
                            width: ctrl.selectedService != null ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              ctrl.selectedService != null
                                  ? Icons.check_circle_rounded
                                  : Icons.search_rounded,
                              color: ctrl.selectedService != null ? Colors.blue : const Color(0xFF94A3B8),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                ctrl.selectedService != null
                                    ? ctrl.selectedService!.title
                                    : 'اضغط هنا لاختيار نوع الخدمة من القائمة',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: ctrl.selectedService != null ? FontWeight.bold : FontWeight.w500,
                                  color: ctrl.selectedService != null
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF64748B),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Quick Services Grid / Chips (shows all or available services)
                    if (ctrl.services.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ctrl.services.map((s) {
                          final isSelected = ctrl.selectedService?.id == s.id;
                          return InkWell(
                            onTap: () => ctrl.onSelectService(s),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue
                                    : (s.isGolden ? const Color(0xFFFEF3C7) : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue
                                      : (s.isGolden ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
                                  width: isSelected ? 1.5 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.blue.withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.02),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (s.isGolden) ...[
                                    Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: isSelected ? Colors.amberAccent : const Color(0xFFD97706),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    s.title,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : (s.isGolden ? const Color(0xFF92400E) : const Color(0xFF334155)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),

          // Sub Service Selector (if available)
          if (ctrl.selectedService != null) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 14),
            Text(
              'الخدمة الفرعية (اختياري):',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            ctrl.isLoadingSubServices
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ctrl.subServices.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Text(
                          'لا توجد تصنيفات فرعية لهذه الخدمة (سيتم اعتماد الخدمة الرئيسية)',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ctrl.subServices.map((sub) {
                          final isSelected = ctrl.selectedSubService?.id == sub.id;
                          return InkWell(
                            onTap: () => ctrl.onSelectSubService(sub),
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFF0F9FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFBAE6FD),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                sub.title,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFF0369A1),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
          ],
        ],
      ),
    );
  }

  // 4. Issue Details & Media Attachments Card
  Widget _buildIssueDetailsCard(CreateWorkerMaintenanceController ctrl) {
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.build_rounded,
                  color: Colors.blue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'تفاصيل ومرفقات العطل',
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Problem Description
          _buildTextField(
            controller: ctrl.descriptionController,
            label: 'شرح وتوصيف العطل',
            hint: 'مثال: عطل في لوحة التحكم الكهربائية للمصعد...',
            icon: Icons.notes_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Photos Picker Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'صور العطل المرفقة (${ctrl.imageFiles.length}):',
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF334155),
                ),
              ),
              TextButton.icon(
                onPressed: ctrl.pickImage,
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                label: Text(
                  'إضافة صورة',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (ctrl.imageFiles.isNotEmpty) ...[
            const SizedBox(height: 6),
            SizedBox(
              height: 75,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ctrl.imageFiles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          ctrl.imageFiles[index],
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => ctrl.removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Voice Note Section
          Text(
            'تسجيل صوتي لوصف العطل (اختياري):',
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),

          if (ctrl.audioFilePath != null)
            _buildAudioPlayerCard(ctrl)
          else
            _buildAudioRecorderCard(ctrl),
        ],
      ),
    );
  }

  // 5. Completion Report & Payment Card
  Widget _buildReportAndPaymentCard(CreateWorkerMaintenanceController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF16A34A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'تقرير الإنجاز والتحصيل',
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Payment & Percentage Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Paid
              Expanded(
                flex: 3,
                child: _buildTextField(
                  controller: ctrl.amountPaidController,
                  label: 'المبلغ المقبوض (ل.س) *',
                  hint: 'مثال: 50000',
                  icon: Icons.payments_rounded,
                  keyboardType: TextInputType.number,
                  iconColor: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 10),
              // Repair Percentage
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: ctrl.repairPercentageController,
                  label: 'نسبة صلحلي (%) *',
                  hint: 'مثال: 10',
                  icon: Icons.percent_rounded,
                  keyboardType: TextInputType.number,
                  iconColor: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Report Description
          _buildTextField(
            controller: ctrl.reportDescriptionController,
            label: 'تقرير الصيانة والإجراءات المنفذة *',
            hint: 'اكتب ما تم إصلاحه، القطع المستبدلة، والملاحظات...',
            icon: Icons.task_alt_rounded,
            maxLines: 3,
            iconColor: const Color(0xFF16A34A),
          ),
          const SizedBox(height: 14),

          // Report Images (report_files)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'صور إنجاز العمل / الفواتير (${ctrl.reportFiles.length}):',
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF334155),
                ),
              ),
              TextButton.icon(
                onPressed: ctrl.pickReportImage,
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 18, color: Color(0xFF16A34A)),
                label: Text(
                  'إضافة صورة',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),

          if (ctrl.reportFiles.isNotEmpty) ...[
            const SizedBox(height: 6),
            SizedBox(
              height: 75,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ctrl.reportFiles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          ctrl.reportFiles[index],
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => ctrl.removeReportImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 6. Submit Button
  Widget _buildSubmitButton(CreateWorkerMaintenanceController ctrl) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: ctrl.isLoading ? null : () => ctrl.submitWorkerOrder(),
        icon: ctrl.isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_rounded, size: 20),
        label: Text(
          ctrl.isLoading ? 'جارٍ تسجيل الطلب...' : 'تأكيد وحفظ الطلب الخارجي',
          style: GoogleFonts.cairo(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF16A34A),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: const Color(0xFF16A34A).withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // Helper Widget: TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Color iconColor = Colors.blue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          minLines: maxLines > 1 ? 2 : 1,
          keyboardType: keyboardType,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(icon, size: 18, color: iconColor),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
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
              borderSide: BorderSide(color: iconColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widget: Audio Recorder Card
  Widget _buildAudioRecorderCard(CreateWorkerMaintenanceController ctrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                ctrl.isRecording ? Icons.fiber_manual_record : Icons.mic_rounded,
                color: ctrl.isRecording ? Colors.red : Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                ctrl.isRecording
                    ? 'جارٍ التسجيل: ${ctrl.recordingDurationStr}'
                    : 'اضغط للبدء بتسجيل صوتي',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ctrl.isRecording ? Colors.red : const Color(0xFF475569),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.isRecording) {
                ctrl.stopRecording();
              } else {
                ctrl.startRecording();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ctrl.isRecording ? Colors.red : Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              ctrl.isRecording ? 'إيقاف' : 'تسجيل',
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget: Audio Player Card
  Widget _buildAudioPlayerCard(CreateWorkerMaintenanceController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (ctrl.isPlaying) {
                ctrl.stopAudio();
              } else {
                ctrl.playAudio();
              }
            },
            icon: Icon(
              ctrl.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              color: Colors.blue,
              size: 32,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تسجيل صوتي مرفق',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${ctrl.formatDuration(ctrl.playbackPosition)} / ${ctrl.formatDuration(ctrl.playbackDuration)}',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: ctrl.deleteAudio,
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  // Service Picker Bottom Sheet with Search & Clean List
  void _showServicePickerBottomSheet(BuildContext context, CreateWorkerMaintenanceController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredServices = ctrl.services.where((s) {
              if (searchQuery.isEmpty) return true;
              return s.title.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'اختر نوع الخدمة الأساسية',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (val) {
                          setModalState(() {
                            searchQuery = val.trim();
                          });
                        },
                        style: GoogleFonts.cairo(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن خدمة...',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 12.5,
                            color: const Color(0xFF94A3B8),
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // Services List
                  Expanded(
                    child: filteredServices.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  'لم يتم العثور على خدمات مطابقة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            itemCount: filteredServices.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            itemBuilder: (context, index) {
                              final service = filteredServices[index];
                              final isSelected = ctrl.selectedService?.id == service.id;

                              return ListTile(
                                onTap: () {
                                  ctrl.onSelectService(service);
                                  Navigator.of(context).pop();
                                },
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue.withValues(alpha: 0.12)
                                        : (service.isGolden ? const Color(0xFFFEF3C7) : const Color(0xFFF8FAFC)),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : (service.isGolden ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                  child: service.image.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(11),
                                          child: CachedNetworkImage(
                                            imageUrl: service.fullImageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (c, u) => const Center(
                                              child: SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Icon(
                                              service.isGolden ? Icons.star_rounded : Icons.handyman_rounded,
                                              color: service.isGolden ? const Color(0xFFD97706) : Colors.blue,
                                              size: 22,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          service.isGolden ? Icons.star_rounded : Icons.handyman_rounded,
                                          color: isSelected
                                              ? Colors.blue
                                              : (service.isGolden ? const Color(0xFFD97706) : const Color(0xFF64748B)),
                                          size: 22,
                                        ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        service.title,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13.5,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: isSelected ? Colors.blue : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    if (service.isGolden)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFFDE68A)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star_rounded, size: 12, color: Color(0xFFD97706)),
                                            const SizedBox(width: 2),
                                            Text(
                                              'ذهبية',
                                              style: GoogleFonts.cairo(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF92400E),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.blue,
                                        size: 22,
                                      )
                                    : const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: Color(0xFF94A3B8),
                                      ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
