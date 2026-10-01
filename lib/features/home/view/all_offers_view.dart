import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/core/utils/phone_utils.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import 'package:salhly/features/home/model/offer_model.dart';
import 'package:salhly/features/home/view/about_contact_view.dart';
import 'package:salhly/features/home/view/offer_detail_view.dart';
import 'package:salhly/features/home/widgets/animated_logo.dart';
import 'package:salhly/features/notifications/view/notifications_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:salhly/core/utils/assets_manager.dart';

enum OfferFilterType { all, available, sold }

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
  String _search = '';
  OfferFilterType _selectedFilter = OfferFilterType.all;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOffers({bool force = false}) async {
    if (force) {
      if (widget.useExchangeOffers) {
        await controller.getExchangeOffers();
      } else {
        await controller.getOffers();
      }
    } else {
      if (widget.useExchangeOffers) {
        if (controller.exchangeOffers.isEmpty) {
          await controller.getExchangeOffers();
        }
      } else {
        if (controller.offers.isEmpty) {
          await controller.getOffers();
        }
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
    return GetBuilder<HomeController>(
      builder: (homeCtrl) {
        final rawOffers = widget.useExchangeOffers
            ? homeCtrl.exchangeOffers
            : homeCtrl.offers;

        // Filtering by search text and status
        final filteredOffers = rawOffers.where((offer) {
          final matchesSearch = _search.trim().isEmpty ||
              offer.name.toLowerCase().contains(_search.trim().toLowerCase()) ||
              offer.description
                  .toLowerCase()
                  .contains(_search.trim().toLowerCase());

          final matchesFilter = switch (_selectedFilter) {
            OfferFilterType.all => true,
            OfferFilterType.available => !offer.isSold,
            OfferFilterType.sold => offer.isSold,
          };

          return matchesSearch && matchesFilter;
        }).toList();

        final canPop = Navigator.of(context).canPop();

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          body: RefreshIndicator(
            color: Colors.blue,
            backgroundColor: Colors.white,
            edgeOffset: 120,
            onRefresh: () => _loadOffers(force: true),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. Creative Modern SliverAppBar matching Sell & Exchange Header with Curved Bottom
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  elevation: 4,
                  shadowColor: Colors.blue.withOpacity(0.25),
                  backgroundColor: Colors.blue,
                  surfaceTintColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  centerTitle: true,
                  title: Text(
                    widget.title,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  leadingWidth: 70,
                  leading: canPop
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: GestureDetector(
                            onTap: () => Get.to(() => const AboutContactView()),
                            child: Center(
                              child: SizedBox(
                                height: 38,
                                width: 38,
                                child: AnimatedLogo(assetPath: ImgAsset.whiteLogo),
                              ),
                            ),
                          ),
                        ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Material(
                            color: Colors.white.withOpacity(0.18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () =>
                                  Get.to(() => const NotificationsPage()),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.notifications_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    if (homeCtrl.unreadNotificationsCount > 0)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            homeCtrl.unreadNotificationsCount >
                                                    99
                                                ? '99+'
                                                : '${homeCtrl.unreadNotificationsCount}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. Search & Filter Bar Section below Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search Box
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFE2EBF4),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _search = val;
                              });
                            },
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: const Color(0xFF1E293B),
                            ),
                            decoration: InputDecoration(
                              hintText: 'ابحث في العروض بالاسم أو الوصف...',
                              hintStyle: GoogleFonts.cairo(
                                color: const Color(0xFF94A3B8),
                                fontSize: 12.5,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: Colors.blue,
                                size: 21,
                              ),
                              suffixIcon: _search.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() {
                                          _search = '';
                                        });
                                      },
                                      child: const Icon(
                                        Icons.cancel_rounded,
                                        color: Color(0xFF94A3B8),
                                        size: 18,
                                      ),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Filter Chips
                        Row(
                          children: [
                            _buildFilterChip(
                              label: 'الكل (${filteredOffers.length})',
                              type: OfferFilterType.all,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'متاح للطلب',
                              type: OfferFilterType.available,
                              icon: Icons.check_circle_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'تم البيع',
                              type: OfferFilterType.sold,
                              icon: Icons.remove_circle_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Main Grid Content (Perfectly Snug & Compact - No Blank White Space)
                if (isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    ),
                  )
                else if (rawOffers.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(
                      icon: Icons.local_offer_outlined,
                      title: 'لا توجد عروض حالياً',
                      subtitle: 'سيتم إضافة عروض جديدة ومميزة قريباً، تابعنا!',
                    ),
                  )
                else if (filteredOffers.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'لا توجد نتائج مطابقة',
                      subtitle: 'جرب البحث بكلمات أخرى أو تغيير الفلتر',
                      actionText: 'إعادة ضبط البحث',
                      onAction: () {
                        _searchController.clear();
                        setState(() {
                          _search = '';
                          _selectedFilter = OfferFilterType.all;
                        });
                      },
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 120),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 238,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final offer = filteredOffers[index];
                          return _GeniusVibrantOfferCard(offer: offer);
                        },
                        childCount: filteredOffers.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required OfferFilterType type,
    IconData? icon,
  }) {
    final isSelected = _selectedFilter == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : const Color(0xFFE2EBF4),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.28),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 54,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  actionText,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 🚀 Genius Vibrant Offer Card (No Dead Space, Glowing Gradient Bottom Action Bars)
// =========================================================================
class _GeniusVibrantOfferCard extends StatelessWidget {
  final Offer offer;

  const _GeniusVibrantOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.to(
            () => OfferDetailView(
              offer: offer,
              offerId: offer.id,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.06),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFE8EEF5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Image Section with Glass Price & Sold Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 114,
                      color: const Color(0xFFF1F5F9),
                      child: offer.images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: offer.images.first.imageUrl,
                              fit: BoxFit.contain,
                              placeholder: (_, __) => Container(
                                color: const Color(0xFFE2E8F0),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey.shade400,
                                  size: 32,
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey.shade400,
                                size: 32,
                              ),
                            ),
                    ),
                  ),

                  // Gradient overlay on image bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Floating Sold Badge (ONLY if isSold == true)
                  if (offer.isSold)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_rounded,
                                  color: Colors.white,
                                  size: 10,
                                ),
                                const SizedBox(width: 2.5),
                                Text(
                                  'تم البيع',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Floating Glass Price Pill on Image Bottom-Left (Modern Glowing Sapphire Glass)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF0284C7),
                                Color(0xFF1D4ED8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1D4ED8).withOpacity(0.38),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            offer.newPrice,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 2. Card Content (Anchored to the very bottom)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(9, 7, 9, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with Icon
                          Row(
                            children: [
                              const Icon(
                                Icons.sell_rounded,
                                size: 13.5,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  offer.name,
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                    color: const Color(0xFF0F172A),
                                    height: 1.25,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 2),

                          // Description with Icon
                          Row(
                            children: [
                              Icon(
                                Icons.notes_rounded,
                                size: 13,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  offer.description.replaceAll('\n', ' ').trim(),
                                  style: GoogleFonts.cairo(
                                    color: const Color(0xFF64748B),
                                    fontSize: 10.5,
                                    height: 1.25,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          // Old Struck-through Price (if present)
                          if (offer.oldPrice.isNotEmpty &&
                              offer.oldPrice.trim() != offer.newPrice.trim()) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.price_change_outlined,
                                  size: 13,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  offer.oldPrice,
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey.shade500,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.red.shade400,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      // Divider line before action buttons
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: const Color(0xFFE2E8F0).withOpacity(0.8),
                      ),

                      // 3. Action Buttons (Call & WhatsApp)
                      Row(
                        children: [
                          // Call Button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  if (offer.phone.isNotEmpty) {
                                    await dialPhoneNumber(offer.phone);
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 29,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.blue,
                                        Color(0xFF1976D2),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.35),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1.5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.phone_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 3.5),
                                      Text(
                                        'اتصال',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 6),

                          // WhatsApp Button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _openWhatsApp(offer.whatsapp),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 29,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF16A34A),
                                        Color(0xFF15803D),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF16A34A)
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1.5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const FaIcon(
                                        FontAwesomeIcons.whatsapp,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 3.5),
                                      Text(
                                        'واتساب',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(String phone) async {
    if (phone.isEmpty) return;

    var s = phone.replaceAll(RegExp(r'[\s\-\(\)+]'), '');
    if (s.startsWith('00')) {
      s = s.substring(2);
    }
    if (s.startsWith('0')) {
      s = s.substring(1);
    }
    if (!s.startsWith('963')) {
      s = '963$s';
    }

    final whatsappUri = Uri.parse('whatsapp://send?phone=$s');
    final waMeUri = Uri.parse('https://wa.me/$s');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(waMeUri)) {
        await launchUrl(waMeUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }
} 
