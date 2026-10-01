import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../configs/app_colors.dart';
import '../../service/view/service_view.dart';
import '../model/service_model.dart';

class GoldenServiceCard extends StatefulWidget {
  const GoldenServiceCard({
    super.key,
    required this.service,
    this.index = 0,
  });

  final ServicesModel service;
  final int index;

  @override
  State<GoldenServiceCard> createState() => _GoldenServiceCardState();
}

class _GoldenServiceCardState extends State<GoldenServiceCard> {
  bool _isPressed = false;

  // Selected Golden Tool Images
  static const List<String> _selectedGoldenImages = [
    '111.jpg',
    '113.jpg',
    '112.jpg',
    '114.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 200.0;
    const double cardHeight = 104.0;

    final String bgImage =
        'assets/images/114.jpg';

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          Get.to(
            () => ServiceView(),
            arguments: {'serviceId': widget.service.id},
          );
        },
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFDE68A).withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // 1. Golden Tools Image covering the card
                Positioned.fill(
                  child: Image.asset(
                    bgImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),

                // 2. Home Header Blue Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          const Color(0xFF0284C7).withValues(alpha: 0.88),
                          const Color(0xFF0369A1).withValues(alpha: 0.72),
                          const Color(0xFFFDE68A).withValues(alpha: 0.55),
                        ],
                        stops: const [0.0, 0.50, 1.0],
                      ),
                    ),
                  ),
                ),

                // 3. Card Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Service Image Container
                      Container(
                        width: 62,
                        height: 62,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFFEF08A),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://www.salhly.lareenmedco.com/storage/${widget.service.image}',
                          fit: BoxFit.contain,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade100,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.home_repair_service_rounded,
                            color: AppColors.four,
                            size: 26,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Title and Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.service.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 5),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 12,
                                  color: Color(0xFF7DD3FC),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'أولوية فورية',
                                    style: GoogleFonts.cairo(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFE0F2FE),
                                      height: 1.1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
