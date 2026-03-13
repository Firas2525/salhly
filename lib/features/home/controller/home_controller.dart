import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:salhly/features/auth/view/login.dart';
import 'package:salhly/features/home/model/privacy_policy_model.dart';

import '../../../app.dart';
import '../../../core/utils/app_api.dart';
import '../../../main.dart';
import '../../../core/utils/ui_utils.dart';
import 'package:salhly/models/user_model.dart';
import '../../../notifiction_services.dart';
import '../model/about_us_model.dart';
import '../model/bunner_model.dart';
import '../model/contact_us_model.dart';
import '../model/service_model.dart';

class HomeController extends GetxController {
  bool isLoading = false;
  List<BannerModel> banners = [];
  List<ServicesModel> services = [];
  TextEditingController myPhone = TextEditingController();
  TextEditingController myPassword = TextEditingController();
  TextEditingController myName = TextEditingController();
  TextEditingController myEmail = TextEditingController();
  AboutUsModel? aboutUsModel;
  ContactUsModel? contactUsModel;
  // current logged user
  UserModel? user;
  PrivacyPolicyModel? privacyPolicyModel;
  File? imageFile;

  pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile = File(picked.path);
      update();
    }
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

  deleteAccount() async {
    isLoading = true;
    update();
    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Authorization': 'Bearer $token',
      };
      var request = http.Request(
        'POST',
        Uri.parse('${AppApi.baseUrl}/user/delete'),
      );
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var data = jsonDecode(await response.stream.bytesToString());

      print(response.statusCode);
      if (response.statusCode.toString().substring(0, 1) == "2") {
        showAppSnackbar("نجاح", "تم حذف الحساب بنجاح");
        await App.prefs.clear();
        // Clear in-memory user and update UI
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

  getAds() async {
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
      var uri = Uri.parse("${AppApi.baseUrl}/banner/get");

      var request = http.Request('GET', uri);

      request.headers.addAll(headers);
      var response = await request.send();
      var data = jsonDecode(await response.stream.bytesToString());

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 220) {
        print(data['data']);
        banners = (data['data'] as List)
            .map((e) => BannerModel.fromJson(e))
            .toList();
      } else if (response.statusCode == 403) {
        await App.prefs.clear();
        // Clear in-memory user and update UI
        user = null;
        update();
        Get.offAll(() => Login());
      } else {
        showAppSnackbar("خطأ", data['message'] ?? "حدث خطأ", isError: true);
      }
    } catch (e) {
      print(e);
      showAppSnackbar(
        "خطأ",
        "حدث خطأ أثناء الاتصال. حاول لاحقًا.",
        isError: true,
      );
    }

    getServices();
  }

  getServices() async {
    try {
      String? token = App.prefs.getString('token');
      print(token);
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };
      var uri = Uri.parse("${AppApi.baseUrl}/service/get");

      var request = http.Request('GET', uri);

      request.headers.addAll(headers);
      var response = await request.send();
      var data = jsonDecode(await response.stream.bytesToString());
      print(data);
      print(response.statusCode);
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 210) {
        services = (data["data"] as List)
            .map((e) => ServicesModel.fromJson(e))
            .toList();
        print(data);
      } else {
       // showAppSnackbar("خطأ", data['message'] ?? "حدث خطأ", isError: true);
      }
    } catch (e) {
      print(e);
     /* showAppSnackbar(
        "خطأ",
        "حدث خطأ أثناء الاتصال. حاول لاحقًا.",
        isError: true,
      );*/
    }

    getContactUs();
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

      var data = jsonDecode(await response.stream.bytesToString());
      print(data);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 220) {
        aboutUsModel = AboutUsModel.fromJson(data["data"]);
        print("AboutUs Loaded Successfully");
      } else {
       // showAppSnackbar("خطأ", data['message'] ?? "حدث خطأ", isError: true);
      }
    } catch (e) {
      print(e);
     /* showAppSnackbar(
        "خطأ",
        "حدث خطأ أثناء الاتصال. حاول لاحقًا.",
        isError: true,
      );*/
    }

    isLoading = false;
    update();
  }

  getUser() async {
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
      var data = jsonDecode(await response.stream.bytesToString());
      print(response.statusCode);
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 210 ||
          response.statusCode == 220) {

        if (data is Map && data['data'] != null) {
          try {
            user = UserModel.fromJson(Map<String, dynamic>.from(data['data']));
          } catch (e) {
            print('Failed parse user: $e');
          }
        }
      } else {
     //   showAppSnackbar("خطأ", data['message'] ?? "حدث خطأ", isError: true);
      }
    } catch (e) {
      print(e);
     /* showAppSnackbar(
        "خطأ",
        "حدث خطأ أثناء الاتصال. حاول لاحقًا.",
        isError: true,
      );*/
    }

    isLoading = false;
    update();
  }

  getContactUs() async {
    try {
      String? token = App.prefs.getString('token');

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };

      var uri = Uri.parse("${AppApi.baseUrl}/PrivacyPolicy/ContactUs");
      var request = http.Request('GET', uri);

      request.headers.addAll(headers);
      var response = await request.send();

      var data = jsonDecode(await response.stream.bytesToString());
      print(data);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 220) {
        contactUsModel = ContactUsModel.fromJson(data["data"]);
        print("ContactUs Loaded Successfully");
      } else {
       // showAppSnackbar("خطأ", data['message'] ?? "حدث خطأ", isError: true);
      }
    } catch (e) {
      print(e);
     /* showAppSnackbar(
        "خطأ",
        "حدث خطأ أثناء الاتصال. حاول لاحقًا.",
        isError: true,
      );*/
    }
    getUser();
  }

  getPrivacyPolicy() async {
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
      print(data);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 220) {
        privacyPolicyModel = PrivacyPolicyModel.fromJson(data["data"]);

      } else {
      //  showAppSnackbar("خطأ", data['message'] ?? "حدث خطأ", isError: true);
      }
    } catch (e) {
      print(e);
      /*showAppSnackbar(
        "خطأ",
        "حدث خطأ أثناء الاتصال. حاول لاحقًا.",
        isError: true,
      );*/
    }

    isLoading = false;
    update();
  }

  @override
  void onInit() {
    NotificationServices().getDeviceToken();
    getAds();
    getAboutUs();
    getUser();
    super.onInit();
  }
}
