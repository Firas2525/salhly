import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/app.dart';
import 'package:salhly/services/version_service.dart';

import 'update_required_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _floatingController;
  late final AnimationController _rippleController;
  late final AnimationController _shimmerController;

  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;
  late final Animation<double> _textFadeAnimation;

  bool _hasError = false;
  String _statusText = 'جاري التحضير وتهيئة الخدمات...';
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Pop-in & Fade Animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    );

    _logoFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _textFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
    );

    // 2. Gentle Floating/Levitation Animation for Logo
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    // 3. Concentric Radiating Energy Ripples
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // 4. Shimmer on the loading bar
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _entranceController.forward();

    // Start App Initialization
    _initializeApp();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatingController.dispose();
    _rippleController.dispose();
    _shimmerController.dispose();
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    setState(() {
      _hasError = false;
      _statusText = 'جاري التحقق من التحديثات...';
    });

    try {
      print('[SplashScreen] بدء فحص الإصدار...');
      final versionResult = await VersionService.checkVersion();

      if (!mounted) return;

      final bool versionSuccess = versionResult['success'] ?? false;
      final bool shouldUpdate = versionResult['shouldUpdate'] ?? false;

      // Handle API failure
      if (!versionSuccess && !shouldUpdate) {
        print('[SplashScreen] ❌ خطأ في API - عرض خيار إعادة المحاولة');
        setState(() {
          _hasError = true;
          _statusText = 'تعذر الاتصال بالخادم، جاري إعادة المحاولة...';
        });

        _retryTimer?.cancel();
        _retryTimer = Timer.periodic(const Duration(seconds: 4), (_) {
          if (mounted) {
            _initializeApp();
          }
        });
        return;
      }

      _retryTimer?.cancel();

      // Handle mandatory update
      if (shouldUpdate) {
        print('[SplashScreen] ⚠️ مطلوب تحديث - الانتقال إلى شاشة التحديث');
        final String? androidLink = versionResult['android_link']?.toString();
        final String? iosLink = versionResult['ios_link']?.toString();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => UpdateRequiredScreen(
              androidLink: androidLink,
              iosLink: iosLink,
            ),
          ),
        );
        return;
      }

      // Check auth session
      setState(() {
        _statusText = 'مرحباً بك في صلحلي...';
      });
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      final String? token = App.prefs.getString('token');
      if (token != null) {
        final String? userType = App.prefs.getString('type');
        if (userType == '1') {
          print('[SplashScreen] 👑 مدير - الانتقال إلى لوحة المدير');
          Navigator.of(context).pushReplacementNamed('/homeadmin');
        } else if (userType == '3') {
          print('[SplashScreen] 👨‍🔧 عامل - الانتقال إلى لوحة التحكم');
          Navigator.of(context).pushReplacementNamed('/homeworker');
        } else {
          print('[SplashScreen] 👤 مستخدم عادي - الانتقال إلى الصفحة الرئيسية');
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        print('[SplashScreen] 🔓 لا توجد جلسة - الانتقال إلى شاشة البداية');
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _statusText = 'حدث خطأ غير متوقع أثناء الاتصال';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Deep Royal Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0A1128),
                    Color(0xFF001F54),
                    Color(0xFF034078),
                    Color(0xFF0284C7),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.0, 0.35, 0.70, 1.0],
                ),
              ),
            ),
          ),

          // 2. Animated Ambient Glowing Background Orbs
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              final val = _floatingController.value;
              return Stack(
                children: [
                  // Top-Left Cyan Glow Orb
                  Positioned(
                    top: -40 + (val * 25),
                    left: -50 + (val * 20),
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00F0FF).withOpacity(0.16),
                      ),
                    ),
                  ),
                  // Center-Right Blue Glow Orb
                  Positioned(
                    top: size.height * 0.35 - (val * 20),
                    right: -70 + (val * 15),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF3B82F6).withOpacity(0.20),
                      ),
                    ),
                  ),
                  // Bottom-Left Sapphire Glow Orb
                  Positioned(
                    bottom: -60 + (val * 30),
                    left: -40 + (val * 25),
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF60A5FA).withOpacity(0.14),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // 3. Frosted Blur Filter over Ambient Orbs
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
              child: const SizedBox(),
            ),
          ),

          // 4. Subtle Radial Geometric Grid / Star Dust Accent
          Positioned.fill(
            child: CustomPaint(
              painter: _StarDustPainter(),
            ),
          ),

          // 5. Main Hero Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Floating 3D Glass Logo Card with Pulsing Rings
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _entranceController,
                        _floatingController,
                        _rippleController,
                      ]),
                      builder: (context, child) {
                        final floatOffset = math.sin(_floatingController.value * 2 * math.pi) * 7.0;
                        final rippleVal = _rippleController.value;

                        return Transform.translate(
                          offset: Offset(0, floatOffset),
                          child: ScaleTransition(
                            scale: _logoScaleAnimation,
                            child: FadeTransition(
                              opacity: _logoFadeAnimation,
                              child: SizedBox(
                                width: 190,
                                height: 190,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Concentric Pulsing Energy Rings
                                    Transform.scale(
                                      scale: 1.0 + (rippleVal * 0.45),
                                      child: Container(
                                        width: 155,
                                        height: 155,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF38BDF8).withOpacity((1.0 - rippleVal) * 0.4),
                                            width: 1.8,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 1.0 + (rippleVal * 0.25),
                                      child: Container(
                                        width: 155,
                                        height: 155,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF60A5FA).withOpacity((1.0 - rippleVal) * 0.5),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Outer Glowing Aura
                                    Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0284C7).withOpacity(0.55),
                                            blurRadius: 36,
                                            spreadRadius: 4,
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFF38BDF8).withOpacity(0.35),
                                            blurRadius: 20,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Premium Frosted Glass Card
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(38),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                        child: Container(
                                          width: 140,
                                          height: 140,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.94),
                                            borderRadius: BorderRadius.circular(38),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.9),
                                              width: 2.2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.18),
                                                blurRadius: 24,
                                                offset: const Offset(0, 12),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(22),
                                          child: Image.asset(
                                            'assets/images/logo2.png',
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.home_repair_service_rounded,
                                              size: 70,
                                              color: Color(0xFF0284C7),
                                            ),
                                          ),
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

                    const SizedBox(height: 28),

                    // App Title & Tagline with Smooth Slide/Fade
                    SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Column(
                          children: [
                            // Main App Title
                            Text(
                              'صلّحلي',
                              style: GoogleFonts.cairo(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                height: 1.1,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF0284C7).withOpacity(0.7),
                                    blurRadius: 24,
                                    offset: const Offset(0, 4),
                                  ),
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Modern Subtitle Capsule Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.22),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Color(0xFF38BDF8),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'منصة الصيانة والخدمات الذكية',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFE0F2FE),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Modern Loading Bar & Status Text or Retry Card
                    if (!_hasError) ...[
                      // Futuristic Shimmer Progress Bar
                      AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          final shimmer = _shimmerController.value;
                          return Container(
                            width: 210,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  // Moving Gradient Light Beam
                                  FractionalTranslation(
                                    translation: Offset((shimmer * 2.8) - 1.4, 0),
                                    child: Container(
                                      width: 90,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            const Color(0xFF38BDF8).withOpacity(0.8),
                                            Colors.white,
                                            const Color(0xFF38BDF8).withOpacity(0.8),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // Status Text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _statusText,
                          key: ValueKey(_statusText),
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.78),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ] else ...[
                      // Error & Retry Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withOpacity(0.4),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.wifi_off_rounded,
                                      color: Color(0xFFFCA5A5),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'تعذر الاتصال بالخادم',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 36,
                                  child: ElevatedButton.icon(
                                    onPressed: _initializeApp,
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 16,
                                    ),
                                    label: Text(
                                      'إعادة المحاولة الآن',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0284C7),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle Decorative Star Dust / Sparkles Painter
class _StarDustPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.12);

    final points = [
      Offset(size.width * 0.15, size.height * 0.18),
      Offset(size.width * 0.85, size.height * 0.22),
      Offset(size.width * 0.25, size.height * 0.45),
      Offset(size.width * 0.80, size.height * 0.60),
      Offset(size.width * 0.12, size.height * 0.72),
      Offset(size.width * 0.88, size.height * 0.82),
    ];

    for (var p in points) {
      canvas.drawCircle(p, 1.8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
