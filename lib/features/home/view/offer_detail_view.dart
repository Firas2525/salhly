import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../configs/app_colors.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/utils/ui_utils.dart';
import '../controller/home_controller.dart';
import '../model/offer_model.dart';

class OfferDetailView extends StatefulWidget {
  final int? offerId;
  final Offer? offer;

  const OfferDetailView({super.key, this.offerId, this.offer})
    : assert(
        offerId != null || offer != null,
        'Either offerId or offer must be provided',
      );

  @override
  State<OfferDetailView> createState() => _OfferDetailViewState();
}

class _OfferDetailViewState extends State<OfferDetailView> {
  final HomeController controller = Get.put(HomeController());
  Offer? offer;
  bool isLoading = true;
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.offer != null) {
      offer = widget.offer;
      isLoading = false;
    } else {
      fetchOfferDetail();
    }
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  Future<void> fetchOfferDetail() async {
    if (widget.offerId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      var headers = {'Accept': 'application/json', 'Accept-Language': 'en'};
      var uri = Uri.parse(
        "https://www.salhly.lareenmedco.com/api/offers/find/${widget.offerId}",
      );

      var request = http.Request('GET', uri);
      request.headers.addAll(headers);
      var response = await request.send();
      var data = jsonDecode(await response.stream.bytesToString());

      if (response.statusCode == 200) {
        offer = Offer.fromJson(data['data']);
      } else {
        showAppSnackbar("خطأ", "فشل في تحميل تفاصيل العرض", isError: true);
      }
    } catch (e) {
      print("Exception loading offer detail: $e");
      showAppSnackbar("خطأ", "حدث خطأ أثناء الاتصال", isError: true);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : offer == null
              ? const Center(child: Text('العرض غير متوفر'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      SizedBox(height: 40),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'تفاصيل العرض',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 35),

                      GestureDetector(
                        onTap: offer!.images.isNotEmpty
                            ? () => _openImageViewer(
                                offer!.images
                                    .map((img) => img.imageUrl)
                                    .toList(),
                                _currentImageIndex,
                              )
                            : null,
                        child: Container(
                          width: double.infinity,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey[200],
                          ),
                          child: Stack(
                            children: [
                              offer!.images.isEmpty
                                  ? Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: AppColors.primary,
                                        size: 80,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Stack(
                                        children: [
                                          PageView.builder(
                                            controller: _imagePageController,
                                            itemCount: offer!.images.length,
                                            onPageChanged: (index) {
                                              setState(() {
                                                _currentImageIndex = index;
                                              });
                                            },
                                            itemBuilder: (context, index) {
                                              return CachedNetworkImage(
                                                imageUrl: offer!
                                                    .images[index]
                                                    .imageUrl,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: 250,
                                                placeholder: (context, url) =>
                                                    Container(
                                                      color: Colors.grey[300],
                                                      child: const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    ),
                                                errorWidget:
                                                    (
                                                      context,
                                                      url,
                                                      error,
                                                    ) => Container(
                                                      color: Colors.grey[300],
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey,
                                                          size: 32,
                                                        ),
                                                      ),
                                                    ),
                                              );
                                            },
                                          ),
                                          if (offer!.images.length > 1)
                                            Positioned(
                                              bottom: 12,
                                              left: 0,
                                              right: 0,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: List.generate(
                                                  offer!.images.length,
                                                  (index) => Container(
                                                    width:
                                                        _currentImageIndex ==
                                                            index
                                                        ? 10
                                                        : 8,
                                                    height:
                                                        _currentImageIndex ==
                                                            index
                                                        ? 10
                                                        : 8,
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          _currentImageIndex ==
                                                              index
                                                          ? Colors.white
                                                          : Colors.white54,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                              if (offer!.isSold)
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Transform.rotate(
                                    angle: -0.08,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade700,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'تم البيع',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Name
                      Text(
                        offer!.name,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.four,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Description
                      Text(
                        offer!.description,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Prices
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'السعر الجديد',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${offer!.newPrice}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (offer!.oldPrice != offer!.newPrice)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'السعر القديم',
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '${offer!.oldPrice}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        color: Colors.deepOrangeAccent,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Contact Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (offer?.phone.isNotEmpty == true) {
                                  await dialPhoneNumber(offer!.phone);
                                }
                              },
                              icon: const Icon(
                                Icons.phone,
                                color: Colors.white,
                              ),
                              label: Text(
                                'اتصل الآن',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final whatsappUrl =
                                    'https://wa.me/${offer!.whatsapp}?text=مرحباً، أريد الاستفسار عن العرض: ${offer!.name}';
                                final Uri whatsappUri = Uri.parse(whatsappUrl);
                                if (await canLaunchUrl(whatsappUri)) {
                                  await launchUrl(
                                    whatsappUri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.message,
                                color: Colors.white,
                              ),
                              label: Text(
                                'واتساب',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  void _openImageViewer(List<String> imageUrls, int initialIndex) {
    if (imageUrls.isEmpty) return;
    final imageProviders = imageUrls
        .map((url) => CachedNetworkImageProvider(url))
        .toList();

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
              loadingBuilder: (context, event) =>
                  const Center(child: CircularProgressIndicator()),
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
