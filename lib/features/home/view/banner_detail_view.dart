import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:salhly/configs/app_colors.dart';
import '../../home/model/bunner_model.dart';

class BannerDetailView extends StatelessWidget {
  final BannerModel banner;
  const BannerDetailView({super.key, required this.banner});

  @override
  Widget build(BuildContext context) {
    final hasImage = banner.image != null && banner.image.isNotEmpty;

    return Scaffold(
      body:Stack(children: [
      Positioned.fill(child: Container(color: Colors.white)),
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: MediaQuery.of(context).size.height * 0.35,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue,
                Colors.blue.withOpacity(0.55),
                Colors.white,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),
      ),

       ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search / header

          SizedBox(height: 40),
          Row(
            children: [
              GestureDetector(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 28)),
              const SizedBox(width: 12),
              Text(
                'تفاصيل الاعلان',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 35),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
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
              borderRadius: BorderRadius.circular(5),
              child: hasImage
                  ? GestureDetector(
                      onTap: () => _openImageViewer(
                        context,
                        ['https://www.salhly.lareenmedco.com/storage/${banner.image}'],
                        0,
                      ),
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://www.salhly.lareenmedco.com/storage/${banner.image}',
                        fit: BoxFit.cover,
                        placeholder: (c, s) => Center(
                          child: CircularProgressIndicator(color: AppColors.four),
                        ),
                        errorWidget: (c, s, e) => _buildLogoPlaceholder(),
                      ),
                    )
                  : _buildLogoPlaceholder(),
            ),
          ),

          const SizedBox(height: 25),

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
    ]));
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

  void _openImageViewer(BuildContext context, List<String> imageUrls, int initialIndex) {
    if (imageUrls.isEmpty) return;
    final imageProviders = imageUrls.map((url) => CachedNetworkImageProvider(url)).toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: imageProviders.length,
              pageController: PageController(initialPage: initialIndex),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: imageProviders[index],
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                );
              },
              loadingBuilder: (context, event) => const Center(child: CircularProgressIndicator()),
            ),
            Positioned(
              top: 28,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
