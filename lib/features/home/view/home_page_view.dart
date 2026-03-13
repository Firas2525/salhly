import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import 'package:salhly/features/service/view/service_view.dart';
import 'package:salhly/features/user/view/update_user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../notifiction_services.dart';
import '../../requests/view/requests_view.dart';
import '../../user/view/update_password.dart';
import 'about_contact_view.dart';
import 'privacy_policy_view.dart';
import 'banner_detail_view.dart';

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
      _showOnboardingTooltip();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure startup tasks run when the page is entered (covers navigation from login/register)
    // Call controller methods explicitly so they run even if controller lifecycle didn't trigger onInit
    // Ensure device token is refreshed when entering the page
    NotificationServices().getDeviceToken();
    controller.getAds();
    controller.getAboutUs();
    controller.getUser();
  }

  void _showOnboardingTooltip() {
    bool isJustLoggedIn = App.prefs.getBool('just_logged_in') ?? false;
    print(isJustLoggedIn);
    if (isJustLoggedIn) {
      // Clear the flag immediately
      App.prefs.setBool('just_logged_in', false);

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
            onFinish: () {},
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
      child: Scaffold(
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
            'الصفحة الرئيسية',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),

        drawer: Drawer(
          child: SafeArea(
            child: GetBuilder<HomeController>(
              builder: (homeCtrl) {
                return Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Header with colored background (vertical layout similar to worker drawer)
                      Container(
                        width: double.infinity,
                        color: AppColors.four,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar: show remote image in a circle; if none, show the
                            // app logo inside a padded container so it's not cropped.
                            Builder(
                              builder: (_) {
                                final hasImage =
                                    homeCtrl.user?.image != null &&
                                    homeCtrl.user!.image!.isNotEmpty;
                                if (hasImage) {
                                  return CircleAvatar(
                                    radius: 34,
                                    backgroundColor: Colors.white,
                                    backgroundImage: CachedNetworkImageProvider(
                                      'https://www.salhly.lareenmedco.com/${homeCtrl.user!.image}'.toString().
                                      contains("storage")?
                                          'https://www.salhly.lareenmedco.com/${homeCtrl.user!.image}':
                                      'https://www.salhly.lareenmedco.com/storage/${homeCtrl.user!.image}',
                                    ),
                                  );
                                }

                                // No user image: show logo in a rounded container without clipping
                                return Container(
                                  height: 68,
                                  width: 68,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.asset(
                                    'assets/images/logo2.png',
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Text(
                              homeCtrl.user?.name ?? 'اسم المستخدم',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // removed email line per request
                            Text(
                              homeCtrl.user?.phone ?? '',
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Menu
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.lock_outline,
                                color: AppColors.four,
                              ),
                              title: Text(
                                'تعديل كلمة المرور',
                                style: GoogleFonts.cairo(
                                  color: AppColors.four,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () => Get.to(() => UpdatePassword()),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.list_alt_rounded,
                                color: AppColors.four,
                              ),
                              title: Text(
                                'الطلبات',
                                style: GoogleFonts.cairo(
                                  color: AppColors.four,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () => Get.to(() => RequestsView()),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.person_outline,
                                color: AppColors.four,
                              ),
                              title: Text(
                                'تعديل الحساب',
                                style: GoogleFonts.cairo(
                                  color: AppColors.four,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () => Get.to(
                                () => UpdateUser(userData: homeCtrl.user),
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.privacy_tip,
                                color: AppColors.four,
                              ),
                              title: Text(
                                'سياسة الخصوصية',
                                style: GoogleFonts.cairo(
                                  color: AppColors.four,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () => Get.to(() => PrivacyPolicyView()),
                            ),
                            const Divider(),
                            ListTile(
                              leading: Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              title: Text(
                                'حذف الحساب',
                                style: GoogleFonts.cairo(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () {
                                final homeCtrl = Get.find<HomeController>();
                                showConfirmDialog(
                                  title: 'حذف الحساب',
                                  middleText:
                                      'هل انت متأكد انك تريد حذف الحساب',
                                  onConfirm: () => homeCtrl.deleteAccount(),
                                  onCancel: () {},
                                  confirmText: 'نعم',
                                  cancelText: 'لا',
                                );
                              },
                            ),

                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  final homeCtrl = Get.find<HomeController>();
                                  showConfirmDialog(
                                    title: 'تسجيل خروج',
                                    middleText:
                                        'هل انت متأكد تسجيل خروجك من الحساب',
                                    onConfirm: () => homeCtrl.logout(),
                                    onCancel: () {},
                                    confirmText: 'نعم',
                                    cancelText: 'لا',
                                  );
                                },
                                icon: const Icon(
                                  Icons.logout_outlined,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'تسجيل خروج',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),
                            Center(
                              child: Text(
                                'نسخة التطبيق 1.0.0',
                                style: GoogleFonts.cairo(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        body: HomeViewBody(logoKey: logoKey),
      ),
    );
  }
}

class HomeViewBody extends StatefulWidget {
  final GlobalKey<State> logoKey;

  const HomeViewBody({super.key, required this.logoKey});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  late GlobalKey<State> logoKey;
  PageController pagecontroller = PageController();
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    logoKey = widget.logoKey;
    pagecontroller = PageController();

    // start auto-scroll for banners every 5 seconds
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      try {
        final homeCtrl = Get.find<HomeController>();
        final count = homeCtrl.banners.length;
        if (count == 0) return;
        if (!pagecontroller.hasClients) return;

        // calculate next page (wrap to 0)
        final currentPage = (pagecontroller.page ?? pagecontroller.initialPage)
            .round();
        var nextPage = currentPage + 1;
        if (nextPage >= count) nextPage = 0;

        pagecontroller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        // ignore if controller not found or other errors during startup
      }
    });
  }

  void _resumeAutoScroll() {
    // Cancel existing timer if any
    _autoScrollTimer?.cancel();

    // Resume auto-scroll for banners every 5 seconds
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      try {
        final homeCtrl = Get.find<HomeController>();
        final count = homeCtrl.banners.length;
        if (count == 0) return;
        if (!pagecontroller.hasClients) return;

        // calculate next page (wrap to 0)
        final currentPage = (pagecontroller.page ?? pagecontroller.initialPage)
            .round();
        var nextPage = currentPage + 1;
        if (nextPage >= count) nextPage = 0;

        pagecontroller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        // ignore if controller not found or other errors during startup
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    pagecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.four,
      backgroundColor: Colors.white,
      onRefresh: () async {
        try {
          final homeCtrl = Get.find<HomeController>();
          // Call the same startup methods used in onInit
          await homeCtrl.getAds();
          await homeCtrl.getAboutUs();
        } catch (e) {
          // ignore errors, Snackbar shown inside controller methods
        }
      },
      child: GetBuilder<HomeController>(
        builder: (controller) {
          return controller.isLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // header skeleton
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 140,
                              height: 22,
                              color: Colors.white,
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // banner skeleton
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // services title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 20,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // services grid skeleton (3 columns)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(3, (i) {
                            return Column(
                              children: [
                                Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 64) /
                                      3,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 60,
                                  height: 12,
                                  color: Colors.white,
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // services grid skeleton (3 columns)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(3, (i) {
                            return Column(
                              children: [
                                Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 64) /
                                      3,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 60,
                                  height: 12,
                                  color: Colors.white,
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // contact title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Container(
                              width: 120,
                              height: 20,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // contact icons skeleton
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(
                            4,
                            (_) => Column(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 40,
                                  height: 10,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    HeaderHomePage(logoKey: logoKey),
                    SizedBox(
                      height: 250,
                      width: 1000,
                      child: PageView.builder(
                        controller: pagecontroller,
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.banners.length,
                        itemBuilder: (context, index) {
                          final banner = controller.banners[index];
                          return GestureDetector(
                            onTap: () {
                              final desc = banner.description ?? '';
                              if (desc.isNotEmpty) {
                                Get.to(() => BannerDetailView(banner: banner));
                              }
                            },
                            onLongPress: () {
                              _autoScrollTimer?.cancel();
                            },
                            onLongPressUp: () {
                              _resumeAutoScroll();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                  image: banner.image != ""
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            "https://www.salhly.lareenmedco.com/storage/${banner.image}",
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Container(
                                    height: 250,
                                    width: 1000,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                    ),
                                    child: banner.image == ""
                                        ? SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 100,
                                                  width: 100,
                                                  child: Image.asset(
                                                    'assets/images/logo2.png',
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.7,
                                                    height:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.5,
                                                    child: Text(
                                                      banner.title,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 17,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 20),

                    // ---------- خدمات الصيانة ----------
                    Row(
                      children: [
                        SizedBox(width: 20),
                        Text(
                          'خدمات ',
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.four,
                          ),
                        ),
                        Text(
                          'الصيانة',
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.four,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Services grid or a loading skeleton when services list is empty
                    controller.services.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(3, (i) {
                                  final width =
                                      (MediaQuery.of(context).size.width - 64) /
                                      3;
                                  return Column(
                                    children: [
                                      Container(
                                        width: width,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 60,
                                        height: 12,
                                        color: Colors.white,
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            shrinkWrap: true,
                            // مهم جداً
                            physics: NeverScrollableScrollPhysics(),
                            // حتى لا يحصل Scroll داخل Scroll
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                  childAspectRatio: 0.9, // يحافظ على الشكل
                                ),
                            itemCount: controller.services.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => ServiceView(),
                                    arguments: {
                                      "serviceId":
                                          controller.services[index].id,
                                    },
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            "https://www.salhly.lareenmedco.com/storage/${controller.services[index].image}",
                                        height: 80,
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) {
                                          return Container(
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade100,
                                              child: Container(
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        },
                                        errorWidget: (context, url, error) {
                                          return Container(
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.error_outline,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      controller.services[index].title,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.four,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                    SizedBox(height: 30),

                    // ----------------- معلومات التواصل -----------------
                    Row(
                      children: [
                        SizedBox(width: 20),
                        Text(
                          'معلومات ',
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.four,
                          ),
                        ),
                        Text(
                          'التواصل',
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.four,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildContactIconCircular(
                                icon: Icons.phone,
                                backgroundColor: Color(0xFF2196F3),
                                label: 'اتصال',
                                onTap: () => launchUrl(
                                  Uri.parse(
                                    "tel:${controller.contactUsModel?.phoneNumber}",
                                  ),
                                ),
                                size: 48,
                              ),

                              // ---- واتساب ----
                              GestureDetector(
                                onTap: () {
                                  final wa =
                                      controller
                                          .contactUsModel
                                          ?.whatsAppNumber ??
                                      "";
                                  if (wa.isNotEmpty) {
                                    launchUrl(Uri.parse('https://wa.me/$wa'));
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 48,
                                      width: 48,
                                      child: Image.asset(
                                        'assets/images/whats.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'واتساب',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.four,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  final fb =
                                      controller.contactUsModel?.facebook ?? "";
                                  if (fb.isNotEmpty) launchUrl(Uri.parse(fb));
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 48,
                                      width: 48,
                                      child: Image.asset(
                                        'assets/images/face.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'فيسبوك',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.four,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // ---- فيسبوك ----

                              // ---- إنستغرام ----
                              GestureDetector(
                                onTap: () {
                                  final ig =
                                      controller.contactUsModel?.instagram ??
                                      "";
                                  if (ig.isNotEmpty) launchUrl(Uri.parse(ig));
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 48,
                                      width: 48,
                                      child: Image.asset(
                                        'assets/images/insta.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'انستغرام',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.four,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildContactIconCircular(
                                icon: Icons.web,
                                backgroundColor: Color(0xFF2196F3),
                                label: 'الموقع',
                                onTap: () => launchUrl(
                                  Uri.parse(
                                    "${controller.contactUsModel?.websiteLink}",
                                  ),
                                ),
                                size: 48,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                    Container(
                      alignment: Alignment.bottomCenter,
                      margin: const EdgeInsets.only(right: 10, top: 5),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.098,
                      decoration: const BoxDecoration(
                        //color: Color.fromARGB(255, 190, 226, 255),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              " للتواصل معنا : ${controller.contactUsModel?.companyNumber == null ? "" : controller.contactUsModel?.companyNumber}",
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.four,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Text(
                              controller.contactUsModel?.gmail == null
                                  ? ""
                                  : controller.contactUsModel!.gmail.toString(),
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.four,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                );
        },
      ),
    );
  }
}

// ------------------- Widgets أسفل الصفحة -------------------

Widget _buildContactIconCircular({
  dynamic icon,
  String? imageUrl,
  required Color backgroundColor,
  required String label,
  required VoidCallback onTap,
  bool isFontAwesome = false,
  bool useImage = false,
  double size = 60,
  bool fullImage = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.3),
            gradient: LinearGradient(
              colors: [backgroundColor, backgroundColor.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.25),
                blurRadius: 12,
                offset: Offset(0, 5),
                spreadRadius: 1,
              ),
            ],
          ),
          child: useImage && imageUrl != null
              ? fullImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(size * 0.3),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.link,
                              color: Colors.white,
                              size: size * 0.35,
                            );
                          },
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(size * 0.15),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.link,
                              color: Colors.white,
                              size: size * 0.35,
                            );
                          },
                        ),
                      )
              : Center(
                  child: isFontAwesome
                      ? FaIcon(icon, color: Colors.white, size: size * 0.42)
                      : Icon(icon, color: Colors.white, size: size * 0.45),
                ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.four,
          ),
        ),
      ],
    ),
  );
}

enum IconType { material, fa }

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
          child: Text(
            " الاعلانات  ",
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.four,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          width: 100,
          key: this.logoKey,
          child: GestureDetector(
            onTap: () => Get.to(() => const AboutContactView()),
            child: const AnimatedLogo(assetPath: 'assets/images/logo2.png'),
          ),
        ),
      ],
    );
  }
}

class AnimatedLogo extends StatefulWidget {
  final String assetPath;

  const AnimatedLogo({super.key, required this.assetPath});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final Animation<double> _rotationAnim;
  late final AnimationController _gleamController;
  late final AnimationController _scaleController;
  Timer? _gleamTimer;
  bool _rotationStopped = false;
  final Duration _pauseDuration = const Duration(seconds: 6);

  @override
  void initState() {
    super.initState();

    // rotation: slow continuous spin
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _rotationAnim = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
    // start a single-cycle rotation loop that pauses after each full spin
    _startRotationCycle();

    // subtle scale (breathing) effect
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _scaleController.repeat(reverse: true);

    // gleam: controls position of shining gradient (0.0 -> 1.0)
    _gleamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // trigger periodic gleam every 4 seconds
    _gleamTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        _gleamController
            .forward(from: 0)
            .then((_) => _gleamController.reverse());
      }
    });
  }

  void _startRotationCycle() async {
    // Runs one forward rotation, triggers a gleam, pauses, then repeats until disposed
    if (!mounted) return;
    _rotationStopped = false;
    while (mounted && !_rotationStopped) {
      try {
        await _rotationController.forward(from: 0.0);

        // on cycle end, trigger a short gleam
        if (mounted) {
          _gleamController
              .forward(from: 0)
              .then((_) => _gleamController.reverse());
        }

        // (stars removed)

        // pause between cycles
        await Future.delayed(_pauseDuration);
      } catch (e) {
        break;
      }
    }
  }

  // stars removed

  @override
  void dispose() {
    _rotationStopped = true;
    _rotationController.stop();
    _rotationController.dispose();
    _scaleController.dispose();
    _gleamController.dispose();
    _gleamTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationController,
        _scaleController,
        _gleamController,
      ]),
      builder: (context, child) {
        final gleamValue = _gleamController.value; // 0.0..1.0
        return Transform.rotate(
          angle: _rotationAnim.value,
          child: Transform.scale(
            scale:
                1.0 +
                (_scaleController.value - 0.5) * 0.04, // small +/-2% scale
            child: Stack(
              children: [
                // Logo image
                Positioned.fill(child: child!),

                // Gleam shader mask overlay using ShaderMask so it blends with the image
                if (gleamValue > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Opacity(
                        // smoother opacity curve using sine for fade-in/out
                        opacity: (math.sin(gleamValue * math.pi) * 0.9).clamp(
                          0.0,
                          0.95,
                        ),
                        child: ShaderMask(
                          blendMode: BlendMode.lighten,
                          shaderCallback: (rect) {
                            // move the narrow white band from left to right
                            final start =
                                -0.6 +
                                gleamValue * 2.2; // wider range for nicer sweep
                            return LinearGradient(
                              begin: Alignment(start, -0.3),
                              end: Alignment(start + 0.5, 0.3),
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.9),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ).createShader(rect);
                          },
                          child: Container(
                            color: Colors.white.withOpacity(0.0),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Image.asset(widget.assetPath, fit: BoxFit.contain),
      ),
    );
  }
}
