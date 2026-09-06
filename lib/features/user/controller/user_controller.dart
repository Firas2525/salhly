import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:salhly/models/user_model.dart';
import '../../../app.dart';
import '../../../core/utils/app_api.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../main.dart';
import '../../auth/view/login.dart';
import '../../home/view/home_navigation_view.dart';
import '../../home/view/new_home_page_view.dart';
import '../../home/controller/home_controller.dart';

class UserController extends GetxController {
  bool isLoading = false;

  TextEditingController myPhone = TextEditingController();
  TextEditingController myName = TextEditingController();
  TextEditingController myEmail = TextEditingController();
  TextEditingController myCurrentPassword = TextEditingController();
  TextEditingController myNewPassword = TextEditingController();
  TextEditingController myConfirmPassword = TextEditingController();

  File? imageFile;
  String? currentUserImage;

  pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile = File(picked.path);
      update();
    }
  }

  populateUserData(UserModel user) {
    myName.text = user.name ?? '';
    myPhone.text = user.phone ?? '';
    myEmail.text = user.email ?? '';
    currentUserImage = user.image;
    isLoading = false;
    update();
  }

  updateUser() async {
    isLoading = true;
    update();

    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var uri = Uri.parse("${AppApi.baseUrl}/user/update_user");

      var request = http.MultipartRequest('POST', uri);

      request.fields['name'] = myName.text;
      request.fields['phone'] = myPhone.text;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile!.path),
        );
      }
      request.headers.addAll(headers);
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await App.prefs.clear();
        Get.offAll(() => Login());
        return;
      }

      var data = jsonDecode(responseBody);
      print(response.statusCode);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 220) {
        showAppSnackbar("نجاح", "تم تعديل الحساب بنجاح");
        // Refresh user data in HomeController before navigating
        try {
          final homeController = Get.find<HomeController>();
          await homeController.getUser();
        } catch (e) {
          print('Could not refresh user data: $e');
        }
        Get.offAll(() => const HomeNavigationView());
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

  updatePassword() async {
    isLoading = true;
    update();

    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var uri = Uri.parse("${AppApi.baseUrl}/user/changePassword");

      var request = http.MultipartRequest('POST', uri);

      request.fields['current_password'] = myCurrentPassword.text;
      request.fields['new_password'] = myNewPassword.text;
      request.fields['new_confirm_password'] = myConfirmPassword.text;

      request.headers.addAll(headers);
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await App.prefs.clear();
        Get.offAll(() => Login());
        return;
      }

      var data = jsonDecode(responseBody);
      print(response.statusCode);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 220) {
        showAppSnackbar("نجاح", "تم تعديل كلمة المرور بنجاح");
        // Refresh user data in HomeController before navigating
        try {
          final homeController = Get.find<HomeController>();
          await homeController.getUser();
        } catch (e) {
          print('Could not refresh user data: $e');
        }
        Get.offAll(() => const HomeNavigationView());
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

  getUser() async {
    isLoading = true;
    update();

    try {
      String? token = App.prefs.getString('token');
      print(token);
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };
      var uri = Uri.parse("${AppApi.baseUrl}/user/find");

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
      print(response.statusCode);
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 210 ||
          response.statusCode == 220) {
        if (data is Map && data['data'] != null) {
          try {
            UserModel user = UserModel.fromJson(
              Map<String, dynamic>.from(data['data']),
            );
            populateUserData(user);
          } catch (e) {
            print('Failed to parse user: $e');
          }
        }
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
