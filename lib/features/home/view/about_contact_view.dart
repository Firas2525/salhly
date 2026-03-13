import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:salhly/features/home/controller/home_controller.dart';

import '../../../core/utils/ui_utils.dart';

class AboutContactView extends StatefulWidget {
  const AboutContactView({super.key});

  @override
  State<AboutContactView> createState() => _AboutContactViewState();
}

class _AboutContactViewState extends State<AboutContactView> {
  late HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HomeController>();
    // البيانات محملة بالفعل من HomeController.onInit()
    // لكن نتأكد بتحميلها مرة أخرى إذا لم تكن موجودة
    if (_controller.aboutUsModel == null) {
      _controller.getAboutUs();
    }
    if (_controller.contactUsModel == null) {
      _controller.getContactUs();
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        showAppSnackbar('خطأ', 'لا يمكن فتح الرابط');
      }
    } catch (e) {
      showAppSnackbar('خطأ', 'لا يمكن فتح الرابط');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFBFC),
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
          'نبذة عننا',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: GetBuilder<HomeController>(
        builder: (controller) {
          if (controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.four),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // من نحن section
              if (controller.aboutUsModel != null) ...[
                _buildAboutSection(controller.aboutUsModel!.aboutUs),
                SizedBox(height: 28),
              ],

              // تواصل معنا section
              if (controller.contactUsModel != null) ...[
                _buildContactSection(controller.contactUsModel!),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildAboutSection(String aboutText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 5,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.four,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'من نحن',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.four,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            aboutText,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.white,
              height: 1.9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(var contactData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 5,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.four,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'تواصل معنا',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),

        // Contact icons row (phone, whatsapp, facebook, instagram)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Phone (circular gradient like home page)
              Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final phone = contactData.phoneNumber ?? "";
                        if (phone.isNotEmpty) _launchUrl('tel:$phone');
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(48 * 0.3),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF2196F3),
                              Color(0xFF2196F3).withOpacity(0.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF2196F3).withOpacity(0.25),
                              blurRadius: 12,
                              offset: Offset(0, 5),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اتصال',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.four,
                    ),
                  ),
                ],
              ),

              // WhatsApp
              Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final wa = contactData.whatsAppNumber ?? "";
                        if (wa.isNotEmpty) _launchUrl('https://wa.me/$wa');
                      },
                      child: Container(
                        height: 48,
                        width: 48,
                        child: Image.asset(
                          'assets/images/whats.png',
                          fit: BoxFit.contain,
                        ),
                      ),
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

              // Facebook
              Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final fb = contactData.facebook ?? "";
                        if (fb.isNotEmpty) {
                          final url = fb.startsWith('http')
                              ? fb
                              : 'https://$fb';
                          _launchUrl(url);
                        }
                      },
                      child: Container(
                        height: 48,
                        width: 48,
                        child: Image.asset(
                          'assets/images/face.png',
                          fit: BoxFit.contain,
                        ),
                      ),
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

              // Instagram
              Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final ig = contactData.instagram ?? "";
                        if (ig.isNotEmpty) {
                          final url = ig.startsWith('http')
                              ? ig
                              : 'https://$ig';
                          _launchUrl(url);
                        }
                      },
                      child: Container(
                        height: 48,
                        width: 48,
                        child: Image.asset(
                          'assets/images/insta.png',
                          fit: BoxFit.contain,
                        ),
                      ),
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


              Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final web = contactData.websiteLink ?? "";
                        if (web.isNotEmpty) _launchUrl('$web');
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(48 * 0.3),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF2196F3),
                              Color(0xFF2196F3).withOpacity(0.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF2196F3).withOpacity(0.25),
                              blurRadius: 12,
                              offset: Offset(0, 5),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.web,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'الموقع',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.four,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 20),
      ],
    );
  }
}
