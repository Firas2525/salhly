import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../app.dart';
import '../../../core/utils/app_api.dart';
import '../../../core/utils/ui_utils.dart';
import '../../auth/view/login.dart';
import '../model/request_model.dart';

class RequestsController extends GetxController {
  // Loading state
  bool isLoading = false;
  List<RequestModel> requests = [];

  // Fetch sub-services for a service id
  Future<void> getRequests() async {
    isLoading = true;
    update();

    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };
      var uri = Uri.parse("${AppApi.baseUrl}/order/maintenance");

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
        print(dataList);
        requests = dataList.map((e) => RequestModel.fromJson(e)).toList();
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

  @override
  void onInit() {
    getRequests();

    super.onInit();
  }
}
