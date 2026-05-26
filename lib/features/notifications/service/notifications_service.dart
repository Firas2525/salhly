import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:salhly/app.dart';
import 'package:salhly/core/utils/app_api.dart';
import 'package:salhly/core/utils/ui_utils.dart';
import 'package:salhly/features/auth/view/login.dart';
import 'package:salhly/features/notifications/model/notification.dart';

class NotificationsService {
  Future<NotificationsResponse?> getNotifications({int page = 1, int perPage = 10}) async {
    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Accept': 'application/json',
        'Accept-Language': 'en',
        'Authorization': 'Bearer $token',
      };
      var uri = Uri.parse("${AppApi.baseUrl}/notifications?page=$page&per_page=$perPage");

      var request = http.Request('GET', uri);
      request.headers.addAll(headers);

      var response = await request.send();
      var data = jsonDecode(await response.stream.bytesToString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NotificationsResponse.fromJson(data);
      } else if (response.statusCode == 403) {
        await App.prefs.clear();
        Get.offAll(() => Login());
        return null;
      } else {
        showAppSnackbar("خطأ", data['message'] ?? "حدث خطأ", isError: true);
        return null;
      }
    } catch (e) {
      print(e);
      showAppSnackbar(
        "خطأ",
        "حدث خطأ أثناء الاتصال. حاول لاحقًا.",
        isError: true,
      );
      return null;
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Accept': 'application/json',
        'Accept-Language': 'en',
        'Authorization': 'Bearer $token',
      };
      var uri = Uri.parse("${AppApi.baseUrl}/notifications/$notificationId/read");

      var request = http.Request('POST', uri);
      request.headers.addAll(headers);

      var response = await request.send();
      // بدون معالجة النتيجة، فقط استدعاء API
    } catch (e) {
      print('Error marking notification as read: $e');
      // بدون عرض أخطاء للمستخدم
    }
  }
}