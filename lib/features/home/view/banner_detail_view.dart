import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import '../../home/model/bunner_model.dart';

class BannerDetailView extends StatelessWidget {
  final BannerModel banner;
  const BannerDetailView({super.key, required this.banner});

  @override
  Widget build(BuildContext context) {
    final hasImage = banner.image != null && banner.image.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.four,
        title: Text(
          'تفاصيل الإعلان',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl:
                          'https://www.salhly.lareenmedco.com/storage/${banner.image}',
                      fit: BoxFit.cover,
                      placeholder: (c, s) => Center(
                        child: CircularProgressIndicator(color: AppColors.four),
                      ),
                      errorWidget: (c, s, e) => _buildLogoPlaceholder(),
                    )
                  : _buildLogoPlaceholder(),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            banner.title,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              banner.description ?? '',
              style: GoogleFonts.cairo(
                fontSize: 15,
                height: 1.8,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Image.asset('assets/images/logo2.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}
