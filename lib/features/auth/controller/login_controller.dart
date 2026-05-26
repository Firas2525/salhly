import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:salhly/features/auth/view/login.dart';

import '../../../app.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/utils/app_api.dart';
import '../../../main.dart';
import '../../../notifiction_services.dart';
import '../../home/view/home_page_view.dart';
import '../../home/view/new_home_page_view.dart';
import '../../home/controller/home_controller.dart';
import '../../home_worker/view/home_worker_view.dart';

class AuthController extends GetxController {
  bool isLoading = false;

  TextEditingController myPhone = TextEditingController();
  TextEditingController myPassword = TextEditingController();
  TextEditingController myName = TextEditingController();
  TextEditingController myEmail = TextEditingController();

  File? imageFile;

  pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile = File(picked.path);
      update();
    }
  }

  resetPassword() async {
    isLoading = true;
    update();

    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var uri = Uri.parse("${AppApi.baseUrl}/user/reset-password");

      var request = http.MultipartRequest('POST', uri);

      request.fields['email'] = myEmail.text;

      request.headers.addAll(headers);
      var response = await request.send();
      var data = jsonDecode(await response.stream.bytesToString());
      print(response.statusCode);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 220) {
        showAppSnackbar("نجاح", "يمكنك تغيير كلمة المرور من بريدك الالكتروني");
        Get.offAll(() => Login());
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

  login() async {
    isLoading = true;
    update();

    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
        'POST',
        Uri.parse(
          '${AppApi.baseUrl}/login?phone=${myPhone.text}&password=${myPassword.text}',
        ),
      );

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var data = jsonDecode(await response.stream.bytesToString());

      print(data);
      if (response.statusCode == 200) {
        await App.prefs.setString('token', data['data']['token']);
        await App.prefs.setString('type', data['data']['role_id'].toString());
        await App.prefs.setBool('just_logged_in', true);
        NotificationServices().getDeviceToken();

        // Refresh user data before navigating
        try {
          final homeController = Get.find<HomeController>();
          await homeController.getUser();
        } catch (e) {
          print('Could not initialize HomeController: $e');
          // Create new instance if not found
          final homeController = Get.put(HomeController());
          await homeController.getUser();
        }

        if (data['data']['role_id'].toString() == "3") {
          Get.offAll(() => HomeWorkerView());
        } else {
          Get.offAll(() => HomePageView());
        }
      } else {
        showAppSnackbar("خطأ", "رقم الهاتف أو كلمة المرور غير صحيحة");
      }
    } catch (e) {
      print(e);
      showAppSnackbar("خطأ", "حدث خطأ أثناء الاتصال. حاول لاحقًا.");
    }

    isLoading = false;
    update();
  }

  register() async {
    isLoading = true;
    update();

    try {
      var uri = Uri.parse("${AppApi.baseUrl}/register");

      var request = http.MultipartRequest('POST', uri);

      request.fields['name'] = myName.text;
      request.fields['phone'] = myPhone.text;
      request.fields['password'] = myPassword.text;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile!.path),
        );
      }

      var response = await request.send();
      var data = jsonDecode(await response.stream.bytesToString());

      if (response.statusCode == 200) {
        showAppSnackbar("نجاح", "تم إنشاء الحساب بنجاح");
        await App.prefs.setString('token', data['data']['token']);
        await App.prefs.setBool('just_logged_in', true);
        NotificationServices().getDeviceToken();
        // Refresh user data before navigating to home
        try {
          final homeController = Get.find<HomeController>();
          await homeController.getUser();
        } catch (e) {
          print('Could not initialize HomeController: $e');
          // Create new instance if not found
          final homeController = Get.put(HomeController());
          await homeController.getUser();
        }
        Get.offAll(() => HomePageView());
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
