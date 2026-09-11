import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';

import '../../service/view/service_view.dart';
import '../model/service_model.dart';

class GoldenServiceCard extends StatelessWidget {
  const GoldenServiceCard({super.key, required this.service});

  final ServicesModel service;

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.of(context).size.width - 64) / 3;

    return GestureDetector(
      onTap: () => Get.to(
        () => ServiceView(),
        arguments: {'serviceId': service.id},
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: cardWidth,
            height: cardWidth,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://www.salhly.lareenmedco.com/storage/${service.image}',
                    height: 50,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => _imageFallback(),
                    errorWidget: (_, __, ___) => _imageFallback(),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    service.title,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4682A9),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -5,
            left: -5,
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient (
                    colors: [
                      Color(0xFFF4D06F),
                      Color(0xFFC58A16),
                      Color(0xFFE5B94D),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC58A16).withOpacity(0.32),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'خدمة ذهبية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: Colors.grey.shade200,
      height: 60,
      child: const Icon(Icons.error_outline, color: Colors.grey),
    );
  }
}
