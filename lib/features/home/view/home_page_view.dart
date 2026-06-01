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
            drawer: Drawer(
              child: SafeArea(
                child: GetBuilder<HomeController>(
                  builder: (homeCtrl) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade300, Colors.blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Header with colored background (vertical layout similar to worker drawer)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade300, Colors.blue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            width: double.infinity,
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
                                          'https://www.salhly.lareenmedco.com/${homeCtrl.user!.image}'
                                                  .toString()
                                                  .contains("storage")
                                              ? 'https://www.salhly.lareenmedco.com/${homeCtrl.user!.image}'
                                              : 'https://www.salhly.lareenmedco.com/storage/${homeCtrl.user!.image}',
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
                            child: Container(
                              color: Colors.white,
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
                                      Icons.sell,
                                      color: AppColors.four,
                                    ),
                                    title: Text(
                                      'طلبات البيع',
                                      style: GoogleFonts.cairo(
                                        color: AppColors.four,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    onTap: () =>
                                        Get.to(() => SellRequestsView()),
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.swap_horiz,
                                      color: AppColors.four,
                                    ),
                                    title: Text(
                                      'طلبات الاستبدال',
                                      style: GoogleFonts.cairo(
                                        color: AppColors.four,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    onTap: () =>
                                        Get.to(() => ExchangeRequestsView()),
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
                                    onTap: () =>
                                        Get.to(() => PrivacyPolicyView()),
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
                                      final homeCtrl =
                                          Get.find<HomeController>();
                                      showConfirmDialog(
                                        title: 'حذف الحساب',
                                        middleText:
                                            'هل انت متأكد انك تريد حذف الحساب',
                                        onConfirm: () =>
                                            homeCtrl.deleteAccount(),
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
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        final homeCtrl =
                                            Get.find<HomeController>();
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
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
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

class _HomeViewBodyState extends State<HomeViewBody>
    with TickerProviderStateMixin {
  late GlobalKey<State> logoKey;
  late TabController _tabController;
  late PageController _bannerController;
  late TabController _sellExchangeTabController;
  int _currentBannerPage = 0;

  @override
  void initState() {
    super.initState();
    logoKey = widget.logoKey;
    _tabController = TabController(length: 3, vsync: this);
    _sellExchangeTabController = TabController(length: 2, vsync: this);
    _bannerController = PageController();
    _bannerController.addListener(() {
      setState(() {
        _currentBannerPage = _bannerController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sellExchangeTabController.dispose();
    _bannerController.dispose();
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
          // Force refresh all API data even if already initialized
          await homeCtrl.initializeHome(force: true);
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
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header skeleton
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: SizedBox(
                                height: 100,
                                width: 120,
                                child: GestureDetector(
                                  child: AnimatedLogo(
                                    assetPath: ImgAsset.whiteLogo,
                                  ),
                                ),
                              ),
                            ),

                            /*Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            " صلحلي  ",
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),*/
                            Row(
                              children: [
                                Builder(
                                  builder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 0.0),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () => Get.to(
                                          () => const NotificationsPage(),
                                        ),
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: GetBuilder<HomeController>(
                                            builder: (homeCtrl) {
                                              return Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.notifications,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Builder(
                                  builder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 10,
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () =>
                                            Scaffold.of(context).openDrawer(),
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.menu,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                width: 160,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        // Ads skeleton
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: 2,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(left: 14),
                                width: 276,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: 1,
                                ),
                            itemCount: 9,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.four.withOpacity(0.12),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      HeaderHomePage(logoKey: logoKey),
                      SizedBox(height: 5),
                      // نص مع أيقونة للإعلانات
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(Icons.campaign, color: Colors.white, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              'إعلاناتنا المميزة',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      // تغيير من PageView إلى ListView عمودي مع تصغير الحجم
                      SizedBox(
                        height: 180, // تصغير من 250 إلى 200
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.banners.length,
                          itemBuilder: (context, index) {
                            final banner = controller.banners[index];
                            return GestureDetector(
                              onTap: () {
                                final desc = banner.description ?? '';
                                if (desc.isNotEmpty) {
                                  Get.to(
                                    () => BannerDetailView(banner: banner),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 8.0,
                                ),
                                child: Container(
                                  height: 160, // تصغير الارتفاع
                                  width: 284.44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
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
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.only(
                                        left: 5,
                                        right: 5,
                                      ),
                                      child: banner.image == ""
                                          ? Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 60,
                                                    width: 60,
                                                    child: Image.asset(
                                                      'assets/images/logo2.png',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    banner.title,
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 14,
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
                      // TabBar for Services
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        // أزلنا الـ padding من الحاوية الخارجية ليلتصق التاب بالأطراف
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.four.withOpacity(0.12),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        // ClipRRect لضمان أن الـ Indicator لا يخرج عن زوايا الحاوية الخارجية
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: false,
                            dividerColor: Colors.transparent,

                            // المؤشر الآن يملأ المساحة بالكامل
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              // جعلناه 0 لأن ClipRRect سيتكفل بالحواف
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade300, Colors.blue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),

                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorPadding: EdgeInsets.zero,

                            // تأكيد إلغاء أي مسافات للمؤشر
                            labelColor: Colors.white,
                            unselectedLabelColor: AppColors.four,
                            labelPadding: EdgeInsets.zero,

                            // جعل النصوص تتوسط المساحة تماماً
                            labelStyle: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            unselectedLabelStyle: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),

                            overlayColor: MaterialStateProperty.all(
                              Colors.transparent,
                            ),

                            tabs: [
                              _buildCleanTab(
                                Icons.build_circle_rounded,
                                'الصيانة',
                              ),
                              _buildCleanTab(Icons.sync_alt, 'بيع واستبدال'),
                              _buildCleanTab(
                                Icons.local_offer_rounded,
                                'العروض',
                              ),
                            ],
                          ),
                        ),
                      ),

                      // TabBarView with bounded height using SizedBox
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 440,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Tab 1: Services Grid with Contact Section
                            Column(
                              children: [
                                Expanded(
                                  child: controller.services.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                          ),
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                Colors.grey.shade100,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: List.generate(3, (i) {
                                                final width =
                                                    (MediaQuery.of(
                                                          context,
                                                        ).size.width -
                                                        64) /
                                                    3;
                                                return Column(
                                                  children: [
                                                    Container(
                                                      width: width,
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
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
                                        ) // قمت بفصل الشيمر في دالة بالأسفل للترتيب
                                      : CustomScrollView(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          slivers: [
                                            // 1. مسافة بادئة علوية (اختياري)

                                            // 2. شبكة العناصر (الغريد فيو)
                                            SliverPadding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                  ),
                                              sliver: SliverGrid(
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                      mainAxisSpacing: 15,
                                                      crossAxisSpacing: 15,
                                                      childAspectRatio: 1,
                                                    ),
                                                delegate: SliverChildBuilderDelegate(
                                                  (context, index) {
                                                    final service = controller
                                                        .services[index];
                                                    return GestureDetector(
                                                      onTap: () {
                                                        Get.to(
                                                          () => ServiceView(),
                                                          arguments: {
                                                            "serviceId": controller
                                                                .services[index]
                                                                .id,
                                                          },
                                                        );
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                          border: Border.all(
                                                            color: AppColors
                                                                .four
                                                                .withOpacity(
                                                                  0.12,
                                                                ),
                                                            width: 1,
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                    0.06,
                                                                  ),
                                                              blurRadius: 10,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    4,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              child: CachedNetworkImage(
                                                                imageUrl:
                                                                    "https://www.salhly.lareenmedco.com/storage/${controller.services[index].image}",
                                                                height: 50,
                                                                fit: BoxFit
                                                                    .contain,
                                                                placeholder: (context, url) {
                                                                  return Container(
                                                                    height: 60,
                                                                    decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade200,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                    child: Shimmer.fromColors(
                                                                      baseColor: Colors
                                                                          .grey
                                                                          .shade300,
                                                                      highlightColor: Colors
                                                                          .grey
                                                                          .shade100,
                                                                      child: Container(
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                errorWidget:
                                                                    (
                                                                      context,
                                                                      url,
                                                                      error,
                                                                    ) {
                                                                      return Container(
                                                                        height:
                                                                            60,
                                                                        decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200,
                                                                          borderRadius: BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                        ),
                                                                        child: Center(
                                                                          child: Icon(
                                                                            Icons.error_outline,
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        4,
                                                                  ),
                                                              child: Text(
                                                                controller
                                                                    .services[index]
                                                                    .title,
                                                                style: GoogleFonts.cairo(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      AppColors
                                                                          .four,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ); // عنصر الخدمة الخاص بك
                                                  },
                                                  childCount: controller
                                                      .services
                                                      .length,
                                                ),
                                              ),
                                            ),

                                            // 3. العنصر الذي تريده في النهاية (الـ Row)
                                            SliverToBoxAdapter(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 30,
                                                      horizontal: 20,
                                                    ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                          },
                                                          child: Icon(
                                                            Icons.phone_android,
                                                            color: Colors.blue,
                                                            size: 28,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(
                                                          'معلومات التواصل',
                                                          style:
                                                              GoogleFonts.cairo(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 30),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              _buildContactIconCircular(
                                                                icon:
                                                                    Icons.phone,
                                                                backgroundColor:
                                                                    const Color(
                                                                      0xFF2196F3,
                                                                    ),
                                                                label: 'اتصال',
                                                                onTap: () {
                                                                  final phone =
                                                                      controller
                                                                          .contactUsModel
                                                                          ?.phoneNumber;
                                                                  if (phone !=
                                                                          null &&
                                                                      phone
                                                                          .isNotEmpty) {
                                                                    dialPhoneNumber(
                                                                      phone,
                                                                    );
                                                                  }
                                                                },
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
                                                                  if (wa
                                                                      .isNotEmpty) {
                                                                    launchUrl(
                                                                      Uri.parse(
                                                                        'https://wa.me/$wa',
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      height:
                                                                          48,
                                                                      width: 48,
                                                                      child: Image.asset(
                                                                        'assets/images/whats.png',
                                                                        fit: BoxFit
                                                                            .contain,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Text(
                                                                      'واتساب',
                                                                      style: GoogleFonts.cairo(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: AppColors
                                                                            .four,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),

                                                              GestureDetector(
                                                                onTap: () {
                                                                  final fb =
                                                                      controller
                                                                          .contactUsModel
                                                                          ?.facebook ??
                                                                      "";
                                                                  if (fb
                                                                      .isNotEmpty) {
                                                                    launchUrl(
                                                                      Uri.parse(
                                                                        fb,
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      height:
                                                                          48,
                                                                      width: 48,
                                                                      child: Image.asset(
                                                                        'assets/images/face.png',
                                                                        fit: BoxFit
                                                                            .contain,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Text(
                                                                      'فيسبوك',
                                                                      style: GoogleFonts.cairo(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: AppColors
                                                                            .four,
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
                                                                      controller
                                                                          .contactUsModel
                                                                          ?.instagram ??
                                                                      "";
                                                                  if (ig
                                                                      .isNotEmpty) {
                                                                    launchUrl(
                                                                      Uri.parse(
                                                                        ig,
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      height:
                                                                          48,
                                                                      width: 48,
                                                                      child: Image.asset(
                                                                        'assets/images/insta.png',
                                                                        fit: BoxFit
                                                                            .contain,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Text(
                                                                      'انستغرام',
                                                                      style: GoogleFonts.cairo(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: AppColors
                                                                            .four,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              _buildContactIconCircular(
                                                                icon: Icons.web,
                                                                backgroundColor:
                                                                    const Color(
                                                                      0xFF2196F3,
                                                                    ),
                                                                label: 'الموقع',
                                                                onTap: () =>
                                                                    launchUrl(
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
                                                    const SizedBox(height: 50),
                                                    Container(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      margin:
                                                          const EdgeInsets.only(
                                                            right: 10,
                                                            top: 5,
                                                          ),
                                                      width: MediaQuery.of(
                                                        context,
                                                      ).size.width,
                                                      height:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.height *
                                                          0.098,
                                                      decoration:
                                                          const BoxDecoration(
                                                            //color: Color.fromARGB(255, 190, 226, 255),
                                                          ),
                                                      child: Center(
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              " ${controller.contactUsModel?.contact == null ? "للتواصل معنا" : controller.contactUsModel?.contact} " +
                                                                  " ${controller.contactUsModel?.companyNumber == null ? "" : controller.contactUsModel?.companyNumber}",
                                                              style: GoogleFonts.cairo(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppColors
                                                                    .four,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  MediaQuery.of(
                                                                        context,
                                                                      )
                                                                      .size
                                                                      .height *
                                                                  0.01,
                                                            ),
                                                            Text(
                                                              controller
                                                                          .contactUsModel
                                                                          ?.gmail ==
                                                                      null
                                                                  ? ""
                                                                  : controller
                                                                        .contactUsModel!
                                                                        .gmail
                                                                        .toString(),
                                                              style: GoogleFonts.cairo(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppColors
                                                                    .four,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                            // Tab 2: بيع واستبدال
                            ListView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => const SellPieceView());
                                  },

                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                          child: controller.buyImage.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: controller.buyImage,

                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                        color: Colors.blue
                                                            .withOpacity(0.2),
                                                      ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => Image.asset(
                                                        'assets/images/19.jpg',
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                      ),
                                                )
                                              : Image.asset(
                                                  'assets/images/19.jpg',
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue.withOpacity(0.2),
                                                Colors.blue,
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 20),
                                            GestureDetector(
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                  right: 15,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.3),
                                                    width: 0.8,
                                                  ),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.white.withOpacity(
                                                        0.1,
                                                      ),
                                                      Colors.white.withOpacity(
                                                        0.2,
                                                      ),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  child: BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                      sigmaX: 10,
                                                      sigmaY: 10,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 7,
                                                          ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .monetization_on,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                          SizedBox(width: 5),
                                                          Text(
                                                            controller
                                                                    .buyTitle
                                                                    .isNotEmpty
                                                                ? controller
                                                                      .buyTitle
                                                                : "بيعنا قطعتك",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                              ),
                                              child: Text(
                                                controller.buyDesc.isNotEmpty
                                                    ? controller.buyDesc
                                                    : "نشتري منك بأفضل الأسعار",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),

                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => const ExchangePieceView());
                                  },

                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                          child:
                                              controller.replaceImage.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl:
                                                      controller.replaceImage,

                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                        color: Colors.blue
                                                            .withOpacity(0.2),
                                                      ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => Image.asset(
                                                        'assets/images/11.jpg',
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                      ),
                                                )
                                              : Image.asset(
                                                  'assets/images/11.jpg',
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue.withOpacity(0.2),
                                                Colors.blue,
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 20),
                                            Container(
                                              margin: EdgeInsets.only(
                                                right: 15,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  width: 0.8,
                                                ),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white.withOpacity(
                                                      0.1,
                                                    ),
                                                    Colors.white.withOpacity(
                                                      0.2,
                                                    ),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                    sigmaX: 10,
                                                    sigmaY: 10,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 7,
                                                        ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.recycling,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          controller
                                                                  .replaceTitle
                                                                  .isNotEmpty
                                                              ? controller
                                                                    .replaceTitle
                                                              : "استبدل قطعتك",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                              ),
                                              child: Text(
                                                controller
                                                        .replaceDesc
                                                        .isNotEmpty
                                                    ? controller.replaceDesc
                                                    : "استبدل قطعتك من عنا بقطعة جديدة",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                // العروض
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      controller.appTitle.isNotEmpty
                                          ? controller.appTitle
                                          : 'العروض المتاحة',
                                      style: GoogleFonts.cairo(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.four,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          () => AllOffersView(
                                            title: 'كل عروض الاستبدال',
                                            useExchangeOffers: true,
                                          ),
                                        );
                                      },

                                      child: Row(
                                        children: [
                                          Text(
                                            'عرض الكل',
                                            style: GoogleFonts.cairo(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.four,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14,
                                            color: AppColors.four,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                controller.exchangeOffers.isEmpty
                                    ? Center(
                                        child: Text(
                                          'لا توجد عروض حالياً',
                                          style: GoogleFonts.cairo(
                                            fontSize: 16,
                                            color: AppColors.four,
                                          ),
                                        ),
                                      )
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 0,
                                          vertical: 5,
                                        ),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 15,
                                              crossAxisSpacing: 15,
                                              mainAxisExtent: 280,
                                            ),
                                        itemCount:
                                            controller.exchangeOffers.length,
                                        itemBuilder: (context, index) {
                                          final offer =
                                              controller.exchangeOffers[index];
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),

                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                Get.to(
                                                  () => OfferDetailView(
                                                    offer: offer,
                                                    offerId: offer.id,
                                                  ),
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF7F9FC),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.30),
                                                      blurRadius: 12,
                                                      offset: Offset(0, 6),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // image (non-interactive here; card tap opens details)
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          height: 120,
                                                          decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey[200],
                                                            borderRadius:
                                                                const BorderRadius.vertical(
                                                                  top:
                                                                      Radius.circular(
                                                                        10,
                                                                      ),
                                                                ),
                                                            image:
                                                                offer
                                                                    .images
                                                                    .isNotEmpty
                                                                ? DecorationImage(
                                                                    image: CachedNetworkImageProvider(
                                                                      offer
                                                                          .images
                                                                          .first
                                                                          .imageUrl,
                                                                    ),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : null,
                                                          ),
                                                          child:
                                                              offer
                                                                  .images
                                                                  .isEmpty
                                                              ? Center(
                                                                  child: Icon(
                                                                    Icons
                                                                        .image_not_supported,
                                                                    color: AppColors
                                                                        .primary,
                                                                    size:
                                                                        MediaQuery.of(
                                                                          context,
                                                                        ).size.width *
                                                                        0.14,
                                                                  ),
                                                                )
                                                              : null,
                                                        ),

                                                        if (offer.isSold)
                                                          Positioned(
                                                            top: 8,
                                                            right: 8,
                                                            child: Transform.rotate(
                                                              angle: -0.08,
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          4,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .red
                                                                      .shade700,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black26,
                                                                      blurRadius:
                                                                          6,
                                                                      offset:
                                                                          Offset(
                                                                            0,
                                                                            2,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: const Text(
                                                                  'تم البيع',
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),

                                                        Positioned(
                                                          bottom: 8,
                                                          left: 4,
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                  left: 10,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        15,
                                                                      ),
                                                                  color: Colors
                                                                      .blue,
                                                                ),
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      10,
                                                                ),
                                                            child: Text(
                                                              offer.newPrice,
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        left:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.035,
                                                        right:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.035,
                                                        top:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.035,
                                                        bottom:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.015,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            offer
                                                                    .name
                                                                    .isNotEmpty
                                                                ? offer.name
                                                                : "",
                                                            style: TextStyle(
                                                              fontSize:
                                                                  MediaQuery.of(
                                                                    context,
                                                                  ).size.width *
                                                                  0.038,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.of(
                                                                  context,
                                                                ).size.width *
                                                                0.02,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .description,
                                                                size: 18,
                                                                color: AppColors
                                                                    .four,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  '${offer.description}'
                                                                      .toString()
                                                                      .replaceAll(
                                                                        '\n',
                                                                        ' ',
                                                                      ),
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .grey[900],
                                                                    fontSize:
                                                                        MediaQuery.of(
                                                                          context,
                                                                        ).size.width *
                                                                        0.032,
                                                                  ),

                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.of(
                                                                  context,
                                                                ).size.width *
                                                                0.01,
                                                          ),
                                                          // fuel type (matches icons used in details view)
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .attach_money,
                                                                size: 18,
                                                                color: AppColors
                                                                    .four,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                ' ${offer.oldPrice}',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .grey[900],
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough,
                                                                  fontSize:
                                                                      MediaQuery.of(
                                                                        context,
                                                                      ).size.width *
                                                                      0.032,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                MediaQuery.of(
                                                                  context,
                                                                ).size.width *
                                                                0.03,
                                                          ),
                                                          OfferCardWidgetButtons(
                                                            phone: offer.phone,
                                                            whatsapp:
                                                                offer.whatsapp,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ],
                            ),
                            // Tab 3: Offers Grid
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 5,
                                    left: 20.0,
                                    right: 20.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'العروض المتاحة',
                                        style: GoogleFonts.cairo(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.four,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(
                                            () => AllOffersView(
                                              title: 'كل عروض البيع',
                                              useExchangeOffers: false,
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              'عرض الكل',
                                              style: GoogleFonts.cairo(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.four,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 14,
                                              color: AppColors.four,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: controller.offers.isEmpty
                                      ? Center(
                                          child: Text(
                                            'لا توجد عروض حالياً',
                                            style: GoogleFonts.cairo(
                                              fontSize: 16,
                                              color: AppColors.four,
                                            ),
                                          ),
                                        )
                                      : GridView.builder(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                mainAxisSpacing: 15,
                                                crossAxisSpacing: 15,
                                                mainAxisExtent: 280,
                                              ),
                                          itemCount: controller.offers.length,
                                          itemBuilder: (context, index) {
                                            final offer =
                                                controller.offers[index];
                                            return Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),

                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  Get.to(
                                                    () => OfferDetailView(
                                                      offer: offer,
                                                      offerId: offer.id,
                                                    ),
                                                  );
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFF7F9FC),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.30),
                                                        blurRadius: 12,
                                                        offset: Offset(0, 6),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // image (non-interactive here; card tap opens details)
                                                      Stack(
                                                        children: [
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            height: 120,
                                                            decoration: BoxDecoration(
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius:
                                                                  const BorderRadius.vertical(
                                                                    top:
                                                                        Radius.circular(
                                                                          10,
                                                                        ),
                                                                  ),
                                                              image:
                                                                  offer
                                                                      .images
                                                                      .isNotEmpty
                                                                  ? DecorationImage(
                                                                      image: CachedNetworkImageProvider(
                                                                        offer
                                                                            .images
                                                                            .first
                                                                            .imageUrl,
                                                                      ),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : null,
                                                            ),
                                                            child:
                                                                offer
                                                                    .images
                                                                    .isEmpty
                                                                ? Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .image_not_supported,
                                                                      color: AppColors
                                                                          .primary,
                                                                      size:
                                                                          MediaQuery.of(
                                                                            context,
                                                                          ).size.width *
                                                                          0.14,
                                                                    ),
                                                                  )
                                                                : null,
                                                          ),

                                                          if (offer.isSold)
                                                            Positioned(
                                                              top: 8,
                                                              right: 8,
                                                              child: Transform.rotate(
                                                                angle: -0.08,
                                                                child: Container(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            4,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .red
                                                                        .shade700,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black26,
                                                                        blurRadius:
                                                                            6,
                                                                        offset:
                                                                            Offset(
                                                                              0,
                                                                              2,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: const Text(
                                                                    'تم البيع',
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                          Positioned(
                                                            bottom: 8,
                                                            left: 4,
                                                            child: Container(
                                                              margin:
                                                                  EdgeInsets.only(
                                                                    left: 10,
                                                                  ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          15,
                                                                        ),
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        10,
                                                                  ),
                                                              child: Text(
                                                                controller
                                                                    .offers[index]
                                                                    .newPrice,
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              left:
                                                                  MediaQuery.of(
                                                                    context,
                                                                  ).size.width *
                                                                  0.035,
                                                              right:
                                                                  MediaQuery.of(
                                                                    context,
                                                                  ).size.width *
                                                                  0.035,
                                                              top:
                                                                  MediaQuery.of(
                                                                    context,
                                                                  ).size.width *
                                                                  0.035,
                                                              bottom:
                                                                  MediaQuery.of(
                                                                    context,
                                                                  ).size.width *
                                                                  0.015,
                                                            ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              controller
                                                                      .offers[index]
                                                                      .name
                                                                      .isNotEmpty
                                                                  ? controller
                                                                        .offers[index]
                                                                        .name
                                                                  : "",
                                                              style: TextStyle(
                                                                fontSize:
                                                                    MediaQuery.of(
                                                                      context,
                                                                    ).size.width *
                                                                    0.038,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  MediaQuery.of(
                                                                    context,
                                                                  ).size.width *
                                                                  0.02,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .description,
                                                                  size: 18,
                                                                  color:
                                                                      AppColors
                                                                          .four,
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    controller
                                                                        .offers[index]
                                                                        .description
                                                                        .toString()
                                                                        .replaceAll(
                                                                          '\n',
                                                                          ' ',
                                                                        ),
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .grey[900],
                                                                      fontSize:
                                                                          MediaQuery.of(
                                                                            context,
                                                                          ).size.width *
                                                                          0.032,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  MediaQuery.of(
                                                                    context,
                                                                  ).size.width *
                                                                  0.01,
                                                            ),
                                                            // fuel type (matches icons used in details view)
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .attach_money,
                                                                  size: 18,
                                                                  color:
                                                                      AppColors
                                                                          .four,
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  ' ${controller.offers[index].oldPrice}',
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .grey[900],
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough,
                                                                    fontSize:
                                                                        MediaQuery.of(
                                                                          context,
                                                                        ).size.width *
                                                                        0.032,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  MediaQuery.of(
                                                                    context,
                                                                  ).size.width *
                                                                  0.03,
                                                            ),
                                                            OfferCardWidgetButtons(
                                                              phone:
                                                                  offer.phone,
                                                              whatsapp: offer
                                                                  .whatsapp,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),

                            // Contact section
                          ],
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

class OfferCardWidgetButtons extends StatelessWidget {
  const OfferCardWidgetButtons({
    super.key,
    required this.phone,
    required this.whatsapp,
  });

  final String phone;
  final String whatsapp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              if (phone.isNotEmpty) {
                await dialPhoneNumber(phone);
              }
            },
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.phone, size: 14, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: InkWell(
            onTap: () async {
              // Normalize phone for WhatsApp
              String normalize(String raw) {
                var s = raw.replaceAll(RegExp(r'[\s\-\(\)+]'), '');
                if (s.startsWith('00')) s = s.substring(2);
                if (s.startsWith('0')) s = s.substring(1);
                if (!s.startsWith('963')) {
                  s = '963' + s;
                }
                return s;
              }

              final normalized = normalize(whatsapp);
              final whatsappUri = Uri.parse(
                'whatsapp://send?phone=$normalized',
              );
              final waMeUri = Uri.parse('https://wa.me/$normalized');
              try {
                if (await canLaunchUrl(whatsappUri)) {
                  await launchUrl(
                    whatsappUri,
                    mode: LaunchMode.externalApplication,
                  );
                  return;
                }
                if (await canLaunchUrl(waMeUri)) {
                  await launchUrl(
                    waMeUri,
                    mode: LaunchMode.externalApplication,
                  );
                }
              } catch (e) {
                print('Error launching WhatsApp: $e');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              height: 35,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset("assets/images/whatsapp.png", width: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
            height: 100,
            width: 120,
            key: this.logoKey,
            child: GestureDetector(
              onTap: () => Get.to(() => const AboutContactView()),
              child: AnimatedLogo(assetPath: ImgAsset.whiteLogo),
            ),
          ),
        ),
        /*Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            " صلحلي  ",
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),*/
        Row(
          children: [
            Builder(
              builder: (context) {
                return Padding(
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
                              Icon(
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
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        homeCtrl.unreadNotificationsCount > 99
                                            ? '99+'
                                            : homeCtrl.unreadNotificationsCount
                                                  .toString(),
                                        style: TextStyle(
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
                );
              },
            ),
            Builder(
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.menu, color: Colors.white, size: 24),
                    ),
                  ),
                );
              },
            ),
          ],
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
    return SizedBox.square(
      dimension: 100,
      child: AnimatedBuilder(
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
                                  gleamValue *
                                      2.2; // wider range for nicer sweep
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
      ),
    );
  }
}

// ويدجت التاب المعدلة
Widget _buildCleanTab(IconData icon, String label) {
  return Tab(
    height: 50, // زيادة الطول قليلاً ليعطي فخامة
    child: Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)],
      ),
    ),
  );
}

/*
 SizedBox(height: 30),
                    Column(children: [
                      Row(
                        children: [
                          const SizedBox(width: 20),
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
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: [
                                _buildContactIconCircular(
                                  icon: Icons.phone,
                                  backgroundColor: const Color(0xFF2196F3),
                                  label: 'اتصال',
                                  onTap: () {
                                    final phone = controller.contactUsModel?.phoneNumber;
                                    if (phone != null && phone.isNotEmpty) {
                                      dialPhoneNumber(phone);
                                    }
                                  },
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
                                      launchUrl(
                                        Uri.parse('https://wa.me/$wa'),
                                      );
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
                                      const SizedBox(height: 8),
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
                                        controller
                                            .contactUsModel
                                            ?.facebook ??
                                            "";
                                    if (fb.isNotEmpty) {
                                      launchUrl(Uri.parse(fb));
                                    }
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
                                      const SizedBox(height: 8),
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
                                        controller
                                            .contactUsModel
                                            ?.instagram ??
                                            "";
                                    if (ig.isNotEmpty) {
                                      launchUrl(Uri.parse(ig));
                                    }
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
                                      const SizedBox(height: 8),
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
                                  backgroundColor: const Color(0xFF2196F3),
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
                      const SizedBox(height: 50),
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
                                height:
                                MediaQuery.of(context).size.height *
                                    0.01,
                              ),
                              Text(
                                controller.contactUsModel?.gmail == null
                                    ? ""
                                    : controller.contactUsModel!.gmail
                                    .toString(),
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
                      const SizedBox(height: 20),],)
 */

/*

                              Expanded(
                                child: controller.services.isEmpty
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
                                                  (MediaQuery.of(context).size.width -
                                                      64) /
                                                  3;
                                              return Column(
                                                children: [
                                                  Container(
                                                    width: width,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(10),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 15,
                                    crossAxisSpacing: 15,
                                    childAspectRatio: 1,
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
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(
                                                  16,
                                                ),
                                                border: Border.all(
                                                  color: AppColors.four.withOpacity(
                                                    0.12,
                                                  ),
                                                  width: 1,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(
                                                      0.06,
                                                    ),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          "https://www.salhly.lareenmedco.com/storage/${controller.services[index].image}",
                                                      height: 50,
                                                      fit: BoxFit.contain,
                                                      placeholder: (context, url) {
                                                        return Container(
                                                          height: 60,
                                                          decoration: BoxDecoration(
                                                            color:
                                                                Colors.grey.shade200,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                              12,
                                                            ),
                                                          ),
                                                          child: Shimmer.fromColors(
                                                            baseColor:
                                                                Colors.grey.shade300,
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
                                                          height: 60,
                                                          decoration: BoxDecoration(
                                                            color:
                                                                Colors.grey.shade200,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                              12,
                                                            ),
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
                                                  const SizedBox(height: 8),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                                    child: Text(
                                                      controller
                                                          .services[index]
                                                          .title,
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.four,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
 */
