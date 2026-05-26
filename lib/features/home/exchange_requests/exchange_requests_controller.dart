import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../app.dart';
import '../../../core/utils/ui_utils.dart';
import 'exchange_piece_request_model.dart';

class ExchangeRequestsController extends GetxController {
  bool isLoading = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  int lastPage = 1;
  final int perPage = 10;
  late final ScrollController scrollController;

  List<ExchangePieceRequest> requests = [];

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    _loadRequests();
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
    if (!scrollController.hasClients || isLoading || isLoadingMore) return;
    if (currentPage >= lastPage) return;
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 120) {
      loadMoreRequests();
    }
  }

  Future<void> _loadRequests() async {
    isLoading = true;
    update();

    currentPage = 1;
    lastPage = 1;

    try {
      String? token = App.prefs.getString('token');
      var uri = Uri.parse('https://www.salhly.lareenmedco.com/api/exchange-pieces/my-requests?page=$currentPage&per_page=$perPage');
      var response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'en',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == true || data['isSuccessful'] == true) {
          final List pageItems = (data['data'] is List) ? data['data'] : (data['data']?['data'] ?? []);
          requests = pageItems.map((r) => ExchangePieceRequest.fromJson(r)).toList();

          Map? pagination = data['pagination'] ?? (data['data'] is Map ? data['data']['pagination'] : null);
          if (pagination != null) {
            currentPage = _parsePage(pagination['current_page'], fallback: 1);
            lastPage = _parsePage(pagination['last_page'], fallback: currentPage);
          }
        } else {
          showAppSnackbar('خطأ', data['message'] ?? 'فشل في جلب الطلبات');
        }
      } else {
        showAppSnackbar('خطأ', 'فشل في جلب الطلبات (حالة: ${response.statusCode})');
      }
    } catch (e) {
      print(e);
      showAppSnackbar('خطأ', 'حدث خطأ أثناء جلب الطلبات');
    }

    isLoading = false;
    update();
  }

  Future<void> loadMoreRequests() async {
    if (isLoadingMore) return;
    if (currentPage >= lastPage) return;

    isLoadingMore = true;
    update();

    final nextPage = currentPage + 1;
    try {
      String? token = App.prefs.getString('token');
      var uri = Uri.parse('https://www.salhly.lareenmedco.com/api/exchange-pieces/my-requests?page=$nextPage&per_page=$perPage');
      var response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'en',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == true || data['isSuccessful'] == true) {
          final List pageItems = (data['data'] is List) ? data['data'] : (data['data']?['data'] ?? []);
          requests.addAll(pageItems.map((r) => ExchangePieceRequest.fromJson(r)).toList());

          Map? pagination = data['pagination'] ?? (data['data'] is Map ? data['data']['pagination'] : null);
          if (pagination != null) {
            currentPage = _parsePage(pagination['current_page'], fallback: nextPage);
            lastPage = _parsePage(pagination['last_page'], fallback: currentPage);
          }
        }
      }
    } catch (e) {
      print(e);
    } finally {
      isLoadingMore = false;
      update();
    }
  }

  ExchangePieceRequest? selectedRequest;

  Future<void> fetchRequestDetails(int id) async {
    selectedRequest = null;
    isLoading = true;
    update();

    try {
      String? token = App.prefs.getString('token');
      var uri = Uri.parse('https://www.salhly.lareenmedco.com/api/exchange-pieces/find/$id');
      var response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'en',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['isSuccessful'] == true) {
          selectedRequest = ExchangePieceRequest.fromJson(data['data']);
          print('Selected request: ${selectedRequest?.id}');
        } else {
          showAppSnackbar('خطأ', data['message'] ?? 'فشل في جلب تفاصيل الطلب');
        }
      } else {
        showAppSnackbar('خطأ', 'فشل في جلب تفاصيل الطلب');
      }
    } catch (e) {
      print('Error fetching request details: $e');
      showAppSnackbar('خطأ', 'حدث خطأ أثناء جلب تفاصيل الطلب');
    }

    isLoading = false;
    update();
  }
}