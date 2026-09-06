import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';

import '../controller/home_controller.dart';
import '../model/offer_model.dart';
import '../exchange_pieces/exchange_piece_view.dart';
import 'banner_detail_view.dart';
import 'all_offers_view.dart';
import 'offer_detail_view.dart';
import 'sell_piece_view.dart';
import '../widgets/home_header.dart';
import '../widgets/offer_card_widget_buttons.dart';

class SellExchangeHomeView extends StatefulWidget {
  const SellExchangeHomeView({super.key});

  @override
  State<SellExchangeHomeView> createState() => _SellExchangeHomeViewState();
}
class _SellExchangeHomeViewState extends State<SellExchangeHomeView> {
  final GlobalKey<State> _logoKey = GlobalKey<State>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.34,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4682A9), Color(0xFFEAF4F8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: RefreshIndicator(
                  color: const Color(0xFF4682A9),
                  onRefresh: () => controller.initializeHome(force: true),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 110),
                    children: [
                      HeaderHomePage(logoKey: _logoKey),
                      _sectionTitle('إعلاناتنا المميزة', Icons.campaign),
                      _buildBanners(controller),
                      _buildSellExchangeActions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 21),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanners(HomeController controller) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: controller.banners.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final banner = controller.banners[index];
          return GestureDetector(
            onTap: banner.description?.isNotEmpty == true
                ? () => Get.to(() => BannerDetailView(banner: banner))
                : null,
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                image: banner.image.isNotEmpty
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(
                          'https://www.salhly.lareenmedco.com/storage/${banner.image}',
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: banner.image.isEmpty
                  ? Center(
                      child: Text(
                        banner.title,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildOffers(HomeController controller) {
    if (controller.offers.isEmpty) {
      return const SizedBox(height: 12);
    }

    return SizedBox(
      height: 124,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: controller.offers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final offer = controller.offers[index];
          return _OfferPreview(offer: offer);
        },
      ),
    );
  }

  Widget _buildSellExchangeActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          GetBuilder<HomeController>(
            builder: (controller) {
              return Column(
                children: [
                  _buildFeatureBanner(
                    image: controller.buyImage,
                    fallbackImage: 'assets/images/19.jpg',
                    title: controller.buyTitle.isNotEmpty
                        ? controller.buyTitle
                        : 'بيعنا قطعتك',
                    description: controller.buyDesc.isNotEmpty
                        ? controller.buyDesc
                        : 'نشتري منك بأفضل الأسعار',
                    icon: Icons.monetization_on,
                    onTap: () => Get.to(() => const SellPieceView()),
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureBanner(
                    image: controller.replaceImage,
                    fallbackImage: 'assets/images/11.jpg',
                    title: 'استبدل قطعتك',
                    description: controller.replaceDesc.isNotEmpty
                        ? controller.replaceDesc
                        : 'استبدل قطعتك من عنا بقطعة جديدة',
                    icon: Icons.sync_alt_rounded,
                    onTap: () => Get.to(() => const ExchangePieceView()),
                  ),
                  const SizedBox(height: 24),
                  _buildUsedProducts(controller),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBanner({
    required String image,
    required String fallbackImage,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorWidget: (_, __, ___) => Image.asset(
                        fallbackImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : Image.asset(
                      fallbackImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [Colors.blue.withOpacity(0.15), Colors.blue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: Colors.white, size: 16),
                            const SizedBox(width: 5),
                            Text(
                              title,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 13,
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

  Widget _buildUsedProducts(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المنتجات المستعملة',
              style: GoogleFonts.cairo(
                color: const Color(0xFF4682A9),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(
                () => const AllOffersView(
                  title: 'كل عروض الاستبدال',
                  useExchangeOffers: true,
                ),
              ),
              child: Text(
                'عرض الكل',
                style: GoogleFonts.cairo(color: const Color(0xFF4682A9)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        controller.exchangeOffers.isEmpty
            ? Center(
                child: Text(
                  'لا توجد منتجات حالياً',
                  style: GoogleFonts.cairo(color: const Color(0xFF4682A9)),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 280,
                ),
                itemCount: controller.exchangeOffers.length,
                itemBuilder: (context, index) {
                  final offer = controller.exchangeOffers[index];
                  return _UsedProductCard(offer: offer);
                },
              ),
      ],
    );
  }
}

class _OfferPreview extends StatelessWidget {
  const _OfferPreview({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE3EEF4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: offer.images.isEmpty
                ? Container(
                    width: 70,
                    height: 70,
                    color: const Color(0xFFEAF4F8),
                    child: const Icon(Icons.local_offer_outlined),
                  )
                : CachedNetworkImage(
                    imageUrl: offer.images.first.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              offer.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: const Color(0xFF263238),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsedProductCard extends StatelessWidget {
  const _UsedProductCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(
        () => OfferDetailView(offer: offer, offerId: offer.id),
      ),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.30),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    image: offer.images.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(
                              offer.images.first.imageUrl,
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: offer.images.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.primary,
                            size: MediaQuery.of(context).size.width * 0.14,
                          ),
                        )
                      : null,
                ),
                if (offer.isSold)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Transform.rotate(
                      angle: -0.08,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
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
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  left: 4,
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blue,
                    ),
                    child: Text(
                      offer.newPrice,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.035,
                right: MediaQuery.of(context).size.width * 0.035,
                top: MediaQuery.of(context).size.width * 0.035,
                bottom: MediaQuery.of(context).size.width * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.name,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.038,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.02,
                  ),
                  Row(
                    children: [
                      Icon(Icons.description, size: 18, color: AppColors.four),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          offer.description.replaceAll('\n', ' '),
                          style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: MediaQuery.of(context).size.width * 0.032,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.01,
                  ),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 18, color: AppColors.four),
                      const SizedBox(width: 5),
                      Text(
                        ' ${offer.oldPrice}',
                        style: TextStyle(
                          color: Colors.grey[900],
                          decoration: TextDecoration.lineThrough,
                          fontSize: MediaQuery.of(context).size.width * 0.032,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.03,
                  ),
                  OfferCardWidgetButtons(
                    phone: offer.phone,
                    whatsapp: offer.whatsapp,
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

