import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
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
                    imageProvider: NetworkImage(widget.file.fullUrl),
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
          child: Image.network(
            widget.file.fullUrl,
            width: 120,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              width: 120,
              height: 80,
              color: Colors.grey.shade200,
              child: Icon(Icons.broken_image, color: Colors.grey),
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
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
      GetBuilder<RequestsController>(
        builder: (controller) {
          if (controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.four),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
            child: Column(
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
                      'الخدمات المطلوبة',
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
                  child: controller.requests.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد طلبات حالياً',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              color: AppColors.four,
                            ),
                          ),
                        )
                      : ListView.separated(
                          separatorBuilder: (_, __) => SizedBox(height: 14),
                          itemCount: controller.requests.length,
                          itemBuilder: (context, index) {
                            final r = controller.requests[index];
                            return InkWell(
                              onTap: () =>
                                  Get.to(() => RequestDetailView(request: r)),
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: LinearGradient(
                                    colors: [Colors.white, Colors.white],
                                  ),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.06),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 18,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Status badge (top right)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
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
                                              color: Colors.black.withOpacity(
                                                0.12,
                                              ),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
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
                                            SizedBox(width: 6),
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
                                    // Main content (no media)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Main info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 28),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.person,
                                                      color: AppColors.four,
                                                      size: 18,
                                                    ),
                                                    SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        r.fullName,
                                                        style:
                                                            GoogleFonts.cairo(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(
                                                      Icons.calendar_today,
                                                      color: Colors.grey,
                                                      size: 15,
                                                    ),
                                                    SizedBox(width: 3),
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
                                                SizedBox(height: 7),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.home_repair_service,
                                                      color: AppColors.four,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Expanded(
                                                      child: Text(
                                                        '${r.service?.name ?? ''} • ${r.subService?.name ?? ''}',
                                                        style:
                                                            GoogleFonts.cairo(
                                                              fontSize: 13,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  r.description,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 13,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.phone,
                                                      size: 15,
                                                      color: AppColors.four,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      r.phoneNumber,
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 16,
                                                      color: AppColors.four
                                                          .withOpacity(0.7),
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
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    ]));
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
