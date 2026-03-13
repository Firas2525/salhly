import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/app.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import 'package:salhly/features/service/controller/service_controller.dart';
import 'package:salhly/features/user/view/update_user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/utils/app_api.dart';
import '../../user/view/update_password.dart';
import '../controller/request_service_controller.dart';

class RequestServiceView extends StatefulWidget {
  const RequestServiceView({super.key});

  @override
  State<RequestServiceView> createState() => _RequestServiceViewState();
}

class _RequestServiceViewState extends State<RequestServiceView> {
  final controller = Get.put(RequestServiceController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.four, AppColors.four.withOpacity(0.6)],
            ),
          ),
        ),
        title: const Text(
          'طلب خدمة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: GetBuilder<RequestServiceController>(
        builder: (controller) {
          return controller.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.four,
                    strokeWidth: 4,
                  ),
                )
              : Container();
        },
      ),
    );
  }
}
