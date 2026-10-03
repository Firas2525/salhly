import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import 'package:salhly/features/service/controller/service_controller.dart';
import 'package:salhly/features/service/views/service_order_page.dart';

class ServiceView extends StatefulWidget {
  const ServiceView({super.key});

  @override
  State<ServiceView> createState() => _ServiceViewState();
}

class _ServiceViewState extends State<ServiceView> {
  final controller = Get.put(ServiceController());
  String _search = '';
  bool _isGolden = false;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      if (args['isGolden'] == true) {
        _isGolden = true;
      }
    }

    if (!_isGolden && Get.isRegistered<HomeController>()) {
      final homeCtrl = Get.find<HomeController>();
      _isGolden = homeCtrl.goldenServices.any((g) => g.id == controller.serviceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.blue;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          'أقسام الخدمة',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GetBuilder<ServiceController>(
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          final items = _search.trim().isEmpty
              ? ctrl.subServices
              : ctrl.subServices
                    .where(
                      (s) => s.title.toLowerCase().contains(
                        _search.toLowerCase(),
                      ),
                    )
                    .toList();

          return Column(
            children: [
              // Search Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: GoogleFonts.cairo(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن قسم أو خدمة فرعية...',
                      hintStyle: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // Sub-Services List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'لم يتم العثور على أي أقسام مطابقة',
                              style: GoogleFonts.cairo(
                                fontSize: 13.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final s = items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Get.to(
                                    () => ServiceOrderPage(
                                      serviceId: ctrl.serviceId,
                                      subServiceId: s.id,
                                      isGolden: _isGolden,
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Image
                                      if (s.image.isNotEmpty)
                                        CachedNetworkImage(
                                          imageUrl:
                                              'https://www.salhly.lareenmedco.com/storage/${s.image}',
                                          fit: BoxFit.cover,
                                          placeholder: (c, u) => Container(
                                            color: Colors.grey.shade100,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: primaryColor,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (c, u, e) => Container(
                                            color: Colors.grey.shade100,
                                            child: const Icon(
                                              Icons.broken_image_rounded,
                                              color: Colors.grey,
                                              size: 32,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(color: Colors.grey.shade100),

                                      // Gradient overlay for contrast
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.black.withValues(alpha: 0.1),
                                                Colors.black.withValues(alpha: 0.75),
                                              ],
                                              stops: const [0.3, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Card Content
                                      Positioned(
                                        left: 14,
                                        right: 14,
                                        bottom: 14,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                s.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.cairo(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black.withValues(alpha: 0.6),
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'طلب الآن',
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                    Icons.arrow_forward_ios_rounded,
                                                    size: 11,
                                                    color: Colors.white,
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
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
