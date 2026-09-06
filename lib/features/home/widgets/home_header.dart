import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/core/utils/assets_manager.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import 'package:salhly/features/home/view/about_contact_view.dart';
import 'package:salhly/features/notifications/view/notifications_page.dart';

import 'package:salhly/features/home/widgets/animated_logo.dart';

class HeaderHomePage extends StatelessWidget {
  final GlobalKey<State> logoKey;

  const HeaderHomePage({super.key, required this.logoKey});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 90,
            width: 120,
            key: logoKey,
            child: GestureDetector(
              onTap: () => Get.to(() => const AboutContactView()),
              child: AnimatedLogo(assetPath: ImgAsset.whiteLogo),
            ),
          ),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Get.to(() => const NotificationsPage()),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GetBuilder<HomeController>(
                    builder: (homeCtrl) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 24,
                          ),
                          if (homeCtrl.unreadNotificationsCount > 0)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    homeCtrl.unreadNotificationsCount > 99
                                        ? '99+'
                                        : homeCtrl.unreadNotificationsCount
                                              .toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 10),
              child: Builder(
                builder: (context) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
