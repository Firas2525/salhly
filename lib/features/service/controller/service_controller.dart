import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app.dart';
import '../../../core/utils/app_api.dart';
import '../../../core/utils/ui_utils.dart';
import '../../auth/view/login.dart';
import '../model/service_model.dart';

class ServiceController extends GetxController {
  // Loading state
  bool isLoading = false;

  // Form controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Service IDs
  late int serviceId;
  int? selectedSubServiceId;

  // Subservices list
  List<SubServiceModel> subServices = [];

  // Image
  File? imageFile;



  // Fetch sub-services for a service id
  Future<void> getService(int id) async {
    isLoading = true;
    update();

    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };
      var uri = Uri.parse("${AppApi.baseUrl}/service/get_SubService?service_id=$id");

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
      final List<dynamic> dataList = data?['data'] ?? [];

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 210) {
        subServices = dataList.map((e) => SubServiceModel.fromJson(e)).toList();
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
  serviceId = Get.arguments['serviceId'];
        getService(serviceId);

    super.onInit();
  }


}
