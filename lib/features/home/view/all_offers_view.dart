import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/core/utils/phone_utils.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import 'package:salhly/features/home/model/offer_model.dart';
import 'package:salhly/features/home/view/offer_detail_view.dart';
import 'package:url_launcher/url_launcher.dart';

class AllOffersView extends StatefulWidget {
  final String title;
  final bool useExchangeOffers;

  const AllOffersView({
    super.key,
    required this.title,
    required this.useExchangeOffers,
  });

  @override
  State<AllOffersView> createState() => _AllOffersViewState();
}

class _AllOffersViewState extends State<AllOffersView> {
  final HomeController controller = Get.put(HomeController());
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    if (widget.useExchangeOffers) {
      if (controller.exchangeOffers.isEmpty) {
        await controller.getExchangeOffers();
      }
    } else {
      if (controller.offers.isEmpty) {
        await controller.getOffers();
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final offers = widget.useExchangeOffers
        ? controller.exchangeOffers
        : controller.offers;

    return Scaffold(
      //
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.white)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Stack(
              children: [
                /* Container(
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
                    ),*/
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue,
                        Colors.blue.withOpacity(0.25),
                        Colors.white,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child:
            Column(children: [
                SizedBox(height: 40),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
              SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : offers.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد عروض حالياً',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: AppColors.four,
                        ),
                      ),
                    )
                  : GridView.builder(padding: EdgeInsets.only(bottom: 20,top: 20),
                      itemCount: offers.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            mainAxisExtent: 270,
                          ),
                      itemBuilder: (context, index) {
                        final offer = offers[index];
                        return InkWell(
                          onTap: () {
                            Get.to(
                              () => OfferDetailView(
                                offer: offer,
                                offerId: offer.id,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F9FC),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.25),
                                  blurRadius: 5,
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
                                          top: Radius.circular(12),
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
                                                size: 42,
                                              ),
                                            )
                                          : null,
                                    ),
                                    if (offer.isSold)
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Transform.rotate(
                                          angle: -0.08,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade700,
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
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
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Text(
                                          offer.newPrice,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 10.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        offer.name,
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons
                                                .description,
                                            size: 18,
                                            color:
                                            AppColors
                                                .four,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${controller.offers[index].description}',
                                              style: TextStyle(
                                                color: Colors
                                                    .grey[900],
                                                fontSize:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                    0.032,
                                              ),
                                              overflow:
                                              TextOverflow
                                                  .ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.attach_money,
                                            size: 16,
                                            color: AppColors.four,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            offer.oldPrice,
                                            style: GoogleFonts.cairo(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.grey[700],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () async {
                                                if (offer.phone.isNotEmpty) {
                                                  await dialPhoneNumber(
                                                    offer.phone,
                                                  );
                                                }
                                              },
                                              child: Container(
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.phone,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () async {
                                                String normalize(String raw) {
                                                  var s = raw.replaceAll(
                                                    RegExp(r'[\s\-\(\)+]'),
                                                    '',
                                                  );
                                                  if (s.startsWith('00')) {
                                                    s = s.substring(2);
                                                  }
                                                  if (s.startsWith('0')) {
                                                    s = s.substring(1);
                                                  }
                                                  if (!s.startsWith('963')) {
                                                    s = '963' + s;
                                                  }
                                                  return s;
                                                }

                                                final normalized = normalize(
                                                  offer.whatsapp,
                                                );
                                                final whatsappUri = Uri.parse(
                                                  'whatsapp://send?phone=$normalized',
                                                );
                                                final waMeUri = Uri.parse(
                                                  'https://wa.me/$normalized',
                                                );
                                                try {
                                                  if (await canLaunchUrl(
                                                    whatsappUri,
                                                  )) {
                                                    await launchUrl(
                                                      whatsappUri,
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                    return;
                                                  }
                                                  if (await canLaunchUrl(
                                                    waMeUri,
                                                  )) {
                                                    await launchUrl(
                                                      waMeUri,
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  }
                                                } catch (e) {
                                                  print(
                                                    'Error launching WhatsApp: $e',
                                                  );
                                                }
                                              },
                                              child: Container(
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Image.asset(
                                                    'assets/images/whatsapp.png',
                                                    width: 18,
                                                  ),
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
                          ),
                        );
                      },
                    ),
            ),])
          ),
        ],
      ),
    );
  }
}
