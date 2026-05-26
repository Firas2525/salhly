import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/features/notifications/controller/notifications_controller.dart';
import 'package:salhly/features/notifications/model/notification.dart';
import 'package:salhly/features/home/sell_requests/sell_piece_detail_view.dart';
import 'package:salhly/features/home/exchange_requests/exchange_piece_detail_view.dart';
import 'package:salhly/features/maintenance/view/maintenance_order_detail_view.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final controller = Get.put(NotificationsController());

  void _handleNotificationTap(NotificationModel notification) {
    controller.markAsRead(notification.id);

    if (notification.type == 'sell_piece_request_reviewed' && notification.targetId != null) {
      Get.to(() => SellPieceDetailView(requestId: notification.targetId!));
    } else if (notification.type == 'exchange_piece_request_reviewed' && notification.targetId != null) {
      Get.to(() => ExchangePieceDetailView(requestId: notification.targetId!));
    } else if ((notification.type == 'maintenance_request_status_updated' || notification.type == 'maintenance_request_approved') && notification.targetId != null) {
      Get.to(() => MaintenanceOrderDetailView(orderId: notification.targetId!));
    }
  }

  @override
  Widget build(BuildContext context) {
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
          GetBuilder<NotificationsController>(
            builder: (ctrl) {
              if ((ctrl.homeController.isLoading && ctrl.notifications.isEmpty) || (ctrl.isLoading && ctrl.notifications.isEmpty)) {
                return Center(child: CircularProgressIndicator(color: AppColors.four));
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'الإشعارات',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ctrl.notifications.isEmpty
                            ? Center(
                                child: Text(
                                  'لا توجد إشعارات حالياً',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    color: AppColors.four,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                controller: ctrl.scrollController,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemCount: ctrl.notifications.length + (ctrl.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == ctrl.notifications.length) {
                                    return  Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(child: CircularProgressIndicator(color: AppColors.four)),
                                    );
                                  }
                                  final notification = ctrl.notifications[index];
                                  return _buildNotificationCard(notification);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    IconData icon;
    Color iconColor;
    String label;

    switch (notification.type) {
      case 'sell_piece_request_reviewed':
        icon = Icons.sell;
        iconColor = Colors.green.shade700;
        label = 'بيع قطع';
        break;
      case 'exchange_piece_request_reviewed':
        icon = Icons.swap_horiz;
        iconColor = Colors.blue.shade700;
        label = 'استبدال قطع';
        break;
      case 'maintenance_request_status_updated':
      case 'maintenance_request_approved':
        icon = Icons.build;
        iconColor = Colors.orange.shade700;
        label = 'صيانة';
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey.shade600;
        label = 'إشعار';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          border: Border.all(
            color: notification.isRead ? Colors.grey.withOpacity(0.15) : AppColors.four.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: iconColor, size: 28),
                      ),
                    ],
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.four,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          notification.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                            SizedBox(width: 6),
                            Text(
                              _formatDate(notification.createdAt),
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Spacer(),
                            if (notification.type != null)
                              Icon(Icons.chevron_right, size: 18, color: AppColors.four.withOpacity(0.8)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'اليوم';
      } else if (difference.inDays == 1) {
        return 'أمس';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} أيام';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'sell_piece_request_reviewed':
        return 'بيع قطع';
      case 'exchange_piece_request_reviewed':
        return 'استبدال قطع';
      case 'maintenance_request_status_updated':
      case 'maintenance_request_approved':
        return 'صيانة';
      default:
        return 'إشعار';
    }
  }
}