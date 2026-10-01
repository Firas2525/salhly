import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app.dart';
import '../../../configs/app_colors.dart';
import '../../../core/utils/phone_utils.dart';
import '../../home_admin/view/reorder_services_view.dart';
import '../../service/view/service_view.dart';
import '../controller/home_controller.dart';
import '../view/banner_detail_view.dart';
import 'contact_icon_widget.dart';
import 'golden_service_card.dart';
import 'home_header.dart';

class HomeViewBody extends StatefulWidget {
  final GlobalKey<State> logoKey;

  const HomeViewBody({super.key, required this.logoKey});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  late GlobalKey<State> logoKey;

  @override
  void initState() {
    super.initState();
    logoKey = widget.logoKey;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.four,
      backgroundColor: Colors.white,
      onRefresh: () async {
        try {
          final homeCtrl = Get.find<HomeController>();
          await homeCtrl.initializeHome(force: true);
        } catch (e) {
          // ignore errors
        }
      },
      child: GetBuilder<HomeController>(
        builder: (controller) {
          return controller.isLoading
              ? _buildSkeletonLoader(context)
              : Column(
                  children: [
                    const SizedBox(height: 15),
                    HeaderHomePage(logoKey: logoKey),

                    // Banners ListView
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 8.0,
                              ),
                              child: Container(
                                height: 160,
                                width: 284.44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: banner.image != ""
                                      ? CachedNetworkImage(
                                          imageUrl:
                                              "https://www.salhly.lareenmedco.com/storage/${banner.image}",
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          placeholder: (context, url) =>
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey.shade300,
                                                highlightColor:
                                                    Colors.grey.shade100,
                                                child: Container(
                                                  color: Colors.white,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                color: AppColors.primary,
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.white60,
                                                    size: 38,
                                                  ),
                                                ),
                                              ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Center(
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
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 110),
                        child: Column(
                          children: [
                            if (controller.goldenServices.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              // Golden Services Section Header
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  bottom: 0.0,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.campaign,
                                      color: Colors.blue,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'الخدمات الذهبية',
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Golden Services Horizontal List
                              SizedBox(
                                height: 114,
                                child: ListView.separated(
                                  clipBehavior: Clip.none,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.goldenServices.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    return GoldenServiceCard(
                                      service: controller.goldenServices[index],
                                      index: index,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            // Featured Services Header
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                bottom: 0.0,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.campaign,
                                    color: Colors.blue,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'خدماتنا المميزة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (App.prefs.getString('type') == '1')
                                    InkWell(
                                      onTap: () {
                                        Get.to(
                                          () => const ReorderServicesView(),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF0284C7,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF0284C7,
                                            ).withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.swap_vert_rounded,
                                              color: Color(0xFF0284C7),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'إعادة الترتيب',
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF0284C7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 7),
                            // Featured Services Grid
                            controller.services.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'لا توجد خدمات حالياً',
                                        style: GoogleFonts.cairo(
                                          color: AppColors.four,
                                        ),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: GridView.builder(
                                      padding: const EdgeInsets.only(
                                        top: 8.0,
                                        bottom: 4.0,
                                      ),
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            mainAxisSpacing: 12,
                                            crossAxisSpacing: 12,
                                            childAspectRatio: 1.02,
                                          ),
                                      itemCount: controller.services.length,
                                      itemBuilder: (context, index) {
                                        final service =
                                            controller.services[index];
                                        return GestureDetector(
                                          onTap: () {
                                            Get.to(
                                              () => ServiceView(),
                                              arguments: {
                                                "serviceId": service.id,
                                              },
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: AppColors.four
                                                    .withOpacity(0.12),
                                                width: 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.06),
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
                                                        "https://www.salhly.lareenmedco.com/storage/${service.image}",
                                                    height: 50,
                                                    fit: BoxFit.contain,
                                                    placeholder: (context, url) {
                                                      return Container(
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                          color: Colors
                                                              .grey
                                                              .shade200,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child:
                                                            Shimmer.fromColors(
                                                              baseColor: Colors
                                                                  .grey
                                                                  .shade300,
                                                              highlightColor:
                                                                  Colors
                                                                      .grey
                                                                      .shade100,
                                                              child: Container(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                      );
                                                    },
                                                    errorWidget: (context, url, error) {
                                                      return Container(
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                          color: Colors
                                                              .grey
                                                              .shade200,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: const Center(
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
                                                    service.title,
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.four,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                            const SizedBox(height: 14),

                            // Beautiful Contact Information Section
                            _buildContactSection(controller),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  // --- Beautiful Contact Section ---
  Widget _buildContactSection(HomeController controller) {
    final contact = controller.contactUsModel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.four.withOpacity(0.12), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.phone_android_rounded,
                    color: Colors.blue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'معلومات التواصل',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Social Action Icons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Phone Call
                buildContactIconCircular(
                  icon: Icons.phone_rounded,
                  backgroundColor: const Color(0xFF2196F3),
                  label: 'اتصال',
                  onTap: () {
                    final phone = contact?.phoneNumber;
                    if (phone != null && phone.isNotEmpty) {
                      dialPhoneNumber(phone);
                    }
                  },
                  size: 44,
                ),

                // WhatsApp
                GestureDetector(
                  onTap: () {
                    final wa = contact?.whatsAppNumber ?? "";
                    if (wa.isNotEmpty) {
                      launchUrl(Uri.parse('https://wa.me/$wa'));
                    }
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        height: 44,
                        width: 44,
                        child: Image.asset(
                          'assets/images/whats.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'واتساب',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.four,
                        ),
                      ),
                    ],
                  ),
                ),

                // Facebook
                GestureDetector(
                  onTap: () {
                    final fb = contact?.facebook ?? "";
                    if (fb.isNotEmpty) {
                      launchUrl(Uri.parse(fb));
                    }
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        height: 44,
                        width: 44,
                        child: Image.asset(
                          'assets/images/face.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'فيسبوك',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.four,
                        ),
                      ),
                    ],
                  ),
                ),

                // Instagram
                GestureDetector(
                  onTap: () {
                    final ig = contact?.instagram ?? "";
                    if (ig.isNotEmpty) {
                      launchUrl(Uri.parse(ig));
                    }
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        height: 44,
                        width: 44,
                        child: Image.asset(
                          'assets/images/insta.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'انستغرام',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.four,
                        ),
                      ),
                    ],
                  ),
                ),

                // Website
                if (contact?.websiteLink != null &&
                    contact!.websiteLink.isNotEmpty)
                  buildContactIconCircular(
                    icon: Icons.language_rounded,
                    backgroundColor: const Color(0xFF2196F3),
                    label: 'الموقع',
                    onTap: () => launchUrl(Uri.parse(contact.websiteLink)),
                    size: 44,
                  ),
              ],
            ),

            // Additional details (Company phone & Email)
            if (contact != null &&
                (contact.contact != null ||
                    contact.companyNumber != null ||
                    contact.gmail != null)) ...[
              const SizedBox(height: 16),
              Divider(height: 1, color: AppColors.four.withOpacity(0.12)),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    if (contact.contact != null ||
                        contact.companyNumber != null)
                      Text(
                        "${contact.contact ?? 'للتواصل معنا'} ${contact.companyNumber ?? ''}",
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.four,
                        ),
                      ),
                    if (contact.gmail != null && contact.gmail!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        contact.gmail!,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.four,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Skeleton Loading State ---
  Widget _buildSkeletonLoader(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 27),
            // Header skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 90,
                    width: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Ads skeleton
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    child: Container(
                      height: 160,
                      width: 284.44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
