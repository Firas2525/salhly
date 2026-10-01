import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/core/utils/ui_utils.dart';
import '../../home_worker/controller/home_worker_controller.dart';
import '../../home_worker/model/maintenance_order_model.dart';
import '../../home_worker/view/order_detail_worker_view.dart';

class AdminOrdersTab extends StatefulWidget {
  const AdminOrdersTab({super.key});

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final HomeWorkerController _workerCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (Get.isRegistered<HomeWorkerController>()) {
      _workerCtrl = Get.find<HomeWorkerController>();
    } else {
      _workerCtrl = Get.put(HomeWorkerController());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.four,
                AppColors.four.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          'إدارة طلبات الصيانة',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'تحديث الطلبات',
            onPressed: () {
              _workerCtrl.refreshAllOrders();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          tabs: [
            GetBuilder<HomeWorkerController>(
              builder: (ctrl) => Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('قيد الانتظار'),
                    if (ctrl.pendingOrders.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _buildCountBadge(ctrl.pendingOrders.length, Colors.redAccent),
                    ],
                  ],
                ),
              ),
            ),
            GetBuilder<HomeWorkerController>(
              builder: (ctrl) => Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('موافق عليها'),
                    if (ctrl.approvedOrders.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _buildCountBadge(ctrl.approvedOrders.length, Colors.blueAccent),
                    ],
                  ],
                ),
              ),
            ),
            GetBuilder<HomeWorkerController>(
              builder: (ctrl) => Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('مكتملة'),
                    if (ctrl.completedOrders.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _buildCountBadge(ctrl.completedOrders.length, Colors.green),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: GetBuilder<HomeWorkerController>(
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 160, height: 16, color: Colors.white),
                        const SizedBox(height: 10),
                        Container(width: 120, height: 12, color: Colors.white),
                        const SizedBox(height: 12),
                        Container(width: double.infinity, height: 14, color: Colors.white),
                      ],
                    ),
                  );
                },
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(ctrl.pendingOrders, 'pending', ctrl),
              _buildOrdersList(ctrl.approvedOrders, 'approved', ctrl),
              _buildOrdersList(ctrl.completedOrders, 'completed', ctrl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCountBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrdersList(
    List<MaintenanceOrderModel> orders,
    String status,
    HomeWorkerController ctrl,
  ) {
    Future<void> onRefresh() async {
      try {
        await ctrl.refreshAllOrders();
      } catch (_) {}
    }

    if (orders.isEmpty) {
      return RefreshIndicator(
        color: AppColors.four,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 80),
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد طلبات',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.four,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(14),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCardWithAction(order);
        },
      ),
    );
  }

  Widget _buildOrderCardWithAction(MaintenanceOrderModel order) {
    final statusLower = order.status.toLowerCase();
    Color statusColor;
    IconData statusIcon;
    if (statusLower.contains('pending') || statusLower.contains('قيد')) {
      statusColor = Colors.redAccent;
      statusIcon = Icons.hourglass_top_rounded;
    } else if (statusLower.contains('approved') ||
        statusLower.contains('موافق')) {
      statusColor = const Color(0xFF1E88E5);
      statusIcon = Icons.thumb_up_alt;
    } else if (statusLower.contains('completed') ||
        statusLower.contains('مكتمل')) {
      statusColor = Colors.green.shade600;
      statusIcon = Icons.check_circle_outline;
    } else {
      statusColor = AppColors.four;
      statusIcon = Icons.info_outline;
    }

    final bool isPending =
        statusLower.contains('pending') || statusLower.contains('قيد');
    final bool isApproved =
        statusLower.contains('approved') || statusLower.contains('موافق');

    return InkWell(
      onTap: () {
        if (!isPending) {
          Get.to(() => OrderDetailWorkerView(order: order));
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border(
            left: BorderSide(
              color: statusColor.withValues(alpha: 0.8),
              width: 5,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Status badge
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusText(order.status),
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Customer name and date
                  Row(
                    children: [
                      Icon(Icons.person, color: AppColors.four, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.fullName,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        order.createdAt != null
                            ? order.createdAt!.toLocal().toString().split(' ')[0]
                            : '',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Service
                  Row(
                    children: [
                      Icon(Icons.build_outlined, color: AppColors.four, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${order.serviceName} • ${order.subServiceName}',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    order.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Bottom row
                  Row(
                    children: [
                      if (!isPending) ...[
                        Icon(Icons.phone_outlined, size: 14, color: AppColors.four),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            order.phoneNumber,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ] else
                        const Spacer(),
                      if (isPending)
                        ElevatedButton(
                          onPressed: () {
                            _workerCtrl.approveOrder(order.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            minimumSize: const Size(60, 36),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'قبول',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (isApproved)
                        OutlinedButton(
                          onPressed: () {
                            showConfirmDialog(
                              title: 'تأكيد',
                              middleText: 'هل تريد إلغاء الطلب؟',
                              onConfirm: () async {
                                await _workerCtrl.rejectOrder(order.id);
                              },
                              onCancel: () {},
                              confirmText: 'نعم',
                              cancelText: 'لا',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent, width: 1.5),
                            minimumSize: const Size(60, 36),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                              const SizedBox(width: 6),
                              Text(
                                'إلغاء',
                                style: GoogleFonts.cairo(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.four.withValues(alpha: 0.7),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'approved':
        return 'موافق عليه';
      case 'completed':
        return 'مكتمل';
      default:
        return status;
    }
  }
}
