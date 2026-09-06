import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/core/utils/assets_manager.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import 'package:salhly/core/utils/phone_utils.dart';
import 'package:salhly/features/home/sell_requests/sell_requests_view.dart';
import 'package:salhly/features/home/exchange_requests/exchange_requests_view.dart';
import 'package:salhly/features/home/exchange_pieces/exchange_piece_view.dart';
import 'package:salhly/features/home/view/all_offers_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../notifiction_services.dart';
import '../../requests/view/requests_view.dart';
import '../../service/view/service_view.dart';
import '../../user/view/update_password.dart';
import '../../user/view/update_user.dart';
import 'about_contact_view.dart';
import 'privacy_policy_view.dart';
import 'banner_detail_view.dart';
import 'offer_detail_view.dart';
import 'sell_piece_view.dart';
import '../../notifications/view/notifications_page.dart';
import '../widgets/animated_logo.dart';
import '../widgets/contact_icon_widget.dart';
import '../widgets/home_header.dart';
import '../widgets/offer_card_widget_buttons.dart';
import '../widgets/home_view_body.dart';
import '../widgets/home_drawer.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  final controller = Get.put(HomeController());
  final GlobalKey<State> logoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeHome();
      _showOnboardingTooltip();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _showOnboardingTooltip() {
    bool isJustLoggedIn = App.prefs.getBool('just_logged_in') ?? false;
    bool shouldShowLogoTooltip = App.prefs.getBool('show_logo_tooltip') ?? true;
    print(
      'just_logged_in=$isJustLoggedIn show_logo_tooltip=$shouldShowLogoTooltip',
    );
    if (isJustLoggedIn || shouldShowLogoTooltip) {
      if (isJustLoggedIn) {
        App.prefs.setBool('just_logged_in', false);
      }

      Future.delayed(Duration(milliseconds: 800), () {
        if (mounted) {
          List<TargetFocus> targets = [
            TargetFocus(
              identify: 'logo',
              keyTarget: logoKey,
              alignSkip: Alignment.topLeft,
              enableOverlayTab: true,
              shape: ShapeLightFocus.Circle,
              contents: [
                TargetContent(
                  align: ContentAlign.bottom,
                  builder: (context, controller) {
                    return Container(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'يمكنك الضغط هنا',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'لمعرفة معلومات عن التطبيق',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              App.prefs.setBool('show_logo_tooltip', false);
                              controller.next();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'فهمت',
                              style: GoogleFonts.cairo(
                                color: AppColors.four,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ];
          TutorialCoachMark(
            targets: targets,
            colorShadow: Colors.black87,
            hideSkip: false,
            onFinish: () {
              App.prefs.setBool('show_logo_tooltip', false);
            },
            onClickTarget: (target) {},
            onSkip: () {
              return true;
            },
          ).show(context: context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // الخروج من التطبيق عند الضغط على زر الرجوع
        // ننادي SystemNavigator.pop فقط ونمنع إطار فلاتر من عمل pop للمسار
        SystemNavigator.pop();
        return false;
      },
      child: GetBuilder<HomeController>(
        builder: (homeCtrl) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Positioned.fill(child: Container(color: Colors.white)),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Stack(
                    children: [
                      /* Container(
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
                    ),*/
                      if (homeCtrl.appTopBackground.isNotEmpty)
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: homeCtrl.appTopBackground,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) =>
                                Container(color: Colors.blue.withOpacity(0.2)),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.blue.withOpacity(0.2),
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.blue,
                              Colors.blue.withOpacity(0.25),
                              Colors.white,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (homeCtrl.appBottomBackground.isNotEmpty)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.35,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: CachedNetworkImage(
                      imageUrl: homeCtrl.appBottomBackground,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) =>
                          Container(color: Colors.white),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.white,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                HomeViewBody(logoKey: logoKey),
              ],
            ),
            /*      appBar: AppBar(
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
            'الصفحة الرئيسية',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
*/
            drawer: const HomeDrawer(),
          );
        },
      ),
    );
  }
}
