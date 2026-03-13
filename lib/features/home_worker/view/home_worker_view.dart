import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/features/auth/view/login.dart';
import '../../../app.dart';
import '../controller/home_worker_controller.dart';
import 'order_detail_worker_view.dart';
import 'package:salhly/features/home/view/privacy_policy_view.dart';
import '../../../core/utils/ui_utils.dart';

class HomeWorkerView extends StatefulWidget {
  const HomeWorkerView({super.key});

  @override
  State<HomeWorkerView> createState() => _HomeWorkerViewState();
}

class _HomeWorkerViewState extends State<HomeWorkerView>
    with TickerProviderStateMixin {
  final controller = Get.put(HomeWorkerController());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // الخروج من التطبيق عند الضغط على زر الرجوع
        // ننادي SystemNavigator.pop فقط ونمنع إطار فلاتر من عمل pop للمسار
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF7F8FA),
        appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.four, AppColors.four.withOpacity(0.85)],
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        title: const Text(
          'طلبات العامل',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_outlined, color: Colors.white),
            onPressed: () {
              final ctrl = Get.find<HomeWorkerController>();
              showConfirmDialog(
                title: 'تسجيل خروج',
                middleText: 'هل انت متأكد تسجيل خروجك من الحساب',
                onConfirm: () {
                  ctrl.logout();
                },
                onCancel: () {},
              );
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
            Tab(text: 'قيد الانتظار'),
            Tab(text: 'موافق عليها'),
            Tab(text: 'مكتملة'),
          ],
        ),
      ),
      // drawer removed by request - only logout icon remains in AppBar
      body: GetBuilder<HomeWorkerController>(
        builder: (ctrl) {
          if (ctrl.isLoading) {
            // show shimmer skeleton cards similar to home screen style
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(width: 6, height: 80, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 150,
                                height: 16,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: 120,
                                height: 12,
                                color: Colors.white,
                              ),
                              SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                height: 12,
                                color: Colors.white,
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 12,
                                    color: Colors.white,
                                  ),
                                  Container(
                                    width: 50,
                                    height: 28,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
    ),
    );
  }

  Widget _buildOrdersList(
    List orders,
    String status,
    HomeWorkerController ctrl,
  ) {
    // Pull-to-refresh per-tab so the ListView can receive overscroll gestures
    Future<void> _onRefresh() async {
      try {
        await Future.wait<void>([ctrl.refreshAllOrders(), ctrl.getAboutUs()]);
      } catch (e) {
        // controller shows snackbars on errors
      }
    }

    if (orders.isEmpty) {
      return RefreshIndicator(
        color: AppColors.four,
        onRefresh: _onRefresh,
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
                  SizedBox(height: 16),
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
      onRefresh: _onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        separatorBuilder: (_, __) => SizedBox(height: 12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCardWithAction(order);
        },
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

  Widget _buildOrderCardWithAction(dynamic order) {
    final statusLower = order.status?.toString().toLowerCase() ?? '';
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
    } else if (statusLower.contains('cancel') ||
        statusLower.contains('ملغى') ||
        statusLower.contains('ملغي')) {
      statusColor = Colors.black;
      statusIcon = Icons.cancel_outlined;
    } else {
      statusColor = AppColors.four;
      statusIcon = Icons.info_outline;
    }

    bool isPending =
      statusLower.contains('pending') || statusLower.contains('قيد');
    bool isApproved =
      statusLower.contains('approved') || statusLower.contains('موافق');

    return InkWell(
      onTap: () {
        if (!isPending) {
          Get.to(() => OrderDetailWorkerView(order: order));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
          border: Border(
            left: BorderSide(color: statusColor.withOpacity(0.12), width: 6),
          ),
        ),
        child: Stack(
          children: [
            // Status badge
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: Colors.white, size: 14),
                    SizedBox(width: 4),
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
            // Content with action button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  // Customer name and date
                  Row(
                    children: [
                      Icon(Icons.person, color: AppColors.four, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.fullName,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: Colors.grey, size: 14),
                      SizedBox(width: 4),
                      Text(
                        order.createdAt != null
                            ? order.createdAt.toLocal().toString().split(' ')[0]
                            : '',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Service
                  Row(
                    children: [
                      Icon(Icons.build, color: AppColors.four, size: 16),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${order.serviceName} • ${order.subServiceName}',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
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
                  SizedBox(height: 10),
                  // Bottom row: phone (hidden for pending) and action button
                  Row(
                    children: [
                      if (!isPending) ...[
                        Icon(Icons.phone, size: 14, color: AppColors.four),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            order.phoneNumber ?? '',
                            style: GoogleFonts.cairo(fontSize: 12),
                          ),
                        ),
                      ] else
                        Spacer(),
                      if (isPending)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Get.find<HomeWorkerController>().approveOrder(
                                  order.id,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                minimumSize: Size(56, 36),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
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
                                  Icon(Icons.check, size: 16, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'قبول',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else if (isApproved)
                        // For approved orders show cancel button (remove from pending)
                        OutlinedButton(
                          onPressed: () {
                            showConfirmDialog(
                              title: 'تأكيد',
                              middleText: 'هل تريد إلغاء الطلب؟',
                              onConfirm: () async {
                                await Get.find<HomeWorkerController>().rejectOrder(order.id);
                              },
                              onCancel: () {},
                              confirmText: 'نعم',
                              cancelText: 'لا',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.redAccent, width: 1.5),
                            minimumSize: Size(56, 36),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
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
                              Icon(Icons.cancel, size: 16, color: Colors.redAccent),
                              SizedBox(width: 8),
                              Text(
                                'إلغاء',
                                style: GoogleFonts.cairo(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.four.withOpacity(0.7),
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
}
