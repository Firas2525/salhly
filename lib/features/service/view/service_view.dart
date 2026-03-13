import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:salhly/features/service/views/service_order_page.dart';
import 'package:salhly/features/user/view/update_user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/utils/app_api.dart';
import '../../user/view/update_password.dart';

class ServiceView extends StatefulWidget {
  const ServiceView({super.key});

  @override
  State<ServiceView> createState() => _ServiceViewState();
}

class _ServiceViewState extends State<ServiceView> {
  final controller = Get.put(ServiceController());
  String _search = '';

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
          'أقسام الخدمة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: GetBuilder<ServiceController>(
        builder: (controller) {
          final items = _search.trim().isEmpty
              ? controller.subServices
              : controller.subServices
                    .where(
                      (s) =>
                          s.title.toLowerCase().contains(_search.toLowerCase()),
                    )
                    .toList();

          return controller.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.four,
                    strokeWidth: 4,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search / header
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                onChanged: (v) => setState(() => _search = v),
                                decoration: InputDecoration(
                                  hintText: 'ابحث عن خدمة...',
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: AppColors.four,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ) /*
                          const SizedBox(width: 12),
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(color: AppColors.four, borderRadius: BorderRadius.circular(12)),
                            child: IconButton(
                              onPressed: () {
                                // quick refresh
                                controller.getService(controller.serviceId);
                              },
                              icon: const Icon(Icons.refresh, color: Colors.white),
                            ),
                          )*/,
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          'أقسام الخدمة',
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      // Grid of service cards
                      Expanded(
                        child: items.isEmpty
                            ? Center(
                                child: Text(
                                  'لم يتم العثور على خدمات',
                                  style: GoogleFonts.cairo(),
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.only(top: 20),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 17,
                                      childAspectRatio: 1.8,
                                    ),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final s = items[index];
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () {
                                        Get.to(
                                          () => ServiceOrderPage(
                                            serviceId: controller.serviceId,
                                            subServiceId: s.id,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 8,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              // background image
                                              if (s.image.isNotEmpty)
                                                Image(
                                                  image: CachedNetworkImageProvider(
                                                    'https://www.salhly.lareenmedco.com/storage/${s.image}',
                                                  ),

                                                  fit: BoxFit.cover,
                                                )
                                              else
                                                Container(
                                                  color: Colors.grey.shade200,
                                                ),

                                              // bottom gradient
                                              Positioned(
                                                left: 0,
                                                right: 0,
                                                bottom: 0,
                                                height: 72,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.black
                                                            .withOpacity(0.6),
                                                        Colors.transparent,
                                                      ],
                                                      begin: Alignment
                                                          .bottomCenter,
                                                      end: Alignment.topCenter,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // title
                                              Positioned(
                                                left: 12,
                                                bottom: 12,
                                                right: 12,
                                                child: Text(
                                                  s.title,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.cairo(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
