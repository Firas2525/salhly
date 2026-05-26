import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import '../../../core/utils/phone_utils.dart';

class AboutContactView extends StatefulWidget {
  const AboutContactView({super.key});

  @override
  State<AboutContactView> createState() => _AboutContactViewState();
}

class _AboutContactViewState extends State<AboutContactView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HomeController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = Get.find<HomeController>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    if (url.startsWith('tel:')) {
      final phoneNumber = url.substring(4);
      if (phoneNumber.isNotEmpty) {
        await dialPhoneNumber(phoneNumber);
      }
      return;
    }
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFB),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            elevation: 0,
            expandedHeight: 240,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
            ),
            leading: Container(
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.four),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // Tab bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.four,
                indicatorWeight: 3,
                labelColor: AppColors.four,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: 'عننا'),
                  Tab(text: 'تواصل معنا'),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAboutTab(),
                  _buildContactTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.four, Color(0xFF0D3B66)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Stack(
        children: [
          // Animated background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: CustomPaint(
                painter: _BackgroundPainter(),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo2.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'صالحلي',
                  style: GoogleFonts.cairo(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'منصة الخدمات الموثوقة',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    final aboutData = _controller.aboutUsModel;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (aboutData != null) ...[
            // Main about card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.four.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.business,
                          color: AppColors.four,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نبذة عنا',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'اعرف المزيد عن رسالتنا',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200, height: 1),
                  SizedBox(height: 16),
                  Text(
                    aboutData.aboutUs,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Why choose us section
            Text(
              'لماذا تختارنا؟',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            _WhyChooseCard(
              icon: Icons.verified_user,
              title: 'موثوقة',
              description: 'خدمات آمنة وموثوقة تماماً',
              color: Color(0xFF2196F3),
            ),
            _WhyChooseCard(
              icon: Icons.flash_on,
              title: 'سريعة',
              description: 'استجابة فورية لطلباتك',
              color: Color(0xFFFF9800),
            ),
            _WhyChooseCard(
              icon: Icons.paid,
              title: 'أسعار عادلة',
              description: 'أفضل الأسعار في السوق',
              color: Color(0xFF4CAF50),
            ),
            SizedBox(height: 20),
          ] else
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'لم تتمكن من تحميل البيانات',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    final contactData = _controller.contactUsModel;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contactData != null) ...[
            // Contact intro card
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2196F3).withOpacity(0.1),
                    Color(0xFF1976D2).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color(0xFF2196F3).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF2196F3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.headset,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'نحن هنا لمساعدتك',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'يسعدنا الاستماع إلى آرائك واستفساراتك. تواصل معنا عبر القنوات المتاحة.',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Contact methods section
            if (contactData.phoneNumber.isNotEmpty ||
                contactData.whatsAppNumber.isNotEmpty ||
                contactData.gmail.isNotEmpty ||
                contactData.websiteLink.isNotEmpty) ...[
              Text(
                'تواصل معنا',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 14),
            ],

            // Contact items
            if (contactData.phoneNumber.isNotEmpty)
              _ContactMethodCard(
                icon: FontAwesomeIcons.phone,
                label: 'الهاتف',
                value: contactData.phoneNumber,
                color: Color(0xFF4CAF50),
                onTap: () => _launchUrl('tel:${contactData.phoneNumber}'),
              ),
            if (contactData.phoneNumber.isNotEmpty) SizedBox(height: 12),

            if (contactData.whatsAppNumber.isNotEmpty)
              _ContactMethodCard(
                icon: FontAwesomeIcons.whatsapp,
                label: 'واتس آب',
                value: contactData.whatsAppNumber,
                color: Color(0xFF25D366),
                onTap: () =>
                    _launchUrl('https://wa.me/${contactData.whatsAppNumber}'),
              ),
            if (contactData.whatsAppNumber.isNotEmpty) SizedBox(height: 12),

            if (contactData.gmail.isNotEmpty)
              _ContactMethodCard(
                icon: FontAwesomeIcons.envelope,
                label: 'البريد الإلكتروني',
                value: contactData.gmail,
                color: Color(0xFFFF9800),
                onTap: () => _launchUrl('mailto:${contactData.gmail}'),
              ),
            if (contactData.gmail.isNotEmpty) SizedBox(height: 12),

            if (contactData.websiteLink.isNotEmpty)
              _ContactMethodCard(
                icon: FontAwesomeIcons.globe,
                label: 'الموقع الإلكتروني',
                value: contactData.websiteLink,
                color: Color(0xFF2196F3),
                onTap: () => _launchUrl(contactData.websiteLink),
              ),

            SizedBox(height: 28),

            // Social media
            if (contactData.facebook.isNotEmpty ||
                contactData.instagram.isNotEmpty ||
                contactData.linkedin.isNotEmpty) ...[
              Text(
                'تابعنا على وسائل التواصل',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (contactData.facebook.isNotEmpty)
                    _SocialIconButton(
                      icon: FontAwesomeIcons.facebook,
                      color: Color(0xFF1877F2),
                      onTap: () => _launchUrl(contactData.facebook),
                    ),
                  if (contactData.facebook.isNotEmpty) SizedBox(width: 16),
                  if (contactData.instagram.isNotEmpty)
                    _SocialIconButton(
                      icon: FontAwesomeIcons.instagram,
                      color: Color(0xFFE4405F),
                      onTap: () => _launchUrl(contactData.instagram),
                    ),
                  if (contactData.instagram.isNotEmpty) SizedBox(width: 16),
                  if (contactData.linkedin.isNotEmpty)
                    _SocialIconButton(
                      icon: FontAwesomeIcons.linkedin,
                      color: Color(0xFF0077B5),
                      onTap: () => _launchUrl(contactData.linkedin),
                    ),
                ],
              ),
            ],

            SizedBox(height: 24),
          ] else
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'لم تتمكن من تحميل البيانات',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WhyChooseCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _WhyChooseCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactMethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ContactMethodCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: FaIcon(icon, color: color, size: 18),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: color.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: FaIcon(icon, color: color, size: 24),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        canvas.drawCircle(
          Offset(i * 40.0, j * 40.0),
          2,
          paint..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) => false;
}
