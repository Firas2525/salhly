import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import 'package:salhly/features/notifications/service/notifications_service.dart';

class NotificationsController extends GetxController {
  HomeController get homeController => Get.find<HomeController>();
  final NotificationsService _service = NotificationsService();

  bool isLoading = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  int lastPage = 1;
  final int perPage = 10;
  late final ScrollController scrollController;

  List get notifications => homeController.notifications;
  int get unreadCount => homeController.unreadNotificationsCount;
  bool get hasMore => currentPage < lastPage;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    _loadNotifications();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  int _parsePage(dynamic value, {int fallback = 1}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  void _onScroll() {
    if (!scrollController.hasClients || isLoading || isLoadingMore || !hasMore) return;
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 120) {
      loadMoreNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    isLoading = true;
    update();

    currentPage = 1;
    lastPage = 1;

    final response = await homeController.getNotifications(page: currentPage, perPage: perPage, reset: true);
    if (response != null) {
      currentPage = _parsePage(response.pagination['current_page'], fallback: 1);
      lastPage = _parsePage(response.pagination['last_page'], fallback: currentPage);
    }

    isLoading = false;
    update();
  }

  Future<void> loadMoreNotifications() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    update();

    final nextPage = currentPage + 1;
    final response = await homeController.getNotifications(page: nextPage, perPage: perPage, reset: false);
    if (response != null) {
      currentPage = _parsePage(response.pagination['current_page'], fallback: nextPage);
      lastPage = _parsePage(response.pagination['last_page'], fallback: nextPage);
    }

    isLoadingMore = false;
    update();
  }

  void markAsRead(int id) {
    // استدعاء API بدون انتظار النتيجة
    _service.markNotificationAsRead(id);
    
    // تحديث البيانات محلياً
    final index = homeController.notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final notification = homeController.notifications[index];
      if (!notification.isRead) {
        homeController.notifications[index] = notification.copyWith(isRead: true);
        // تقليل عدد الإشعارات غير المقروءة بمقدار 1
        if (homeController.unreadNotificationsCount > 0) {
          homeController.unreadNotificationsCount--;
        }
        homeController.update();
        update();
      }
    }
  }
}