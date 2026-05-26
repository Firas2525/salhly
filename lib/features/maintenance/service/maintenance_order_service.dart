import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:salhly/app.dart';
import 'package:salhly/core/utils/app_api.dart';
import 'package:salhly/features/auth/view/login.dart';
import 'package:salhly/features/maintenance/model/maintenance_order_model.dart';

class MaintenanceOrderService {
  Future<MaintenanceOrderModel?> getMaintenanceOrder(int orderId) async {
    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Accept': 'application/json',
        'Accept-Language': 'en',
        'Authorization': 'Bearer $token',
      };
      var uri = Uri.parse("${AppApi.baseUrl}/order/find_maintenance/$orderId");

      var request = http.Request('GET', uri);
      request.headers.addAll(headers);

      var response = await request.send();
      var data = jsonDecode(await response.stream.bytesToString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['status'] == true) {
          return MaintenanceOrderModel.fromJson(data['data']);
        }
      } else if (response.statusCode == 403) {
        await App.prefs.clear();
        Get.offAll(() => Login());
        return null;
      }
      return null;
    } catch (e) {
      print('Error fetching maintenance order: $e');
      return null;
    }
  }
}
