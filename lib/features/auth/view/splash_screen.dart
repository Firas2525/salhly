import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/services/version_service.dart';
import 'package:salhly/app.dart';
import 'update_required_screen.dart';
import 'onboard_scr.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _wrenchController;
  late AnimationController _toolsController;
  
  bool _hasError = false;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    
    // Logo animation controller - bouncy scale animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    // Wrench rotation animation
    _wrenchController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Tools bounce animation
    _toolsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _logoController.forward();
    _textController.forward();

    // Start version check after a short delay
    _initializeApp();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _wrenchController.dispose();
    _toolsController.dispose();
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // Reset error state
    setState(() {
      _hasError = false;
    });

    // Check version
    print('[SplashScreen] بدء فحص الإصدار...');
    var versionResult = await VersionService.checkVersion();

    if (!mounted) return;

    bool versionSuccess = versionResult['success'] ?? false;
    bool shouldUpdate = versionResult['shouldUpdate'] ?? false;
    String reason = versionResult['reason'] ?? 'Unknown reason';

    print('[SplashScreen] نتيجة الفحص: success=$versionSuccess, shouldUpdate=$shouldUpdate');
    print('[SplashScreen] السبب: $reason');

    // If API error (success=false, shouldUpdate=false), show error and retry
    if (!versionSuccess && !shouldUpdate) {
      print('[SplashScreen] ❌ خطأ في API - عرض خيار إعادة المحاولة');
      setState(() {
        _hasError = true;
      });
      
      // Auto-retry every 5 seconds
      _retryTimer?.cancel();
      _retryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted) {
          print('[SplashScreen] إعادة محاولة تلقائية...');
          _initializeApp();
        }
      });
      return;
    }

    // Cancel retry timer on success
    _retryTimer?.cancel();

    // If should update
    if (shouldUpdate) {
      print('[SplashScreen] ⚠️  مطلوب تحديث - الانتقال إلى شاشة التحديث');
      String? androidLink = versionResult['android_link']?.toString();
      String? iosLink = versionResult['ios_link']?.toString();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => UpdateRequiredScreen(androidLink: androidLink, iosLink: iosLink)),
      );
    } else {
      // Version is valid, check authentication and route accordingly
      print('[SplashScreen] ✅ الإصدار صحيح - فحص حالة المستخدم');
      
      String? token = App.prefs.getString('token');
      
      if (token != null) {
        // User is logged in
        String? userType = App.prefs.getString('type');
        if (userType == "3") {
          print('[SplashScreen] 👨‍🔧 عامل - الانتقال إلى لوحة التحكم');
          Navigator.of(context).pushReplacementNamed('/homeworker');
        } else {
          print('[SplashScreen] 👤 مستخدم عادي - الانتقال إلى الصفحة الرئيسية');
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        // User is not logged in
        print('[SplashScreen] 🔓 لا توجد جلسة - الانتقال إلى شاشة الدخول');
        Navigator.of(context).pushReplacementNamed('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Gradient background with enhanced colors
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.four.withOpacity(0.08),
                  AppColors.four.withOpacity(0.03),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Animated background circles
          Positioned(
            top: -50,
            right: -30,
            child: RotationTransition(
              turns: Tween<double>(begin: 0, end: 1).animate(_wrenchController),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.four.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -50,
            child: RotationTransition(
              turns: Tween<double>(begin: 1, end: 0).animate(_wrenchController),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.four.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated tools icons (decorative repair theme)
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                      CurvedAnimation(parent: _toolsController, curve: Curves.easeInOut),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Wrench icon
                          ScaleTransition(
                            scale: Tween<double>(begin: 0.8, end: 1.1).animate(
                              CurvedAnimation(parent: _toolsController, curve: Curves.easeInOut),
                            ),
                            child: RotationTransition(
                              turns: Tween<double>(begin: 0, end: 0.2).animate(
                                CurvedAnimation(parent: _toolsController, curve: Curves.easeInOut),
                              ),
                              child: Icon(
                                Icons.build_rounded,
                                size: 32,
                                color: AppColors.four.withOpacity(0.6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Hammer icon
                          ScaleTransition(
                            scale: Tween<double>(begin: 1.1, end: 0.8).animate(
                              CurvedAnimation(parent: _toolsController, curve: Curves.easeInOut),
                            ),
                            child: RotationTransition(
                              turns: Tween<double>(begin: 0.2, end: 0).animate(
                                CurvedAnimation(parent: _toolsController, curve: Curves.easeInOut),
                              ),
                              child: Icon(
                                Icons.handyman_rounded,
                                size: 32,
                                color: AppColors.four.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Animated Logo with enhanced styling
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
                    ),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.four.withOpacity(0.25),
                            blurRadius: 40,
                            offset: const Offset(0, 15),
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: AppColors.four.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.four.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(25),
                      child: Image.asset(
                        'assets/images/logo2.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.home_repair_service_rounded,
                          size: 100,
                          color: AppColors.four,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 45),

                  // App Name with enhanced fade animation - FIXED NAME
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
                        CurvedAnimation(parent: _textController, curve: Curves.easeOut),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'صلّحلي',
                            style: GoogleFonts.cairo(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: AppColors.four,
                              letterSpacing: 2,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'منصة الصيانة المنزلية الموثوقة',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 70),

                  // Professional loading indicator with rotation
                  RotationTransition(
                    turns: Tween<double>(begin: 0, end: 1).animate(_wrenchController),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.four.withOpacity(0.1),
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.four.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(
                              Icons.settings_rounded,
                              color: AppColors.four,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Loading text or Error message with retry button
                  if (!_hasError)
                    FadeTransition(
                      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _textController,
                          curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
                        ),
                      ),
                      child: Text(
                        'جاري التحضير...',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    )
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'حدث خطأ في الاتصال',
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'سيتم إعادة المحاولة تلقائياً...',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
