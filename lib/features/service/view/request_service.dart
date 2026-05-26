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
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.white)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue,
                    Colors.blue.withOpacity(0.55),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          GetBuilder<RequestServiceController>(
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
        ],
      ),
    );
  }
}
