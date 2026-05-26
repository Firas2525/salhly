import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/features/home/sell_requests/sell_requests_controller.dart';
import 'package:salhly/features/home/sell_requests/sell_piece_request_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:photo_view/photo_view.dart';
import '../../../core/utils/ui_utils.dart';

class SellPieceDetailView extends StatefulWidget {
  final int requestId;

  const SellPieceDetailView({super.key, required this.requestId});

  @override
  State<SellPieceDetailView> createState() => _SellPieceDetailViewState();
}

class MediaPreview extends StatefulWidget {
  final SellPieceImage? image;
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
            builder: (context) => Dialog(
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
            widget.image!.imageUrl,
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

class _SellPieceDetailViewState extends State<SellPieceDetailView> {
  late final SellRequestsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SellRequestsController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.fetchRequestDetails(widget.requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F8FA),
        body: Stack(
            children: [
        Positioned.fill(child: Container(color: Color(0xFFF7F8FA))),
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
    GetBuilder<SellRequestsController>(
        builder: (controller) {
          if (controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.four),
            );
          }

          if (controller.selectedRequest == null) {
            return Center(
              child: Text(
                'فشل في تحميل التفاصيل',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: AppColors.four,
                ),
              ),
            );
          }

          final request = controller.selectedRequest!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card

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
                      'تفاصيل طلب البيع',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(request.status),
                        color: _getStatusColor(request.status),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'الحالة: ${_getStatusText(request.status)}',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(request.status),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // User Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات المستخدم',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.four,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.person, color: AppColors.four),
                          SizedBox(width: 8),
                          Text(
                            request.user.name,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, color: AppColors.four),
                          SizedBox(width: 8),
                          Text(
                            request.user.phone,
                            style: GoogleFonts.cairo(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppColors.four),
                          SizedBox(width: 8),
                          Text(
                            'تاريخ الإنشاء: ${request.createdAt.toLocal().toString().split(' ')[0]}',
                            style: GoogleFonts.cairo(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Pieces
                ...request.pieces.map((piece) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'القطعة',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.four,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: AppColors.four),
                          SizedBox(width: 8),
                          Text(
                            'السعر المتوقع: ${piece.expectedPrice}',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'الوصف:',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        piece.description,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      if (piece.adminDescription != null) ...[
                        SizedBox(height: 12),
                        Text(
                          'وصف الإدارة:',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.four,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          piece.adminDescription!,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                      if (piece.adminExpectedPrice != null) ...[
                        SizedBox(height: 8),
                        Text(
                          'سعر الإدارة: ${piece.adminExpectedPrice}',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.four,
                          ),
                        ),
                      ],
                      SizedBox(height: 12),
                      // Media
                      if (piece.images.isNotEmpty || piece.voiceRecordUrl != null) ...[
                        Text(
                          'الوسائط:',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Images
                        if (piece.images.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: piece.images.map((img) => MediaPreview(image: img)).toList(),
                          ),
                          SizedBox(height: 8),
                        ],
                        // Voice Record
                        if (piece.voiceRecordUrl != null) ...[
                          Text(
                            'التسجيل الصوتي:',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 12),
                          MediaPreview(voiceRecordUrl: piece.voiceRecordUrl),
                          SizedBox(height: 12),
                        ],
                      ],
                    ],
                  ),
                )),

                // Admin Note
                if (request.adminNote != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepOrangeAccent.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.note, color: Colors.deepOrangeAccent),
                            SizedBox(width: 8),
                            Text(
                              'ملاحظة الإدارة',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          request.adminNote!,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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