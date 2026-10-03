import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/core/utils/assets_manager.dart';
import 'package:salhly/features/home/view/about_contact_view.dart';
import 'package:salhly/features/home/widgets/animated_logo.dart';
import 'package:salhly/features/requests/controller/requests_controller.dart';
import 'package:salhly/features/requests/model/request_model.dart';
import 'package:salhly/features/requests/view/request_detail_view_new.dart';

class RequestsView extends StatefulWidget {
  const RequestsView({super.key});

  @override
  State<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> {
  final controller = Get.put(RequestsController());

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

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
          'طلبات الصيانة',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        leadingWidth: 70,
        leading: canPop
            ? Padding(
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
              )
            : Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () => Get.to(() => const AboutContactView()),
                  child: Center(
                    child: SizedBox(
                      height: 38,
                      width: 38,
                      child: AnimatedLogo(assetPath: ImgAsset.whiteLogo),
                    ),
                  ),
                ),
              ),
        actions: const [],
      ),
      body: GetBuilder<RequestsController>(
        builder: (reqCtrl) {
          final items = reqCtrl.filteredRequests;

          return Column(
            children: [
              // Filter Chips Row
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'الكل',
                        count: reqCtrl.requests.length,
                        isSelected: reqCtrl.selectedFilter == 'all',
                        color: Colors.blue,
                        onTap: () => reqCtrl.setFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'قيد الانتظار',
                        count: reqCtrl.pendingCount,
                        isSelected: reqCtrl.selectedFilter == 'pending',
                        color: const Color(0xFFD97706),
                        onTap: () => reqCtrl.setFilter('pending'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'موافق عليها',
                        count: reqCtrl.approvedCount,
                        isSelected: reqCtrl.selectedFilter == 'approved',
                        color: Colors.blue,
                        onTap: () => reqCtrl.setFilter('approved'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'مكتملة (مدفوعة)',
                        count: reqCtrl.completedPaidCount,
                        isSelected: reqCtrl.selectedFilter == 'completed_paid',
                        color: const Color(0xFF16A34A),
                        onTap: () => reqCtrl.setFilter('completed_paid'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'مكتملة (غير مدفوعة)',
                        count: reqCtrl.completedUnpaidCount,
                        isSelected: reqCtrl.selectedFilter == 'completed_unpaid',
                        color: const Color(0xFFEA580C),
                        onTap: () => reqCtrl.setFilter('completed_unpaid'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'ملغية',
                        count: reqCtrl.cancelledCount,
                        isSelected: reqCtrl.selectedFilter == 'cancelled',
                        color: const Color(0xFF64748B),
                        onTap: () => reqCtrl.setFilter('cancelled'),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Request Items List
              Expanded(
                child: RefreshIndicator(
                  color: Colors.blue,
                  backgroundColor: Colors.white,
                  onRefresh: () => reqCtrl.getRequests(),
                  child: reqCtrl.isLoading
                      ? ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) => _buildSkeletonCard(),
                        )
                      : items.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(alpha: 0.08),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.assignment_outlined,
                                            size: 40,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          reqCtrl.selectedFilter == 'all'
                                              ? 'لا توجد أي طلبات حالياً'
                                              : 'لا توجد طلبات في هذا القسم',
                                          style: GoogleFonts.cairo(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'يمكنك تقديم طلب صيانة جديد من الصفحة الرئيسية',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12.5,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              controller: reqCtrl.scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 85),
                              itemCount: items.length + (reqCtrl.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == items.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return _buildOrderCard(items[index]);
                              },
                            ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(RequestModel r) {
    final statusColor = _getStatusColor(r.status, isPaymentProcessed: r.isPaymentProcessed);
    final statusText = _getStatusText(r.status, isPaymentProcessed: r.isPaymentProcessed);
    final statusDate = r.currentStatusDate;
    final workerName = r.displayWorkerName;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Get.to(() => RequestDetailView(request: r)),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Service Name & Request ID + Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '#${r.id}',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  r.service?.name ?? 'طلب صيانة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (r.subService?.name != null &&
                              r.subService!.name.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              r.subService!.name,
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.25),
                        ),
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

                // Description
                if (r.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Text(
                      r.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],

                // Worker Name Row (if assigned)
                if (workerName != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.engineering_outlined,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'الفني المختص: ',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          workerName,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Payment Status Row (if completed)
                if (r.status.toLowerCase().contains('completed') || r.status.toLowerCase().contains('مكتمل')) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (r.isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C))
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (r.isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C))
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              r.isPaymentProcessed ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                              size: 15,
                              color: r.isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              r.isPaymentProcessed ? 'حالة الدفع: تم الدفع' : 'حالة الدفع: لم يتم الدفع',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: r.isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                              ),
                            ),
                          ],
                        ),
                        if (r.reportAmountPaid != null && r.reportAmountPaid!.isNotEmpty)
                          Text(
                            '${r.reportAmountPaid} ل.س',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                Divider(color: Colors.grey.shade100, height: 1),
                const SizedBox(height: 8),

                // Bottom Row: Date/Time + View details label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (statusDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatDateTime(statusDate),
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      children: [
                        Text(
                          'عرض التفاصيل',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 11,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 140,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 70,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
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

String _formatDateTime(DateTime? dt) {
  if (dt == null) return '';
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
