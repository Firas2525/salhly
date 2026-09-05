import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/features/home/exchange_requests/exchange_piece_request_model.dart';
import 'package:salhly/features/home/exchange_requests/exchange_requests_controller.dart';
import 'exchange_piece_detail_view.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:photo_view/photo_view.dart';
import '../../../core/utils/ui_utils.dart';

class ExchangeRequestsView extends StatefulWidget {
  const ExchangeRequestsView({super.key});

  @override
  State<ExchangeRequestsView> createState() => _ExchangeRequestsViewState();
}

class MediaPreview extends StatefulWidget {
  final ExchangePieceImage? image;
  final String? voiceRecordUrl;

  const MediaPreview({super.key, this.image, this.voiceRecordUrl});

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
      if (widget.voiceRecordUrl != null) {
        try {
          await _player.play(UrlSource(widget.voiceRecordUrl!));
          setState(() => _isPlaying = true);
        } catch (e) {
          setState(() => _isPlaying = false);
          showAppSnackbar('خطأ', 'لا يمكن تشغيل الملف');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.image != null) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) =>
                Dialog(
                  insetPadding: EdgeInsets.zero,
                  backgroundColor: Colors.black,
                  child: Stack(
                    children: [
                      PhotoView(
                        imageProvider: NetworkImage(widget.image!.imageUrl),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 3,
                      ),
                      Positioned(
                        top: 20,
                        right: 12,
                        child: IconButton(
                          icon: Icon(
                              Icons.close, color: Colors.white, size: 28),
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
            widget.image!.imageUrl,
            width: 120,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) =>
                Container(
                  width: 120,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
          ),
        ),
      );
    }

    if (widget.voiceRecordUrl != null) {
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
            Text('تشغيل', style: GoogleFonts.cairo(fontSize: 13)),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }
}

class _ExchangeRequestsViewState extends State<ExchangeRequestsView> {
  final controller = Get.put(ExchangeRequestsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
          Positioned.fill(child: Container(color: Colors.white)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery
                .of(context)
                .size
                .height * 0.35,
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
          GetBuilder<ExchangeRequestsController>(
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

                    SizedBox(height: 40),
                    Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(Icons.arrow_back, color: Colors.white,
                                size: 28)),
                        const SizedBox(width: 12),
                        Text(
                          'طلبات الاستبدال',
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
                          'لا توجد طلبات استبدال حالياً',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: AppColors.four,
                          ),
                        ),
                      )
                          : ListView.separated(
                        controller: controller.scrollController,
                        separatorBuilder: (_, __) => SizedBox(height: 14),
                        itemCount: controller.requests.length +
                            (controller.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == controller.requests.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator(
                                  color: AppColors.four)),
                            );
                          }
                          final r = controller.requests[index];
                          return InkWell(
                              onTap: () => Get.to(() =>
                                  ExchangePieceDetailView(requestId: r.id)),
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
                                    // Main content
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
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
                                                  r.user.name,
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
                                                r.createdAt
                                                    .toLocal()
                                                    .toString()
                                                    .split(' ')[0],
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 7),
                                          ...r.pieces.map((piece) =>
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,
                                                children: [

                                                  Text(
                                                    piece.description ?? '',
                                                    maxLines: 2,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  if (piece.adminDescription !=
                                                      null) ...[
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'وصف الإدارة: ${piece
                                                          .adminDescription}',
                                                      maxLines: 2,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 12,
                                                        color: Colors.grey
                                                            .shade600,
                                                        fontStyle: FontStyle
                                                            .italic,
                                                      ),
                                                    ),
                                                  ],
                                                  SizedBox(height: 10),
                                                  // Media
                                                  if (piece.images.isNotEmpty)
                                                    Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: piece.images
                                                          .map((img) =>
                                                          MediaPreview(
                                                              image: img))
                                                          .toList(),
                                                    ),
                                                ],
                                              )),
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
                                                r.user.phone,
                                                style: GoogleFonts.cairo(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ));
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.deepOrangeAccent;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'في الانتظار';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }
}