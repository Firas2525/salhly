import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app.dart';
import '../../../core/utils/app_api.dart';
import '../../../core/utils/ui_utils.dart';
import '../../auth/view/login.dart';
import '../model/privacy_policy_model.dart';

class PrivacyController extends GetxController {
  bool isLoading = false;
  PrivacyPolicyModel? privacyPolicyModel;

  @override
  void onInit() {
    super.onInit();
    getPrivacyPolicy();
  }

  Future<void> getPrivacyPolicy() async {
    isLoading = true;
    update();

    try {
      String? token = App.prefs.getString('token');

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };

      var uri = Uri.parse("${AppApi.baseUrl}/PrivacyPolicy/get");
      var request = http.Request('GET', uri);

      request.headers.addAll(headers);
      var response = await request.send();

      var data = jsonDecode(await response.stream.bytesToString());
      // print(data);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 220) {
        privacyPolicyModel = PrivacyPolicyModel.fromJson(data["data"]);
      } else {
        showAppSnackbar("خطأ", data['message'] ?? "حدث خطأ");
      }
    } catch (e) {
      print(e);
      showAppSnackbar("خطأ", "حدث خطأ أثناء الاتصال. حاول لاحقًا.");
    }

    isLoading = false;
    update();
  }
}
