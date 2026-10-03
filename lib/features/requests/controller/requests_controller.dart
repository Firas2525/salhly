import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../app.dart';
import '../../../core/utils/app_api.dart';
import '../../../core/utils/ui_utils.dart';
import '../../auth/view/login.dart';
import '../model/request_model.dart';

class RequestsController extends GetxController {
  // Loading states
  bool isLoading = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  int lastPage = 1;
  final int perPage = 15;
  late final ScrollController scrollController;

  List<RequestModel> requests = [];
  String selectedFilter = 'all';

  bool get hasMore => currentPage < lastPage;

  void setFilter(String filter) {
    selectedFilter = filter;
    update();
  }

  List<RequestModel> get filteredRequests {
    if (selectedFilter == 'all') return requests;
    return requests.where((r) {
      final s = r.status.toLowerCase();
      final isComp = s.contains('completed') || s.contains('مكتمل');
      if (selectedFilter == 'pending') {
        return s.contains('pending') || s.contains('قيد');
      }
      if (selectedFilter == 'approved') {
        return s.contains('approved') || s.contains('موافق');
      }
      if (selectedFilter == 'completed_paid') {
        return isComp && r.isPaymentProcessed;
      }
      if (selectedFilter == 'completed_unpaid') {
        return isComp && !r.isPaymentProcessed;
      }
      if (selectedFilter == 'completed') {
        return isComp;
      }
      if (selectedFilter == 'cancelled') {
        return s.contains('cancel') || s.contains('reject') || s.contains('رفض') || s.contains('ملغ');
      }
      return true;
    }).toList();
  }

  int get pendingCount => requests.where((r) {
        final s = r.status.toLowerCase();
        return s.contains('pending') || s.contains('قيد');
      }).length;

  int get approvedCount => requests.where((r) {
        final s = r.status.toLowerCase();
        return s.contains('approved') || s.contains('موافق');
      }).length;

  int get completedPaidCount => requests.where((r) {
        final s = r.status.toLowerCase();
        return (s.contains('completed') || s.contains('مكتمل')) && r.isPaymentProcessed;
      }).length;

  int get completedUnpaidCount => requests.where((r) {
        final s = r.status.toLowerCase();
        return (s.contains('completed') || s.contains('مكتمل')) && !r.isPaymentProcessed;
      }).length;

  int get completedCount => requests.where((r) {
        final s = r.status.toLowerCase();
        return s.contains('completed') || s.contains('مكتمل');
      }).length;

  int get cancelledCount => requests.where((r) {
        final s = r.status.toLowerCase();
        return s.contains('cancel') || s.contains('reject') || s.contains('رفض') || s.contains('ملغ');
      }).length;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    getRequests(reset: true);
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
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 150) {
      loadMoreRequests();
    }
  }

  // Fetch requests (page 1)
  Future<void> getRequests({bool reset = true}) async {
    if (reset) {
      isLoading = true;
      currentPage = 1;
      lastPage = 1;
      update();
    }

    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };
      var uri = Uri.parse("${AppApi.baseUrl}/order/maintenance?page=1&per_page=$perPage");

      final curl = StringBuffer()
        ..writeln("curl --location '$uri' \\")
        ..writeln(headers.entries.map((e) => "--header '${e.key}: ${e.value}'").join(' \\\n'));

      print("\n================== cURL [Get User Requests - Page 1] ==================");
      print(curl.toString());
      print("========================================================================\n");

      var request = http.Request('GET', uri);
      request.headers.addAll(headers);
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await App.prefs.clear();
        Get.offAll(() => Login());
        return;
      }

      var data = jsonDecode(responseBody);
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 210) {
        final List<dynamic> dataList = data?['data'] ?? [];
        requests = dataList.map((e) => RequestModel.fromJson(e)).toList();

        if (data?['pagination'] != null && data['pagination'] is Map) {
          currentPage = _parsePage(data['pagination']['current_page'], fallback: 1);
          lastPage = _parsePage(data['pagination']['last_page'], fallback: currentPage);
        }
      } else {
        showAppSnackbar("خطأ", data?['message'] ?? "حدث خطأ");
      }
    } catch (e) {
      print(e);
      showAppSnackbar("خطأ", "حدث خطأ أثناء الاتصال. حاول لاحقًا.");
    } finally {
      isLoading = false;
      update();
    }
  }

  // Load more requests (next page)
  Future<void> loadMoreRequests() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    update();

    final nextPage = currentPage + 1;

    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };
      var uri = Uri.parse("${AppApi.baseUrl}/order/maintenance?page=$nextPage&per_page=$perPage");

      final curl = StringBuffer()
        ..writeln("curl --location '$uri' \\")
        ..writeln(headers.entries.map((e) => "--header '${e.key}: ${e.value}'").join(' \\\n'));

      print("\n================== cURL [Get User Requests - Page $nextPage] ==================");
      print(curl.toString());
      print("==============================================================================\n");

      var request = http.Request('GET', uri);
      request.headers.addAll(headers);
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await App.prefs.clear();
        Get.offAll(() => Login());
        return;
      }

      var data = jsonDecode(responseBody);
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 210) {
        final List<dynamic> dataList = data?['data'] ?? [];
        final newItems = dataList.map((e) => RequestModel.fromJson(e)).toList();
        requests.addAll(newItems);

        if (data?['pagination'] != null && data['pagination'] is Map) {
          currentPage = _parsePage(data['pagination']['current_page'], fallback: nextPage);
          lastPage = _parsePage(data['pagination']['last_page'], fallback: nextPage);
        } else {
          currentPage = nextPage;
        }
      } else {
        showAppSnackbar("خطأ", data?['message'] ?? "حدث خطأ");
      }
    } catch (e) {
      print('Error loading more requests: $e');
    } finally {
      isLoadingMore = false;
      update();
    }
  }
}
