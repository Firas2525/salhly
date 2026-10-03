import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/core/utils/assets_manager.dart';
import 'package:salhly/core/utils/ui_utils.dart';
import 'package:salhly/features/home/view/about_contact_view.dart';
import 'package:salhly/features/home/widgets/animated_logo.dart';
import 'package:salhly/features/notifications/view/notifications_page.dart';

import '../controller/home_worker_controller.dart';
import '../model/maintenance_order_model.dart';
import 'create_worker_maintenance_view.dart';
import 'order_detail_worker_view.dart';
import 'worker_profile_view.dart';

class HomeWorkerView extends StatefulWidget {
  const HomeWorkerView({super.key});

  @override
  State<HomeWorkerView> createState() => _HomeWorkerViewState();
}

class _HomeWorkerViewState extends State<HomeWorkerView> {
  final controller = Get.put(HomeWorkerController());
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildOrdersTab(),
            const WorkerProfileView(showAppBar: false),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment_rounded,
                label: 'طلبات الصيانة',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'الملف الشخصي',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.blue : const Color(0xFF94A3B8),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.blue : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        title: Text(
          'طلبات الفني',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: GestureDetector(
            onTap: () => Get.to(() => const AboutContactView()),
            child: Center(
              child: SizedBox(
                height: 36,
                width: 36,
                child: AnimatedLogo(assetPath: ImgAsset.whiteLogo),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'تسجيل صيانة خارجية',
            onPressed: () => Get.to(() => const CreateWorkerMaintenanceView()),
            icon: const Icon(
              Icons.add_task_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          IconButton(
            tooltip: 'الإشعارات',
            onPressed: () => Get.to(() => const NotificationsPage()),
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      body: GetBuilder<HomeWorkerController>(
        builder: (ctrl) {
          final items = ctrl.filteredOrders;

          return Column(
            children: [
              // Filter Chips Row
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'الكل',
                        count: ctrl.totalCount,
                        isSelected: ctrl.selectedFilter == 'all',
                        color: Colors.blue,
                        onTap: () => ctrl.setFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'قيد الانتظار',
                        count: ctrl.pendingCount,
                        isSelected: ctrl.selectedFilter == 'pending',
                        color: const Color(0xFFD97706),
                        onTap: () => ctrl.setFilter('pending'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'موافق عليها',
                        count: ctrl.approvedCount,
                        isSelected: ctrl.selectedFilter == 'approved',
                        color: const Color(0xFF2563EB),
                        onTap: () => ctrl.setFilter('approved'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'مكتملة (مدفوعة)',
                        count: ctrl.completedPaidCount,
                        isSelected: ctrl.selectedFilter == 'completed_paid',
                        color: const Color(0xFF16A34A),
                        onTap: () => ctrl.setFilter('completed_paid'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'مكتملة (غير مدفوعة)',
                        count: ctrl.completedUnpaidCount,
                        isSelected: ctrl.selectedFilter == 'completed_unpaid',
                        color: const Color(0xFFEA580C),
                        onTap: () => ctrl.setFilter('completed_unpaid'),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Orders List
              Expanded(
                child: RefreshIndicator(
                  color: Colors.blue,
                  backgroundColor: Colors.white,
                  onRefresh: () => ctrl.refreshAllOrders(),
                  child: ctrl.isLoading
                      ? ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: 4,
                          itemBuilder: (context, index) => _buildSkeletonCard(),
                        )
                      : items.isEmpty
                          ? _buildEmptyState(ctrl.selectedFilter)
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return _buildOrderCard(items[index], ctrl);
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
                    ? Colors.white.withOpacity(0.25)
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

  Widget _buildOrderCard(MaintenanceOrderModel order, HomeWorkerController ctrl) {
    final statusColor = _getStatusColor(order.status, isPaymentProcessed: order.isPaymentProcessed);
    final statusText = _getStatusText(order.status, isPaymentProcessed: order.isPaymentProcessed);
    final statusLower = order.status.toLowerCase();
    final isPending = statusLower.contains('pending') || statusLower.contains('قيد');
    final isApproved = statusLower.contains('approved') || statusLower.contains('موافق');
    final isCompleted = statusLower.contains('completed') || statusLower.contains('مكتمل');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isPending
              ? null
              : () {
                  Get.to(() => OrderDetailWorkerView(order: order));
                },
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
                                '#${order.id}',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  order.serviceName.isNotEmpty
                                      ? order.serviceName
                                      : 'طلب صيانة',
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
                          if (order.subServiceName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              order.subServiceName,
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
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withOpacity(0.25),
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

                const SizedBox(height: 10),

                // Customer info row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 14,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.fullName.isNotEmpty
                            ? order.fullName
                            : 'عميل صلحلي',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (order.createdAt != null) ...[
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(order.createdAt!),
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),

                // Address row if available
                if (order.address.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.address,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Description Box
                if (order.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Text(
                      order.description,
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

                // Payment Status Row (if completed)
                if (isCompleted) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (order.isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C))
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (order.isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C))
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              order.isPaymentProcessed ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                              size: 15,
                              color: order.isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              order.isPaymentProcessed ? 'حالة الدفع: تم الدفع' : 'حالة الدفع: لم يتم الدفع',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: order.isPaymentProcessed ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                              ),
                            ),
                          ],
                        ),
                        if (order.amountPaid != null && order.amountPaid!.isNotEmpty)
                          Text(
                            '${order.amountPaid} ل.س',
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

                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade100, height: 1),
                const SizedBox(height: 10),

                // Bottom Action buttons row
                Row(
                  children: [
                    if (isPending) ...[
                      // Accept button (Full width, details hidden for unaccepted orders)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => ctrl.approveOrder(order.id),
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: Text(
                            'قبول الطلب',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ] else if (isApproved) ...[
                      // Complete/Open details button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Get.to(() => OrderDetailWorkerView(order: order)),
                          icon: const Icon(Icons.build_circle_outlined, size: 16),
                          label: Text(
                            'تفاصيل وإنهاء الطلب',
                            style: GoogleFonts.cairo(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Cancel button
                      OutlinedButton.icon(
                        onPressed: () {
                          showConfirmDialog(
                            title: 'إلغاء الطلب',
                            middleText: 'هل أنت متأكد من رغبتك بإلغاء هذا الطلب؟',
                            onConfirm: () => ctrl.rejectOrder(order.id),
                            onCancel: () {},
                            confirmText: 'نعم، إلغاء',
                            cancelText: 'تراجع',
                          );
                        },
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: Text(
                          'إلغاء',
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Completed order
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.task_alt_rounded,
                                    size: 16,
                                    color: Color(0xFF16A34A),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'تم إنجاز الطلب بنجاح',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'عرض التقرير',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 12,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    String title = 'لا توجد طلبات حالياً';
    String subtitle = 'ستظهر لك هنا الطلبات المسندة إليك فور ورودها';
    if (filter == 'pending') {
      title = 'لا توجد طلبات قيد الانتظار';
      subtitle = 'لا توجد طلبات جديدة بانتظار الموافقة حالياً';
    } else if (filter == 'approved') {
      title = 'لا توجد طلبات موافق عليها';
      subtitle = 'قم بقبول الطلبات الجديدة لتبدأ العمل عليها';
    } else if (filter == 'completed') {
      title = 'لا توجد طلبات مكتملة بعد';
      subtitle = 'الطلبات المنجزة ستظهر هنا مع تفاصيل التقرير';
    }

    return ListView(
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
                    color: Colors.blue.withOpacity(0.08),
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
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 140,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  width: 70,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: 180,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
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
      return 'موافق عليه';
    } else if (s.contains('completed') || s.contains('مكتمل')) {
      return isPaymentProcessed ? 'مكتمل (تم الدفع)' : 'مكتمل (لم يتم الدفع)';
    } else if (s.contains('cancel') || s.contains('ملغ')) {
      return 'ملغي';
    }
    return status;
  }

  String _formatDateTime(DateTime dt) {
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
}
