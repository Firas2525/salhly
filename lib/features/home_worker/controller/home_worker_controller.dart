import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:salhly/features/auth/view/login.dart';
import 'package:salhly/features/home/model/privacy_policy_model.dart';

import '../../../app.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/utils/app_api.dart';
import '../../../main.dart';
import 'package:salhly/models/user_model.dart';
import '../../../notifiction_services.dart';
import '../model/about_us_model.dart';
import '../model/bunner_model.dart';
import '../model/contact_us_model.dart';
import '../model/service_model.dart';
import '../model/maintenance_order_model.dart';
import '../view/home_worker_view.dart';

class HomeWorkerController extends GetxController {
  bool isLoading = false;
  List<MaintenanceOrderModel> pendingOrders = [];
  List<MaintenanceOrderModel> approvedOrders = [];
  List<MaintenanceOrderModel> completedOrders = [];

  UserModel? user;

  Future<void> _forceLogout() async {
    await App.prefs.clear();
    user = null;
    update();
    Get.offAll(() => Login());
  }

  dynamic _tryDecodeBody(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  getAboutUs() async {
    isLoading = true;
    update();

    try {
      String? token = App.prefs.getString('token');

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };

      var uri = Uri.parse("${AppApi.baseUrl}/PrivacyPolicy/About_us");
      var request = http.Request('GET', uri);

      request.headers.addAll(headers);
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await _forceLogout();
        return;
      }

      var data = _tryDecodeBody(responseBody);
      print(data ?? responseBody);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 220) {
        print("AboutUs Loaded Successfully");
      } else {
        showAppSnackbar("خطأ", data?['message'] ?? "حدث خطأ");
      }
    } catch (e) {
      print(e);
      showAppSnackbar("خطأ", "حدث خطأ أثناء الاتصال. حاول لاحقًا.");
    }

    isLoading = false;
    update();
  }

  getPendingOrders() async {
    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };

      var uri = Uri.parse(
        "${AppApi.baseUrl}/order/maintenance_pending?page=1&per_page=100",
      );
      var request = http.Request('GET', uri);
      request.headers.addAll(headers);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await _forceLogout();
        return;
      }

      var data = _tryDecodeBody(responseBody);
      print(data ?? responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data != null && data['data'] != null) {
          pendingOrders = (data['data'] as List)
              .map((o) => MaintenanceOrderModel.fromJson(o))
              .toList();
        } else {
          pendingOrders = [];
        }
      } else {
        showAppSnackbar("خطأ", data?['message'] ?? "حدث خطأ");
      }
    } catch (e) {
      print('Error fetching pending orders: $e');
    }
    update();
  }

  getApprovedOrders() async {
    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };

      var uri = Uri.parse(
        "${AppApi.baseUrl}/order/maintenance_approved?page=1&per_page=100",
      );
      var request = http.Request('GET', uri);
      request.headers.addAll(headers);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await _forceLogout();
        return;
      }

      var data = _tryDecodeBody(responseBody);
      print(data ?? responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data != null && data['data'] != null) {
          approvedOrders = (data['data'] as List)
              .map((o) => MaintenanceOrderModel.fromJson(o))
              .toList();
        } else {
          approvedOrders = [];
        }
      } else {
        showAppSnackbar("خطأ", data?['message'] ?? "حدث خطأ");
      }
    } catch (e) {
      print('Error fetching approved orders: $e');
    }
    update();
  }

  getCompletedOrders() async {
    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };

      var uri = Uri.parse(
        "${AppApi.baseUrl}/order/maintenance_completed?page=1&per_page=100",
      );
      var request = http.Request('GET', uri);
      request.headers.addAll(headers);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await _forceLogout();
        return;
      }

      var data = _tryDecodeBody(responseBody);
      print(data ?? responseBody);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data != null && data['data'] != null) {
          completedOrders = (data['data'] as List)
              .map((o) => MaintenanceOrderModel.fromJson(o))
              .toList();
        } else {
          completedOrders = [];
        }
      } else {
        showAppSnackbar("خطأ", data?['message'] ?? "حدث خطأ");
      }
    } catch (e) {
      print('Error fetching completed orders: $e');
    }
    update();
  }

  refreshAllOrders() async {
    isLoading = true;
    update();
    await Future.wait<void>([
      getPendingOrders(),
      getApprovedOrders(),
      getCompletedOrders(),
    ]);
    isLoading = false;
    update();
  }


  logout() async {
    isLoading = true;
    update();

    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.Request('GET', Uri.parse('${AppApi.baseUrl}/out'));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var data = jsonDecode(await response.stream.bytesToString());

      print(data);
      if (response.statusCode == 200) {
        showAppSnackbar("نجاح", "تم تسجيل الخروج بنجاح");
        await App.prefs.clear();
        // Clear in-memory user and update listeners so UI (drawer) refreshes
        user = null;
        update();
        Get.offAll(() => Login());
      } else {
        showAppSnackbar("خطأ", "حدث خطأ", isError: true);
      }
    } catch (e) {
      print(e);
      showAppSnackbar("خطأ", "حدث خطأ. حاول لاحقًا.", isError: true);
    }

    isLoading = false;
    update();
  }

  approveOrder(int orderId) async {
    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };

      var uri = Uri.parse("${AppApi.baseUrl}/order/change_to_approve/$orderId");
      var request = http.Request('POST', uri);
      request.headers.addAll(headers);

      var response = await request.send();
      var data = jsonDecode(await response.stream.bytesToString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        showAppSnackbar('نجاح', 'تم قبول الطلب بنجاح');
        await refreshAllOrders();
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        await App.prefs.clear();
        user = null;
        update();
        Get.offAll(() => Login());
      } else {
        showAppSnackbar(
          'خطأ',
          data['message'] ?? 'فشل قبول الطلب',
          isError: true,
        );
      }
    } catch (e) {
      print('Error approving order: $e');
      showAppSnackbar('خطأ', 'حدث خطأ أثناء قبول الطلب', isError: true);
    }
  }

  /// Reject (cancel) an order by the worker
  rejectOrder(int orderId) async {
    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };

      var uri = Uri.parse("${AppApi.baseUrl}/order/change_to_reject/$orderId");
      var request = http.Request('POST', uri);
      request.headers.addAll(headers);

      var response = await request.send();
      var data = jsonDecode(await response.stream.bytesToString());

      if (response.statusCode.toString().startsWith('2')) {
        showAppSnackbar('نجاح', data['message'] ?? 'تم إلغاء الطلب بنجاح');
        await refreshAllOrders();
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        await App.prefs.clear();
        user = null;
        update();
        Get.offAll(() => Login());
      } else {
        showAppSnackbar('خطأ', data['message'] ?? 'فشل إلغاء الطلب', isError: true);
      }
    } catch (e) {
      print('Error rejecting order: $e');
      showAppSnackbar('خطأ', 'حدث خطأ أثناء إلغاء الطلب', isError: true);
    }
  }

  /// Complete order with optional report files
  completeOrder({
    required int orderId,
    required String amountPaid,
    required String reportDescription,
    List<File>? reportFiles,
  }) async {
    try {
      String? token = App.prefs.getString('token');

      var uri = Uri.parse(
        "${AppApi.baseUrl}/order/change_to_complete/$orderId",
      );
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      });

      request.fields['amount_paid'] = amountPaid;
      request.fields['report_description'] = reportDescription;

      if (reportFiles != null && reportFiles.isNotEmpty) {
        for (int i = 0; i < reportFiles.length; i++) {
          var file = reportFiles[i];
          if (file.existsSync()) {
            request.files.add(
              await http.MultipartFile.fromPath('report_files[$i]', file.path),
            );
          }
        }
      }

      var response = await request.send();
      var responseData = jsonDecode(await response.stream.bytesToString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        showAppSnackbar('نجاح', 'تم إكمال الطلب بنجاح');
        await refreshAllOrders();
        // go back to worker home
        Get.offAll(() => HomeWorkerView());
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        await App.prefs.clear();
        user = null;
        update();
        Get.offAll(() => Login());
      } else {
        showAppSnackbar(
          'خطأ',
          responseData['message'] ?? 'فشل إكمال الطلب',
          isError: true,
        );
      }
    } catch (e) {
      print('Error completing order: $e');
      showAppSnackbar('خطأ', 'حدث خطأ أثناء إكمال الطلب', isError: true);
    }
  }

  @override
  void onInit() {
    NotificationServices().getDeviceToken();
    refreshAllOrders();
    super.onInit();
  }
}
