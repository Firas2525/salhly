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
import '../model/offer_model.dart';
import '../../notifications/model/notification.dart';
import 'package:salhly/features/notifications/service/notifications_service.dart';

class HomeController extends GetxController {
  bool isLoading = false;
  List<BannerModel> banners = [];
  List<ServicesModel> services = [];
  List<Offer> offers = [];
  List<Offer> exchangeOffers = [];
  TextEditingController myPhone = TextEditingController();
  TextEditingController myPassword = TextEditingController();
  TextEditingController myName = TextEditingController();
  TextEditingController myEmail = TextEditingController();
  AboutUsModel? aboutUsModel;
  ContactUsModel? contactUsModel;
  // current logged user
  UserModel? user;
  PrivacyPolicyModel? privacyPolicyModel;

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

  bool _isHtmlResponse(String body) {
    final trimmed = body.trimLeft().toLowerCase();
    return trimmed.startsWith('<!doctype html>') ||
        trimmed.startsWith('<html') ||
        trimmed.contains('<!doctype html>') ||
        trimmed.contains('<html');
  }

  File? imageFile;

  bool _isInitializing = false;
  bool _hasInitialized = false;

  // App appearance values from /api/app-appearance/show
  String appTitle = '';
  String appTopBackground = '';
  String appBottomBackground = '';
  String appTabbarBackground = '';
  String replaceTitle = '';
  String replaceDesc = '';
  String replaceImage = '';
  String buyTitle = '';
  String buyDesc = '';
  String buyImage = '';

