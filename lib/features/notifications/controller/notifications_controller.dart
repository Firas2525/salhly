import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import 'package:salhly/features/notifications/model/notification.dart';
import 'package:salhly/features/notifications/service/notifications_service.dart';

class NotificationsController extends GetxController {
  final NotificationsService _service = NotificationsService();

  HomeController? get _homeController =>
      Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;

  bool isLoading = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  int lastPage = 1;
  final int perPage = 10;
  late final ScrollController scrollController;

  List<NotificationModel> notifications = [];
  int unreadCount = 0;
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

    try {
      final response = await _service.getNotifications(page: currentPage, perPage: perPage);
      if (response != null) {
        notifications = response.data;
        unreadCount = response.unreadCount;
        currentPage = _parsePage(response.pagination['current_page'], fallback: 1);
        lastPage = _parsePage(response.pagination['last_page'], fallback: currentPage);

        // Sync with HomeController if present
        final hc = _homeController;
        if (hc != null) {
          hc.notifications = notifications;
          hc.unreadNotificationsCount = unreadCount;
          hc.update();
        }
      }
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> loadMoreNotifications() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    update();

    final nextPage = currentPage + 1;
    try {
      final response = await _service.getNotifications(page: nextPage, perPage: perPage);
      if (response != null) {
        notifications.addAll(response.data);
        unreadCount = response.unreadCount;
        currentPage = _parsePage(response.pagination['current_page'], fallback: nextPage);
        lastPage = _parsePage(response.pagination['last_page'], fallback: nextPage);

        final hc = _homeController;
        if (hc != null) {
          hc.notifications = notifications;
          hc.unreadNotificationsCount = unreadCount;
          hc.update();
        }
      }
    } catch (e) {
      print('Error loading more notifications: $e');
    } finally {
      isLoadingMore = false;
      update();
    }
  }

  void markAsRead(int id) {
    // Call API in background
    _service.markNotificationAsRead(id);

    // Update local notifications
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final notification = notifications[index];
      if (!notification.isRead) {
        notifications[index] = notification.copyWith(isRead: true);
        if (unreadCount > 0) {
          unreadCount--;
        }
        final hc = _homeController;
        if (hc != null) {
          hc.notifications = notifications;
          hc.unreadNotificationsCount = unreadCount;
          hc.update();
        }
        update();
      }
    }
  }
}