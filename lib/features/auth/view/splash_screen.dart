import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/app.dart';
import 'package:salhly/services/version_service.dart';
import 'package:video_player/video_player.dart';

import 'update_required_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  late final AnimationController _animController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _typewriterProgress;
  late final Animation<double> _shimmerSweep;
  late final Animation<double> _detailsFade;

  bool _hasError = false;
  String _statusText = 'جاري التهيئة...';
  Timer? _retryTimer;

  static const String _appName = 'صلّحلي';

  @override
  void initState() {
    super.initState();

    // 1. Initialize Background Video
    _initVideo();

    // 2. Ultra-Smooth Synchronized Controller
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Sequence Curves:
    _logoScale = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.40, curve: Curves.easeOutBack),
    );

    _logoFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.30, curve: Curves.easeIn),
    );

    _typewriterProgress = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.30, 0.75, curve: Curves.linear),
    );

    _shimmerSweep = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.70, 1.0, curve: Curves.easeInOut),
    );

    _detailsFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    );

    _animController.forward();

    // Start App Initialization
    _initializeApp();
  }

  Future<void> _initVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/images/1.mp4');
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(0.0);
      await _videoController!.play();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      print('[SplashScreen] Video load error: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _animController.dispose();
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 1600));
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

      setState(() {
        _statusText = 'مرحباً بك في صلحلي...';
      });
      await Future.delayed(const Duration(milliseconds: 700));

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
    return Scaffold(
      backgroundColor: const Color(0xFF031024),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Crystal Clear Looping Background Video
          RepaintBoundary(
            child: _isVideoInitialized && _videoController != null
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF031024)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
          ),

          // 2. Translucent Royal Blue Header Gradient Overlay (Clear video depth)
          RepaintBoundary(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0284C7).withValues(alpha: 0.58), // Vibrant Royal Blue Header
                    const Color(0xFF0369A1).withValues(alpha: 0.35),
                    const Color(0xFF021B3A).withValues(alpha: 0.78), // Deep Midnight Bottom
                  ],
                  stops: const [0.0, 0.40, 1.0],
                ),
              ),
            ),
          ),

          // 3. Creative Cinematic Layout
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Creative Floating Logo with Cyan-Sapphire Halo
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: RepaintBoundary(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Radial Cyan Glow
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF00E5FF).withValues(alpha: 0.35),
                                      const Color(0xFF0284C7).withValues(alpha: 0.15),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),

                              // Clean Floating Logo Badge
                              Container(
                                width: 100,
                                height: 100,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.45),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/4.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    'assets/images/logo2.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.home_repair_service_rounded,
                                      size: 55,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Animated Typewriter Writing of "صلّحلي" with Electric Cyan Glow
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        final charCount =
                            (_typewriterProgress.value * _appName.length).ceil();
                        final String currentText = _appName.substring(0, charCount);
                        final bool isTyping = _typewriterProgress.value < 1.0;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentText,
                              style: GoogleFonts.cairo(
                                fontSize: 46,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFF0FDF4),
                                letterSpacing: 1.5,
                                height: 1.1,
                                shadows: [
                                  // Electric Diamond Cyan Glow
                                  Shadow(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.90),
                                    blurRadius: 24,
                                    offset: const Offset(0, 2),
                                  ),
                                  Shadow(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.70),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.60),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),

                            // Electric Cyan Typing Beam Cursor
                            if (isTyping)
                              Container(
                                margin: const EdgeInsets.only(right: 4, top: 4),
                                width: 3.5,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.95),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    // Minimalist Cyan-Frosted Tagline Capsule
                    FadeTransition(
                      opacity: _detailsFade,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF00E5FF),
                              size: 13,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'منصة الصيانة والخدمات الذكية',
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFE0F2FE),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 4),

                    // Creative Bottom Loading Line with Diamond Pulsing Beam
                    if (!_hasError) ...[
                      FadeTransition(
                        opacity: _detailsFade,
                        child: Column(
                          children: [
                            // Sleek Glowing Cyan Line
                            Container(
                              width: 150,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: const LinearProgressIndicator(
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Status Text
                            Text(
                              _statusText,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.85),
                                letterSpacing: 0.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Error Retry Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.50),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.wifi_off_rounded,
                              color: Color(0xFFFCA5A5),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'تعذر الاتصال',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: _initializeApp,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'إعادة المحاولة',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