  // Notifications
  List<NotificationModel> notifications = [];
  int unreadNotificationsCount = 0;

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
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await _forceLogout();
        return;
      }

      var data = _tryDecodeBody(responseBody);

      print(data);
      if (response.statusCode == 200) {
        showAppSnackbar("نجاح", "تم تسجيل الخروج بنجاح");
        await App.prefs.clear();
        // Clear in-memory user and update listeners so UI (drawer) refreshes
        user = null;
        update();
        Get.offAll(() => Login());
      } else {
        showAppSnackbar("خطأ", data?['message'] ?? "حدث خطأ", isError: true);
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
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await _forceLogout();
        return;
      }

      var data = _tryDecodeBody(responseBody);

      print(response.statusCode);
      if (response.statusCode.toString().substring(0, 1) == "2") {
        showAppSnackbar("نجاح", "تم حذف الحساب بنجاح");
        await App.prefs.clear();
        // Clear in-memory user and update UI
        user = null;
        update();
        Get.offAll(() => Login());
      } else {
        showAppSnackbar("خطأ", data?['message'] ?? "حدث خطأ", isError: true);
      }
    } catch (e) {
      print(e);
      showAppSnackbar("خطأ", "حدث خطأ. حاول لاحقًا.", isError: true);
    }

    isLoading = false;
    update();
  }

  getAds({bool showError = false}) async {
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
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await _forceLogout();
        return;
      }

      var data = _tryDecodeBody(responseBody);
      if (_isHtmlResponse(responseBody) || data == null) {
        print('HomeController.getAds received HTML or invalid JSON, forcing logout');
        await _forceLogout();
        return;
      }

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 220) {
        print(data?['data'] ?? responseBody);
        banners = (data['data'] as List)
            .map((e) => BannerModel.fromJson(e))
            .toList();
      } else {
        if (showError) {
          showAppSnackbar("خطأ", data?['message'] ?? "حدث خطأ", isError: true);
        }
      }
    } catch (e) {
      print(e);
      if (showError) {
        showAppSnackbar(
          "خطأ",
          "حدث خطأ أثناء الاتصال. حاول لاحقًا.",
          isError: true,
        );
      }
    }
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
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await _forceLogout();
        return;
      }

      var data = _tryDecodeBody(responseBody);
      if (_isHtmlResponse(responseBody) || data == null) {
        print('HomeController.getServices received HTML or invalid JSON, forcing logout');
        await _forceLogout();
        return;
      }
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
       // showAppSnackbar("خطأ", data?['message'] ?? "حدث خطأ", isError: true);
      }
    } catch (e) {
      print(e);
     /* showAppSnackbar(
        "خطأ",
        "حدث خطأ أثناء الاتصال. حاول لاحقًا.",
        isError: true,
      );*/
    }
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
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await _forceLogout();
        return;
      }

      var data = _tryDecodeBody(responseBody);
      if (_isHtmlResponse(responseBody) || data == null) {
        print('HomeController.getContactUs received HTML or invalid JSON, forcing logout');
        await _forceLogout();
        return;
      }
      print(data ?? responseBody);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 220) {
        contactUsModel = ContactUsModel.fromJson(data["data"]);
        print("ContactUs Loaded Successfully");
      } else {
       // showAppSnackbar("خطأ", data?['message'] ?? "حدث خطأ", isError: true);
      }
    } catch (e) {
      print(e);
     /* showAppSnackbar(
        "خطأ",
        "حدث خطأ أثناء الاتصال. حاول لاحقًا.",
        isError: true,
      );*/
    }
  }

  getOffers() async {
    try {
      var headers = {
        'Accept': 'application/json',
        'Accept-Language': 'en',
      };
      var uri = Uri.parse("https://www.salhly.lareenmedco.com/api/offers/get");

      var request = http.Request('GET', uri);
      request.headers.addAll(headers);
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await _forceLogout();
        return;
      }

      var data = _tryDecodeBody(responseBody);

      if (response.statusCode == 200) {
        if (data != null) {
          offers = (data['data'] as List)
              .map((e) => Offer.fromJson(e))
              .toList();
          print("Offers loaded: ${offers.length}");
          update();
        }
      } else {
        print("Error loading offers: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception loading offers: $e");
    }
  }

  getExchangeOffers() async {
    try {
      var headers = {
        'Accept': 'application/json',
        'Accept-Language': 'en',
      };
      var uri = Uri.parse("https://www.salhly.lareenmedco.com/api/offers/get_exchange");

      var request = http.Request('GET', uri);
      request.headers.addAll(headers);
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await _forceLogout();
        return;
      }

      var data = _tryDecodeBody(responseBody);

      if (response.statusCode == 200) {
        if (data != null) {
          exchangeOffers = (data['data'] as List)
              .map((e) => Offer.fromJson(e))
              .toList();
          print("Exchange offers loaded: ${exchangeOffers.length}");
          update();
        }
      } else {
        print("Error loading exchange offers: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception loading exchange offers: $e");
    }
  }

  getAppAppearance() async {
    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Accept': 'application/json',
        'Accept-Language': 'en',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      var uri = Uri.parse('https://www.salhly.lareenmedco.com/api/app-appearance/show');
      var request = http.Request('GET', uri);
      request.headers.addAll(headers);
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await _forceLogout();
        return;
      }

      var data = _tryDecodeBody(responseBody);
      if (_isHtmlResponse(responseBody) || data == null) {
        print('HomeController.getAppAppearance received HTML or invalid JSON, forcing logout');
        await _forceLogout();
        return;
      }

      if (response.statusCode == 200 && data != null && data['data'] != null) {
        final appData = data['data'];
        appTitle = appData['title'] ?? '';
        appTopBackground = appData['top_background'] ?? '';
        appBottomBackground = appData['bottom_background'] ?? '';
        appTabbarBackground = appData['tabbar_background'] ?? '';

        replaceTitle = appData['replace']?['title'] ?? '';
        replaceDesc = appData['replace']?['desc'] ?? '';
        replaceImage = appData['replace']?['image'] ?? '';

        buyTitle = appData['buy']?['title'] ?? '';
        buyDesc = appData['buy']?['desc'] ?? '';
        buyImage = appData['buy']?['image'] ?? '';

        await App.prefs.setString('app_title', appTitle);
        await App.prefs.setString('app_top_background', appTopBackground);
        await App.prefs.setString('app_bottom_background', appBottomBackground);
        await App.prefs.setString('app_tabbar_background', appTabbarBackground);
        await App.prefs.setString('app_replace_title', replaceTitle);
        await App.prefs.setString('app_replace_desc', replaceDesc);
        await App.prefs.setString('app_replace_image', replaceImage);
        await App.prefs.setString('app_buy_title', buyTitle);
        await App.prefs.setString('app_buy_desc', buyDesc);
        await App.prefs.setString('app_buy_image', buyImage);

        update();
      } else {
        print('Error loading app appearance: ${response.statusCode} ${data?['message'] ?? ''}');
      }
    } catch (e) {
      print('Exception loading app appearance: $e');
    }
  }

  getAboutUs() async {
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
      if (_isHtmlResponse(responseBody) || data == null) {
        print('HomeController.getAboutUs received HTML or invalid JSON, forcing logout');
        await _forceLogout();
        return;
      }
      print(data ?? responseBody);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 220) {
        aboutUsModel = AboutUsModel.fromJson(data["data"]);
        print("AboutUs Loaded Successfully");
      } else {
       // showAppSnackbar("خطأ", data?['message'] ?? "حدث خطأ", isError: true);
      }
    } catch (e) {
      print(e);
     /* showAppSnackbar(
        "خطأ",
        "حدث خطأ أثناء الاتصال. حاول لاحقًا.",
        isError: true,
      );*/
    }
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
      var responseBody = await response.stream.bytesToString();
     print(88888);
     print("${AppApi.baseUrl}/user/find");
     print(response.statusCode);
     print(responseBody);
     print(88888);


      var data = _tryDecodeBody(responseBody);
      print(response.statusCode);
      if (response.statusCode == 403 || response.statusCode == 401) {
        await _forceLogout();
        return;
      }

      if (_isHtmlResponse(responseBody) || data == null) {
        print('Received HTML or invalid JSON from user/find, forcing logout');
        await _forceLogout();
        return;
      }

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
     //   showAppSnackbar("خطأ", data?['message'] ?? "حدث خطأ", isError: true);
      }
    } catch (e) {
      print(e);
     /* showAppSnackbar(
        "خطأ",
        "حدث خطأ أثناء الاتصال. حاول لاحقًا.",
        isError: true,
      );*/
    }
  }

  Future<NotificationsResponse?> getNotifications({int page = 1, int perPage = 10, bool reset = true}) async {
    try {
      final response = await NotificationsService().getNotifications(page: page, perPage: perPage);
      if (response != null) {
        if (reset) {
          notifications = response.data;
        } else {
          notifications.addAll(response.data);
        }
        unreadNotificationsCount = response.unreadCount;
        update();
      }
      return response;
    } catch (e) {
      print('Error fetching notifications: $e');
      return null;
    }
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
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 403 || response.statusCode == 401) {
        await _forceLogout();
        return;
      }

      var data = _tryDecodeBody(responseBody);
      if (_isHtmlResponse(responseBody) || data == null) {
        print('HomeController.getPrivacyPolicy received HTML or invalid JSON, forcing logout');
        await _forceLogout();
        return;
      }
      print(data ?? responseBody);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 220) {
        privacyPolicyModel = PrivacyPolicyModel.fromJson(data["data"]);
      } else {
      //  showAppSnackbar("خطأ", data?['message'] ?? "حدث خطأ", isError: true);
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
    initializeHome();
    super.onInit();
  }

  // Initialize all home data - called on page load and refresh
  Future<void> initializeHome({bool force = false}) async {
    if (!force && _hasInitialized) {
      return;
    }
    if (_isInitializing) {
      return;
    }

    _isInitializing = true;
    isLoading = true;
    update();

    try {
      // Call all APIs in parallel
      await Future.wait<void>([
        NotificationServices().getDeviceToken(),
        getAds(),
        getServices(),
        getAboutUs(),
        getAppAppearance(),
        getOffers(),
        getExchangeOffers(),
        getContactUs(),
        getUser(),
        getNotifications(),
      ]);
      _hasInitialized = true;
    } catch (e) {
      print('Error initializing home: $e');
    } finally {
      isLoading = false;
      _isInitializing = false;
      update();
    }
  }
}

