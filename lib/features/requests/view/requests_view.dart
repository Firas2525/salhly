import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/core/utils/assets_manager.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import 'package:salhly/features/home/view/about_contact_view.dart';
import 'package:salhly/features/home/widgets/animated_logo.dart';
import 'package:salhly/features/notifications/view/notifications_page.dart';
import 'package:salhly/features/requests/controller/requests_controller.dart';
import 'package:salhly/features/requests/view/request_detail_view_new.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:photo_view/photo_view.dart';
import 'package:salhly/features/requests/model/request_model.dart';

import '../../../core/utils/ui_utils.dart';

class RequestsView extends StatefulWidget {
  const RequestsView({super.key});

  @override
  State<RequestsView> createState() => _RequestsViewState();
}

class MediaPreview extends StatefulWidget {
  final RequestFile file;
  const MediaPreview({super.key, required this.file});

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  late final AudioPlayer _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onPlayerComplete.listen((_) {
      setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
    } else {
      try {
        await _player.play(UrlSource(widget.file.fullUrl));
        setState(() => _isPlaying = true);
      } catch (e) {
        setState(() => _isPlaying = false);
        showAppSnackbar('خطأ', 'لا يمكن تشغيل الملف');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.file.isImage) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.black,
              child: Stack(
                children: [
                  PhotoView(
                    imageProvider: CachedNetworkImageProvider(widget.file.fullUrl),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                  ),
                  Positioned(
                    top: 20,
                    right: 12,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: widget.file.fullUrl,
            width: 120,
            height: 80,
            fit: BoxFit.cover,
            placeholder: (c, url) => Container(
              width: 120,
              height: 80,
              color: Colors.grey.shade200,
              child: const Center(child: CupertinoActivityIndicator()),
            ),
            errorWidget: (c, e, s) => Container(
              width: 120,
              height: 80,
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    if (widget.file.isAudio) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _togglePlay,
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: AppColors.four,
                size: 28,
              ),
            ),
            SizedBox(width: 8),
            Text('تشغيل تسجيل', style: GoogleFonts.cairo(fontSize: 13)),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }
}

class _RequestsViewState extends State<RequestsView> {
  final controller = Get.put(RequestsController());

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: GetBuilder<RequestsController>(
        builder: (reqCtrl) {
          return RefreshIndicator(
            color: Colors.blue,
            backgroundColor: Colors.white,
            edgeOffset: 120,
            onRefresh: () => reqCtrl.getRequests(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
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
                    'الطلبات',
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
                              onTap: () => Get.to(() => const NotificationsPage()),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: GetBuilder<HomeController>(
                                  init: Get.isRegistered<HomeController>()
                                      ? Get.find<HomeController>()
                                      : Get.put(HomeController()),
                                  builder: (homeCtrl) {
                                    return Stack(
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
                                                homeCtrl.unreadNotificationsCount > 99
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
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (reqCtrl.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    ),
                  )
                else if (reqCtrl.requests.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.blue.withOpacity(0.35),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'لا توجد طلبات حالياً',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final r = reqCtrl.requests[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1E293B).withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                onTap: () => Get.to(() => RequestDetailView(request: r)),
                                borderRadius: BorderRadius.circular(18),
                                child: Stack(
                                  children: [
                                    // Status badge (top right)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(r.status),
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(18),
                                            bottomLeft: Radius.circular(14),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.12),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _getStatusIcon(r.status),
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _getStatusText(r.status),
                                              style: GoogleFonts.cairo(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Main content
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 24),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person,
                                                color: AppColors.four,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  r.fullName,
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.calendar_today,
                                                color: Colors.grey,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                r.createdAt != null
                                                    ? r.createdAt!
                                                        .toLocal()
                                                        .toString()
                                                        .split(' ')[0]
                                                    : '',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.home_repair_service,
                                                color: AppColors.four,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  '${r.service?.name ?? ''} • ${r.subService?.name ?? ''}',
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 13,
                                                    color: Colors.black54,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (r.description.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              r.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.cairo(
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.phone,
                                                size: 15,
                                                color: AppColors.four,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                r.phoneNumber,
                                                style: GoogleFonts.cairo(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 15,
                                                color: AppColors.four.withOpacity(0.7),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: reqCtrl.requests.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Color _getStatusColor(String status) {
  final s = status.toLowerCase();
  if (s.contains('pending') || s.contains('قيد')) {
    return Colors.redAccent;
  }

  if (s.contains('approved') || s.contains('موافق')) {
    return const Color(0xFF1E88E5);
  }

  if (s.contains('completed') || s.contains('مكتمل')) {
    return Colors.green.shade600;
  }

  // Treat rejected/reject/رفض as canceled for user-facing view
  if (s.contains('cancel') || s.contains('canceled') || s.contains('reject') || s.contains('rejected') || s.contains('رفض') || s.contains('ملغ')) {
    return Colors.black;
  }

  return AppColors.four;
}

IconData _getStatusIcon(String status) {
  final s = status.toLowerCase();
  if (s.contains('pending') || s.contains('قيد')) return Icons.hourglass_top_rounded;
  if (s.contains('approved') || s.contains('موافق')) return Icons.thumb_up_alt;
  if (s.contains('completed') || s.contains('مكتمل')) return Icons.check_circle_outline;
  if (s.contains('cancel') || s.contains('canceled') || s.contains('reject') || s.contains('rejected') || s.contains('رفض') || s.contains('ملغ')) return Icons.cancel_outlined;
  return Icons.info_outline;
}

String _getStatusText(String status) {
  final s = status.toLowerCase();
  if (s.contains('pending') || s.contains('قيد')) return 'قيد الانتظار';
  if (s.contains('approved') || s.contains('موافق')) return 'موافق عليه';
  if (s.contains('completed') || s.contains('مكتمل')) return 'مكتمل';
  if (s.contains('cancel') || s.contains('canceled') || s.contains('reject') || s.contains('rejected') || s.contains('رفض') || s.contains('ملغ')) return 'ملغي';
  return status;
}
