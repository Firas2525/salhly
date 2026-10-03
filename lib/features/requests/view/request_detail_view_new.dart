import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:salhly/core/utils/phone_utils.dart';
import 'package:salhly/core/utils/ui_utils.dart';
import 'package:salhly/features/requests/model/request_model.dart';

class RequestDetailView extends StatefulWidget {
  final RequestModel request;
  const RequestDetailView({super.key, required this.request});

  @override
  State<RequestDetailView> createState() => _RequestDetailViewState();
}

class _RequestDetailViewState extends State<RequestDetailView> {
  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final local = dt.toLocal();
    final y = local.year.toString();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');

    final hour24 = local.hour;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final h = hour12.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'م' : 'ص';

    return '$y/$m/$d - $h:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final images = r.files.where((f) => f.isImage).toList();
    final audios = r.files.where((f) => f.isAudio).toList();

    final statusLower = r.status.toLowerCase();
    final isCompleted = statusLower.contains('completed') ||
        statusLower.contains('مكتمل');
    final isApproved = statusLower.contains('approved') ||
        statusLower.contains('موافق') ||
        statusLower.contains('قبول');
    final reportDescription = r.reportDescription ?? '';
    final reportAmountPaid = r.reportAmountPaid ?? '';
    final reportWorkerName = r.reportWorkerName ?? '';
    final reportFiles = r.reportFiles ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        title: Text(
          'تفاصيل الطلب #${r.id}',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Order Summary Card
            _buildOrderOverviewCard(r),
            const SizedBox(height: 14),

            // 2. Worker Card (if assigned)
            if (r.worker != null || r.displayWorkerName != null) ...[
              _buildWorkerCard(r),
              const SizedBox(height: 14),
            ],

            // 3. Customer Info Card
            _buildCustomerCard(r),
            const SizedBox(height: 14),

            // 4. Dates & Times Timeline
            _buildTimelineCard(r),
            const SizedBox(height: 14),

            // 5. Description Card
            if (r.description.isNotEmpty) ...[
              _buildDescriptionCard(r),
              const SizedBox(height: 14),
            ],

            // 6. Attached Images
            if (images.isNotEmpty) ...[
              _buildImagesSection(images),
              const SizedBox(height: 14),
            ],

            // 7. Audio Notes
            if (audios.isNotEmpty) ...[
              _buildAudioSection(audios),
              const SizedBox(height: 14),
            ],

            // 8. Completion Report (if completed)
            if (isCompleted &&
                (reportDescription.isNotEmpty ||
                    reportAmountPaid.isNotEmpty ||
                    (r.repairPercentage != null && r.repairPercentage!.isNotEmpty) ||
                    reportWorkerName.isNotEmpty ||
                    reportFiles.isNotEmpty)) ...[
              _buildCompletionReportCard(
                reportWorkerName: reportWorkerName,
                reportAmountPaid: reportAmountPaid,
                isPaymentProcessed: r.isPaymentProcessed,
                repairPercentage: r.repairPercentage,
                reportDescription: reportDescription,
                reportFiles: reportFiles,
              ),
              const SizedBox(height: 14),
            ],

            // 9. Complaints & Support (if completed or approved)
            if (isCompleted || isApproved) ...[
              _buildComplaintsSection(r),
              const SizedBox(height: 14),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Complaints & Support Section (Using API)
  Widget _buildComplaintsSection(RequestModel r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rate_review_outlined,
                  color: Colors.red.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'للشكاوى والملاحظات',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'هل واجهتك أي مشكلة أو ملاحظة على الصيانة؟ راسلنا وسنتابع الأمر فوراً',
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
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => showComplaintBottomSheet(
                requestId: r.id,
                contextTitle: r.service?.name,
              ),
              icon: const Icon(Icons.rate_review_rounded, size: 17),
              label: Text(
                'تقديم شكوى على الطلب',
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 1,
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

  // 1. Order Overview Card
  Widget _buildOrderOverviewCard(RequestModel r) {
    final statusColor = _getStatusColor(r.status, isPaymentProcessed: r.isPaymentProcessed);
    final statusText = _getStatusText(r.status, isPaymentProcessed: r.isPaymentProcessed);

    return Container(
      width: double.infinity,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.service?.name ?? 'طلب صيانة',
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (r.subService?.name != null &&
                        r.subService!.name.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          r.subService!.name,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem(
                label: 'التقديم',
                value: r.createdAt != null ? _formatDate(r.createdAt) : '-',
              ),
              if (r.currentStatusDate != null &&
                  r.currentStatusDate != r.createdAt)
                _summaryItem(
                  label: r.currentStatusDateLabel,
                  value: _formatDate(r.currentStatusDate),
                  valueColor: statusColor,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // 2. Worker Card
  Widget _buildWorkerCard(RequestModel r) {
    final worker = r.worker;
    final workerName = r.displayWorkerName;
    if (worker == null && workerName == null) return const SizedBox.shrink();

    final name = worker?.name ?? workerName ?? '';
    final phone = worker?.phone;
    final email = worker?.email;
    final imageUrl = worker?.fullImageUrl ?? '';

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
              const Icon(
                Icons.engineering_outlined,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'الفني المكلف بالصيانة',
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 44,
                  height: 44,
                  color: Colors.blue.withValues(alpha: 0.08),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (c, u, e) => const Icon(
                            Icons.person,
                            size: 24,
                            color: Colors.blue,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 24,
                          color: Colors.blue,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'فني معتمد لدى صلّحلي',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (phone != null && phone.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => dialPhoneNumber(phone),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.call, size: 14),
                  label: Text(
                    'اتصال',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (phone != null && phone.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 15,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'رقم هاتف الفني: ',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  phone,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
          if (email != null && email.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  email,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 3. Customer Info Card
  Widget _buildCustomerCard(RequestModel r) {
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
              const Icon(
                Icons.person_outline_rounded,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
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
          const SizedBox(height: 12),
          _detailRow(
            icon: Icons.person,
            label: 'الاسم',
            value: r.fullName,
          ),
          const SizedBox(height: 8),
          _detailRow(
            icon: Icons.phone_outlined,
            label: 'رقم الهاتف',
            value: r.phoneNumber,
          ),
          const SizedBox(height: 8),
          _detailRow(
            icon: Icons.location_on_outlined,
            label: 'العنوان',
            value: r.address,
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? action,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
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
        if (action != null) action,
      ],
    );
  }

  // 4. Dates Timeline Card
  Widget _buildTimelineCard(RequestModel r) {
    final List<Map<String, dynamic>> timelineItems = [];

    if (r.createdAt != null) {
      timelineItems.add({
        'title': 'تقديم الطلب',
        'date': r.createdAt,
        'color': Colors.blue,
      });
    }

    if (r.pendingAt != null) {
      timelineItems.add({
        'title': 'قيد الانتظار',
        'date': r.pendingAt,
        'color': const Color(0xFFD97706),
      });
    }

    if (r.approvedAt != null) {
      timelineItems.add({
        'title': 'الموافقة على الطلب',
        'date': r.approvedAt,
        'color': Colors.blue,
      });
    }

    if (r.completedAt != null) {
      timelineItems.add({
        'title': 'اكتمال الصيانة',
        'date': r.completedAt,
        'color': const Color(0xFF16A34A),
      });
    }

    if (r.rejectedAt != null) {
      timelineItems.add({
        'title': 'الإلغاء / الرفض',
        'date': r.rejectedAt,
        'color': const Color(0xFF64748B),
      });
    }

    if (r.updatedAt != null &&
        r.updatedAt != r.createdAt &&
        r.updatedAt != r.approvedAt &&
        r.updatedAt != r.completedAt &&
        r.updatedAt != r.rejectedAt) {
      timelineItems.add({
        'title': 'آخر تحديث للبيانات',
        'date': r.updatedAt,
        'color': Colors.blueGrey,
      });
    }

    if (timelineItems.isEmpty) return const SizedBox.shrink();

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
              const Icon(
                Icons.schedule_rounded,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
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

  // 5. Description Card
  Widget _buildDescriptionCard(RequestModel r) {
    return Container(
      width: double.infinity,
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
              const Icon(
                Icons.description_outlined,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'وصف العطل / المشكلة',
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            r.description,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: const Color(0xFF334155),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 6. Attached Images Section
  Widget _buildImagesSection(List<RequestFile> images) {
    return Container(
      width: double.infinity,
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
                  const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الصور المرفقة (${images.length})',
                    style: GoogleFonts.cairo(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openImageViewer(images, index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: images[index].fullUrl,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (c, u, e) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(
                        Icons.broken_image,
                        size: 24,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 7. Attached Audio Section
  Widget _buildAudioSection(List<RequestFile> audios) {
    return Container(
      width: double.infinity,
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
              const Icon(
                Icons.mic_none_rounded,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'التسجيلات الصوتية المرفقة',
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...audios.map(
            (audio) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AudioCard(file: audio),
            ),
          ),
        ],
      ),
    );
  }

  // 8. Completion Report Card
  Widget _buildCompletionReportCard({
    required String reportWorkerName,
    required String reportAmountPaid,
    bool isPaymentProcessed = false,
    String? repairPercentage,
    required String reportDescription,
    required List<RequestFile> reportFiles,
  }) {
    final reportImages = reportFiles.where((f) => f.isImage).toList();
    final reportAudios = reportFiles.where((f) => f.isAudio).toList();
    final reportBorderColor = isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: reportBorderColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: reportBorderColor.withValues(alpha: 0.04),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: reportBorderColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تقرير إنجاز الصيانة',
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: reportBorderColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C))
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C))
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaymentProcessed ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                      size: 13,
                      color: isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPaymentProcessed ? 'تم الدفع' : 'لم يتم الدفع',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (reportWorkerName.isNotEmpty ||
              reportAmountPaid.isNotEmpty ||
              (repairPercentage != null && repairPercentage.isNotEmpty)) ...[
            if (reportWorkerName.isNotEmpty) ...[
              _detailRow(
                icon: Icons.person_outline,
                label: 'المنفذ',
                value: reportWorkerName,
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                if (reportAmountPaid.isNotEmpty) ...[
                  Expanded(
                    child: _detailRow(
                      icon: Icons.payments_outlined,
                      label: 'المبلغ المدفوع',
                      value: '$reportAmountPaid ل.س',
                    ),
                  ),
                ],
                if (repairPercentage != null && repairPercentage.isNotEmpty) ...[
                  Expanded(
                    child: _detailRow(
                      icon: Icons.percent_rounded,
                      label: 'نسبة صلّحلي',
                      value: '$repairPercentage%',
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (reportDescription.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'ملاحظات الإنجاز: $reportDescription',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                color: const Color(0xFF334155),
              ),
            ),
          ],
          if (reportImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: reportImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _openImageViewer(reportImages, index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: reportImages[index].fullUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ],
          if (reportAudios.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...reportAudios.map(
              (audio) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AudioCard(file: audio),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openImageViewer(List<RequestFile> images, int initialIndex) {
    if (images.isEmpty) return;
    final imageProviders =
        images.map((f) => CachedNetworkImageProvider(f.fullUrl)).toList();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: imageProviders.length,
              pageController: PageController(initialPage: initialIndex),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: imageProviders[index],
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                );
              },
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            Positioned(
              top: 36,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, {bool isPaymentProcessed = false}) {
    final s = status.toLowerCase();
    if (s.contains('pending') || s.contains('قيد')) {
      return const Color(0xFFD97706);
    }
    if (s.contains('approved') || s.contains('موافق')) {
      return Colors.blue;
    }
    if (s.contains('completed') || s.contains('مكتمل')) {
      return isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C);
    }
    if (s.contains('cancel') ||
        s.contains('canceled') ||
        s.contains('reject') ||
        s.contains('rejected') ||
        s.contains('رفض') ||
        s.contains('ملغ')) {
      return const Color(0xFF64748B);
    }
    return Colors.blue;
  }

  String _getStatusText(String status, {bool isPaymentProcessed = false}) {
    final s = status.toLowerCase();
    if (s.contains('pending') || s.contains('قيد')) return 'قيد الانتظار';
    if (s.contains('approved') || s.contains('موافق')) return 'موافق عليه';
    if (s.contains('completed') || s.contains('مكتمل')) {
      return isPaymentProcessed ? 'مكتمل (تم الدفع)' : 'مكتمل (لم يتم الدفع)';
    }
    if (s.contains('cancel') ||
        s.contains('canceled') ||
        s.contains('reject') ||
        s.contains('rejected') ||
        s.contains('رفض') ||
        s.contains('ملغ')) {
      return 'ملغي';
    }
    return status;
  }
}

class _AudioCard extends StatefulWidget {
  final RequestFile file;
  const _AudioCard({required this.file});

  @override
  State<_AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<_AudioCard> {
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
        await _player.play(UrlSource(widget.file.fullUrl));
        if (mounted) setState(() => _isPlaying = true);
      } catch (e) {
        showAppSnackbar('خطأ', 'لا يمكن تشغيل التسجيل الصوتي');
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
                size: 18,
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
                      'تسجيل صوتي',
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
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _duration.inMilliseconds > 0
                        ? _position.inMilliseconds / _duration.inMilliseconds
                        : 0,
                    minHeight: 4,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
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
