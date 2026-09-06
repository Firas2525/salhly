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
import 'package:salhly/features/home/sell_requests/sell_requests_view.dart';
import 'package:salhly/features/home/exchange_requests/exchange_requests_view.dart';
import 'package:salhly/features/home/exchange_pieces/exchange_piece_view.dart';
import 'package:salhly/features/home/view/all_offers_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import '../view/about_contact_view.dart';
import '../view/privacy_policy_view.dart';
import '../view/banner_detail_view.dart';
import '../view/offer_detail_view.dart';
import '../view/sell_piece_view.dart';
import '../../notifications/view/notifications_page.dart';
import 'animated_logo.dart';
import 'contact_icon_widget.dart';
import 'home_header.dart';
import 'offer_card_widget_buttons.dart';

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
                      SizedBox(height: 15),
                      HeaderHomePage(logoKey: logoKey),
                      
                     // SizedBox(height: 5),
                      // نص مع أيقونة للإعلانات
                     /* Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(Icons.campaign, color: Colors.white, size: 22),
                            const SizedBox(width: 12),
                            Text(
                              'إعلاناتنا المميزة',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),*/
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
                      SizedBox(height: 10),

                      if (controller.goldenServices.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 16.0,),
                          child: Row(
                            children: [
                              Icon(Icons.campaign, color: Colors.blue, size: 22),
                              const SizedBox(width: 12),
                              Text(
                                'خدماتنا الذهبية',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (controller.goldenServices.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.goldenServices.length + 1,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final goldenService =
                                    controller.goldenServices[0];

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
                                  child: Container(width: 120,
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
                                );
                              },
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      /*
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
                      ),*/

                      if (controller.goldenServices.isNotEmpty)
                        SizedBox(height: 10),
                      // TabBarView with bounded height using SizedBox
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 16.0,),
                        child: Row(
                          children: [
                            Icon(Icons.campaign, color: Colors.blue, size: 22),
                            const SizedBox(width: 12),
                            Text(
                              'خدماتنا المميزة',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 520,
                        child:Column(
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
                                                    buildContactIconCircular(
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
                                                    buildContactIconCircular(
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
                      /*  TabBarView(
                          controller: _tabController,
                          children: [
                            // Tab 1: Services Grid with Contact Section

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
                        ),*/
                      ),
                    ],
                  ),
                );
        },
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
