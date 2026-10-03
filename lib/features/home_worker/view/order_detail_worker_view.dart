import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/phone_utils.dart';
import '../../../core/utils/ui_utils.dart';
import '../controller/home_worker_controller.dart';
import '../model/maintenance_order_model.dart';

class OrderDetailWorkerView extends StatefulWidget {
  final MaintenanceOrderModel order;
  const OrderDetailWorkerView({super.key, required this.order});

  @override
  State<OrderDetailWorkerView> createState() => _OrderDetailWorkerViewState();
}

class _OrderDetailWorkerViewState extends State<OrderDetailWorkerView> {
  final controller = Get.find<HomeWorkerController>();
  late TextEditingController amountController;
  late TextEditingController percentageController;
  late TextEditingController reportController;
  bool isCompleting = false;
  List<XFile>? _reportFiles = [];

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController();
    percentageController = TextEditingController();
    reportController = TextEditingController();
  }

  @override
  void dispose() {
    amountController.dispose();
    percentageController.dispose();
    reportController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    try {
      return DateFormat('yyyy/MM/dd - hh:mm a', 'ar').format(dt.toLocal());
    } catch (_) {
      try {
        return DateFormat('yyyy-MM-dd HH:mm').format(dt.toLocal());
      } catch (_) {
        return dt.toString().split('.')[0];
      }
    }
  }

  Future<void> _pickFiles() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> picked = await picker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() {
          _reportFiles = [...?_reportFiles, ...picked];
        });
      }
    } catch (e) {
      showAppSnackbar('خطأ', 'فشل اختيار الصور المرفقة', isError: true);
    }
  }

  void _openImageViewer(List<String> imageUrls, int initialIndex) {
    if (imageUrls.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: imageUrls.length,
              pageController: PageController(initialPage: initialIndex),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(imageUrls[index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                );
              },
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      await dialPhoneNumber(phoneNumber);
    } catch (e) {
      showAppSnackbar('خطأ', 'فشل إجراء الاتصال', isError: true);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      String formattedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (formattedPhone.startsWith('00')) {
        formattedPhone = formattedPhone.substring(2);
      } else if (formattedPhone.startsWith('0')) {
        formattedPhone = formattedPhone.substring(1);
      }
      if (!formattedPhone.startsWith('963')) {
        formattedPhone = '963$formattedPhone';
      }

      final Uri uri = Uri.parse('https://wa.me/$formattedPhone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        showAppSnackbar('خطأ', 'تعذر فتح تطبيق واتساب', isError: true);
      }
    } catch (e) {
      showAppSnackbar('خطأ', 'فشل فتح تطبيق واتساب', isError: true);
    }
  }

  Future<void> _completeOrder() async {
    final amount = amountController.text.trim();
    final percentage = percentageController.text.trim();
    final report = reportController.text.trim();

    if (amount.isEmpty) {
      showAppSnackbar('تنبيه', 'يرجى إدخال المبلغ المدفوع', isError: true);
      return;
    }
    if (percentage.isEmpty) {
      showAppSnackbar('تنبيه', 'يرجى إدخال نسبة صلحلي', isError: true);
      return;
    }
    if (report.isEmpty) {
      showAppSnackbar('تنبيه', 'يرجى كتابة تقرير الصيانة والملاحظات', isError: true);
      return;
    }

    setState(() => isCompleting = true);
    try {
      List<File>? files;
      if (_reportFiles != null && _reportFiles!.isNotEmpty) {
        files = _reportFiles!.map((f) => File(f.path)).toList();
      }

      await controller.completeOrder(
        orderId: widget.order.id,
        amountPaid: amount,
        repairPercentage: percentage,
        reportDescription: report,
        reportFiles: files,
      );
    } catch (e) {
      showAppSnackbar('خطأ', 'فشل إكمال الطلب، حاول ثانية', isError: true);
    } finally {
      if (mounted) setState(() => isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final statusLower = order.status.toLowerCase();
    final isApproved = statusLower.contains('approved') || statusLower.contains('موافق');
    final isCompleted = statusLower.contains('completed') || statusLower.contains('مكتمل');
    final images = order.files?.where((f) => f.isImage).toList() ?? [];
    final audios = order.files?.where((f) => f.isAudio).toList() ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.blue.withOpacity(0.25),
        backgroundColor: Colors.blue,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        title: Text(
          'تفاصيل طلب الصيانة',
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
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Order Overview Card
            _buildOrderOverviewCard(order),

            const SizedBox(height: 14),

            // 2. Customer Information & Contact Card
            _buildCustomerCard(order),

            const SizedBox(height: 14),

            // 3. Dates & Milestones Timeline Card
            _buildTimelineCard(order),

            const SizedBox(height: 14),

            // 4. Issue & Media Details Card
            _buildProblemDetailsCard(order, images, audios),

            const SizedBox(height: 14),

            // 5. Report Section (If Completed) or Action Section (If In Progress)
            if (isCompleted)
              _buildCompletedReportCard(order)
            else if (isApproved)
              _buildCompleteOrderFormCard(),
          ],
        ),
      ),
    );
  }

  // 1. Order Overview Card
  Widget _buildOrderOverviewCard(MaintenanceOrderModel order) {
    final statusColor = _getStatusColor(order.status, isPaymentProcessed: order.isPaymentProcessed);
    final statusText = _getStatusText(order.status, isPaymentProcessed: order.isPaymentProcessed);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${order.id}',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'طلب صيانة',
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusText,
                        style: GoogleFonts.cairo(
                          color: statusColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Service Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.build_circle_rounded,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.serviceName.isNotEmpty
                                ? order.serviceName
                                : 'خدمة صيانة عامة',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          if (order.subServiceName.isNotEmpty)
                            Text(
                              order.subServiceName,
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (order.createdAt != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'الطلب: ',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDate(order.createdAt),
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Customer Information Card
  Widget _buildCustomerCard(MaintenanceOrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_pin_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'بيانات العميل والعنوان',
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
          _buildInfoRow(
            icon: Icons.person_rounded,
            label: 'اسم العميل',
            value: order.fullName.isNotEmpty ? order.fullName : 'غير متوفر',
          ),

          const SizedBox(height: 10),

          // Phone
          _buildInfoRow(
            icon: Icons.phone_android_rounded,
            label: 'رقم الهاتف',
            value: order.phoneNumber.isNotEmpty ? order.phoneNumber : 'غير متوفر',
          ),

          if (order.address.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.location_on_rounded,
              label: 'العنوان',
              value: order.address,
            ),
          ],

          // Quick Contact Buttons
          if (order.phoneNumber.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(order.phoneNumber),
                    icon: const Icon(Icons.call_rounded, size: 16),
                    label: Text(
                      'اتصال بالعميل',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(order.phoneNumber),
                    icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                    label: Text(
                      'محادثة واتساب',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 3. Dates & Milestones Timeline Card
  Widget _buildTimelineCard(MaintenanceOrderModel order) {
    final List<Map<String, dynamic>> timelineItems = [];

    if (order.createdAt != null) {
      timelineItems.add({
        'title': 'تقديم الطلب',
        'date': order.createdAt,
        'color': Colors.blue,
      });
    }

    if (order.pendingAt != null) {
      timelineItems.add({
        'title': 'قيد الانتظار',
        'date': order.pendingAt,
        'color': const Color(0xFFD97706),
      });
    }

    if (order.approvedAt != null) {
      timelineItems.add({
        'title': 'الموافقة وتعيين الفني',
        'date': order.approvedAt,
        'color': Colors.blue,
      });
    }

    if (order.completedAt != null) {
      timelineItems.add({
        'title': 'اكتمال الصيانة',
        'date': order.completedAt,
        'color': const Color(0xFF16A34A),
      });
    }

    if (order.rejectedAt != null) {
      timelineItems.add({
        'title': 'الإلغاء / الرفض',
        'date': order.rejectedAt,
        'color': const Color(0xFF64748B),
      });
    }

    if (order.updatedAt != null &&
        order.updatedAt != order.createdAt &&
        order.updatedAt != order.approvedAt &&
        order.updatedAt != order.completedAt &&
        order.updatedAt != order.rejectedAt) {
      timelineItems.add({
        'title': 'آخر تحديث للبيانات',
        'date': order.updatedAt,
        'color': Colors.blueGrey,
      });
    }

    if (timelineItems.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'سجل مواعيد وتحديثات الطلب',
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: List.generate(timelineItems.length, (index) {
              final item = timelineItems[index];
              final isLast = index == timelineItems.length - 1;
              final Color itemColor = item['color'] as Color;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: itemColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 1.5,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['title'] as String,
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            Text(
                              _formatDate(item['date'] as DateTime?),
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: itemColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // 4. Problem Details & Attached Media
  Widget _buildProblemDetailsCard(
    MaintenanceOrderModel order,
    List<OrderFile> images,
    List<OrderFile> audios,
  ) {
    final hasImages = images.isNotEmpty;
    final hasAudios = audios.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'تفاصيل العطل والملفات المرفقة',
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description Text Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Text(
              order.description.isNotEmpty
                  ? order.description
                  : 'لا يوجد وصف مرفق من العميل',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF334155),
                height: 1.5,
              ),
            ),
          ),

          // Audio Player Notes
          if (hasAudios) ...[
            const SizedBox(height: 14),
            Text(
              'التسجيلات الصوتية المرفقة:',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            ...audios.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _AudioPlayerCard(audioUrl: a.fullUrl),
                )),
          ],

          // Attached Images Gallery
          if (hasImages) ...[
            const SizedBox(height: 14),
            Text(
              'صور العطل المرفقة (${images.length}):',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final img = images[index];
                  return GestureDetector(
                    onTap: () => _openImageViewer(
                      images.map((f) => f.fullUrl).toList(),
                      index,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: img.fullUrl,
                          fit: BoxFit.cover,
                          placeholder: (c, u) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image_rounded,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 4. Form for Completing Order (When In Progress)
  Widget _buildCompleteOrderFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: Color(0xFF16A34A),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إنهاء الطلب ورفع تقرير الصيانة',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'يرجى تعبئة التقرير بدقة لإنهاء المهمة بنجاح',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 1. Amount Paid Input
          Text(
            'المبلغ المدفوع من العميل:',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'أدخل المبلغ الإجمالي (مثال: 50000)',
              hintStyle: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.payments_outlined, color: Colors.blue, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 2. Repair Percentage Input (New Parameter)
          Text(
            'نسبة صلحلي (%):',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: percentageController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'أدخل نسبة صلحلي المئوية (مثال: 10)',
              hintStyle: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.percent_rounded, color: Color(0xFF10B981), size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 3. Report Description
          Text(
            'تقرير وإجراءات الصيانة المنفذة:',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: reportController,
            maxLines: 4,
            minLines: 3,
            style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'اكتب تفاصيل ما تم إصلاحه والقطع المستبدلة والملاحظات...',
              hintStyle: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(14),
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
                borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 4. Attach Photos from Job Site
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'صور إنجاز الصيانة (اختياري):',
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF334155),
                ),
              ),
              TextButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                label: Text(
                  'إضافة صور',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          if (_reportFiles != null && _reportFiles!.isNotEmpty) ...[
            const SizedBox(height: 6),
            SizedBox(
              height: 75,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _reportFiles!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_reportFiles![index].path),
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _reportFiles!.removeAt(index);
                            });
                          },
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

          const SizedBox(height: 20),

          // Submit & Cancel Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isCompleting ? null : _completeOrder,
              icon: isCompleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_rounded, size: 18),
              label: Text(
                isCompleting ? 'جارٍ إرسال التقرير...' : 'تأكيد إكمال الطلب وإرسال التقرير',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showConfirmDialog(
                  title: 'إلغاء الطلب',
                  middleText: 'هل أنت متأكد من رغبتك بإلغاء هذا الطلب؟',
                  onConfirm: () => controller.rejectOrder(widget.order.id),
                  onCancel: () {},
                  confirmText: 'نعم، إلغاء',
                  cancelText: 'تراجع',
                );
              },
              icon: const Icon(Icons.close_rounded, size: 18),
              label: Text(
                'إلغاء الطلب والتراجع',
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFDC2626),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Display Completed Report Info (When Status Is Completed)
  Widget _buildCompletedReportCard(MaintenanceOrderModel order) {
    final reportImgs = order.reportFiles ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF16A34A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تقرير إنجاز المهمة المعتمد',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'تم إكمال هذا الطلب بنجاح',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: const Color(0xFF16A34A),
                              fontWeight: FontWeight.bold,
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (order.isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C))
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (order.isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C))
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      order.isPaymentProcessed ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                      size: 12,
                      color: order.isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.isPaymentProcessed ? 'تم الدفع' : 'لم يتم الدفع',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: order.isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (order.amountPaid != null && order.amountPaid!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.payments_rounded,
              label: 'المبلغ المدفوع',
              value: '${order.amountPaid} ل.س',
            ),
            const SizedBox(height: 10),
          ],

          if (order.repairPercentage != null && order.repairPercentage!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.percent_rounded,
              label: 'نسبة صلحلي',
              value: '${order.repairPercentage}%',
            ),
            const SizedBox(height: 10),
          ],

          if (order.reportDescription != null && order.reportDescription!.isNotEmpty) ...[
            Text(
              'تقرير الصيانة:',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Text(
                order.reportDescription!,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: const Color(0xFF334155),
                  height: 1.5,
                ),
              ),
            ),
          ],

          if (reportImgs.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'صور تقرير الإنجاز (${reportImgs.length}):',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: reportImgs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final img = reportImgs[index];
                  return GestureDetector(
                    onTap: () => _openImageViewer(
                      reportImgs.map((f) => f.fullUrl).toList(),
                      index,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: img.fullUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status, {bool isPaymentProcessed = false}) {
    final s = status.toLowerCase();
    if (s.contains('pending') || s.contains('قيد')) {
      return const Color(0xFFD97706);
    } else if (s.contains('approved') || s.contains('موافق')) {
      return const Color(0xFF2563EB);
    } else if (s.contains('completed') || s.contains('مكتمل')) {
      return isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C);
    } else if (s.contains('cancel') || s.contains('ملغ')) {
      return const Color(0xFF64748B);
    }
    return Colors.blue;
  }

  String _getStatusText(String status, {bool isPaymentProcessed = false}) {
    final s = status.toLowerCase();
    if (s.contains('pending') || s.contains('قيد')) {
      return 'قيد الانتظار';
    } else if (s.contains('approved') || s.contains('موافق')) {
      return 'قيد التنفيذ وموافق عليه';
    } else if (s.contains('completed') || s.contains('مكتمل')) {
      return isPaymentProcessed ? 'مكتمل (تم الدفع)' : 'مكتمل (لم يتم الدفع)';
    } else if (s.contains('cancel') || s.contains('ملغ')) {
      return 'ملغي';
    }
    return status;
  }
}

class _AudioPlayerCard extends StatefulWidget {
  final String audioUrl;
  const _AudioPlayerCard({required this.audioUrl});

  @override
  State<_AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<_AudioPlayerCard> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
      if (mounted) setState(() => _isPlaying = false);
    } else {
      try {
        await _player.play(UrlSource(widget.audioUrl));
        if (mounted) setState(() => _isPlaying = true);
      } catch (e) {
        showAppSnackbar('خطأ', 'لا يمكن تشغيل التسجيل الصوتي', isError: true);
      }
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تسجيل صوتي لوصف العطل',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    thumbColor: Colors.blue,
                  ),
                  child: Slider(
                    value: _position.inSeconds
                        .clamp(0, _duration.inSeconds)
                        .toDouble(),
                    max: (_duration.inSeconds > 0 ? _duration.inSeconds : 1).toDouble(),
                    onChanged: (val) async {
                      final newPos = Duration(seconds: val.toInt());
                      await _player.seek(newPos);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
