import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/features/home/view/home_navigation_view.dart';
import 'package:salhly/features/requests/view/requests_view.dart';

class MaintenanceSuccessDialog extends StatefulWidget {
  final String? tagText;
  final String? title;
  final String? subtitle;
  final String? bannerTitle;
  final String? bannerHeader;
  final String? bannerDesc;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onHomePressed;

  const MaintenanceSuccessDialog({
    super.key,
    this.tagText,
    this.title,
    this.subtitle,
    this.bannerTitle,
    this.bannerHeader,
    this.bannerDesc,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.onHomePressed,
  });

  @override
  State<MaintenanceSuccessDialog> createState() =>
      _MaintenanceSuccessDialogState();
}

class _MaintenanceSuccessDialogState extends State<MaintenanceSuccessDialog>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for radiating guarantee rings
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Subtle rotation for background sunburst / sparkles
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Pop-in bounce animation for dialog entrance
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tag = widget.tagText ?? 'تم إرسال الطلب بنجاح';
    final mainTitle = widget.title ?? 'شكراً لاختيارك صلحلي';
    final mainSubtitle = widget.subtitle ??
        'طلب الصيانة قيد المراجعة والمتابعة من قبل فريقنا الفني المتخصص.';
    final bTitle = widget.bannerTitle ?? 'لا تنسَ!';
    final bHeader = widget.bannerHeader ?? 'عمليات الصيانة مكفولة من صلحلي 🛡️';
    final bDesc = widget.bannerDesc ??
        'نضمن لك جودة العمل وأعلى معايير الصيانة لراحة بالك.';
    final primaryBtn = widget.primaryButtonText ?? 'متابعة الطلب';

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 22),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Main Dialog Card
                Container(
                  margin: const EdgeInsets.only(top: 48),
                  padding: const EdgeInsets.fromLTRB(20, 68, 20, 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                        blurRadius: 36,
                        offset: const Offset(0, 16),
                      ),
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success pill tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF10B981),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tag,
                              style: GoogleFonts.cairo(
                                color: const Color(0xFF047857),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Title
                      Text(
                        mainTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        mainSubtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // --- Creative Info Box ---
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFEFF6FF),
                              Color(0xFFDBEAFE),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF3B82F6)
                                .withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6)
                                  .withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF1D4ED8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.verified_user_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bTitle,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1E40AF),
                                    ),
                                  ),
                                  Text(
                                    bHeader,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1E3A8A),
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    bDesc,
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: const Color(0xFF3B82F6),
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Action Buttons
                      Row(
                        children: [
                          // Go to requests / Primary action
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: widget.onPrimaryPressed ??
                                  () {
                                    Get.back(); // close dialog
                                    Get.to(() => const RequestsView());
                                  },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shadowColor:
                                    Colors.blue.withValues(alpha: 0.4),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                primaryBtn,
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Back to home
                          Expanded(
                            flex: 2,
                            child: OutlinedButton(
                              onPressed: widget.onHomePressed ??
                                  () {
                                    Get.offAll(() => const HomeNavigationView());
                                  },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF475569),
                                side: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                  width: 1.2,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'الرئيسية',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Top Floating Animated Graphic (Pulsating Rings & Shining Guarantee Badge)
                Positioned(
                  top: 0,
                  child: AnimatedBuilder(
                    animation: Listenable.merge(
                        [_pulseController, _rotateController]),
                    builder: (context, child) {
                      final pulseVal = _pulseController.value;
                      return SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Pulsing Ripple 1
                            Transform.scale(
                              scale: 1.0 + (pulseVal * 0.45),
                              child: Container(
                                width: 85,
                                height: 85,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.withValues(
                                    alpha: (1.0 - pulseVal) * 0.25,
                                  ),
                                ),
                              ),
                            ),
                            // Outer Pulsing Ripple 2
                            Transform.scale(
                              scale: 1.0 + (pulseVal * 0.25),
                              child: Container(
                                width: 85,
                                height: 85,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF10B981).withValues(
                                    alpha: (1.0 - pulseVal) * 0.35,
                                  ),
                                ),
                              ),
                            ),
                            // Rotating Sunburst Sparkles
                            Transform.rotate(
                              angle: _rotateController.value * 2 * math.pi,
                              child: Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: SweepGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.blue.withValues(alpha: 0.3),
                                      Colors.transparent,
                                      const Color(0xFF10B981)
                                          .withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Center Glowing Badge
                            Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF3B82F6),
                                    Color(0xFF1D4ED8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.45),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.security_rounded,
                                      color: Colors.white,
                                      size: 42,
                                    ),
                                    Positioned(
                                      bottom: 18,
                                      child: Icon(
                                        Icons.check,
                                        color: Color(0xFF60A5FA),
                                        size: 20,
                                      ),
                                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
