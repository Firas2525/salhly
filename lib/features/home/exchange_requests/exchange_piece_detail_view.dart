import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/features/home/exchange_requests/exchange_requests_controller.dart';
import 'package:salhly/features/home/exchange_requests/exchange_piece_request_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:photo_view/photo_view.dart';
import '../../../core/utils/ui_utils.dart';

class ExchangePieceDetailView extends StatefulWidget {
  final int requestId;

  const ExchangePieceDetailView({super.key, required this.requestId});

  @override
  State<ExchangePieceDetailView> createState() =>
      _ExchangePieceDetailViewState();
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

class _ExchangePieceDetailViewState extends State<ExchangePieceDetailView> {
  late final ExchangeRequestsController controller;
  List<int> _offerPageIndices = [];

  @override
  void initState() {
    super.initState();
    controller = Get.put(ExchangeRequestsController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.fetchRequestDetails(widget.requestId);
    });
  }

  void _showOfferImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(imageUrl),
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
  }

  void _openOfferDetail(BuildContext context, ExchangePieceOffer offer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExchangeOfferDetailPage(offer: offer),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildOfferImageSlider(ExchangePieceOffer offer, int offerIndex) {
    final hasMultipleImages = offer.images.length > 1;
    final imageList = offer.images.isNotEmpty
        ? offer.images
        : offer.imageUrl.isNotEmpty
        ? [
            ExchangePieceImage(
              id: offer.id,
              image: offer.image,
              imageUrl: offer.imageUrl,
            ),
          ]
        : [];

    if (imageList.isEmpty) {
      return SizedBox.shrink();
    }

    return Stack(
      children: [
        SizedBox(
          height: 130,
          child: PageView.builder(
            itemCount: imageList.length,
            onPageChanged: (page) {
              setState(() {
                if (_offerPageIndices.length <= offerIndex) {
                  _offerPageIndices = List<int>.filled(
                    offerIndex + 1,
                    0,
                    growable: true,
                  );
                }
                _offerPageIndices[offerIndex] = page;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () =>
                    _showOfferImageDialog(context, imageList[index].imageUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    imageList[index].imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (hasMultipleImages) ...[
          Column(children: [
            const SizedBox(height: 110),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageList.length, (index) {
                final selected =
                    (_offerPageIndices.length > offerIndex
                        ? _offerPageIndices[offerIndex]
                        : 0) ==
                        index;
                return Container(
                  width: selected ? 10 : 8,
                  height: selected ? 10 : 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.four : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],)

        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          GetBuilder<ExchangeRequestsController>(
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
                          'تفاصيل طلب الاستبدال',
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
                    ...(() {
                      final offerStartIndices = <int>[];
                      int offerOffset = 0;
                      for (final piece in request.pieces) {
                        offerStartIndices.add(offerOffset);
                        offerOffset += piece.offers.length;
                      }
                      if (_offerPageIndices.length != offerOffset) {
                        _offerPageIndices = List<int>.filled(offerOffset, 0);
                      }

                      return request.pieces.asMap().entries.map((entry) {
                        final piece = entry.value;
                        final startOfferIndex = offerStartIndices[entry.key];

                        return Container(
                          width: double.infinity,
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
                              SizedBox(height: 12),

                              // Media
                              if (piece.images.isNotEmpty ||
                                  piece.voiceRecordUrl != null) ...[
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
                                    children: piece.images
                                        .map((img) => MediaPreview(image: img))
                                        .toList(),
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
                                  MediaPreview(
                                    voiceRecordUrl: piece.voiceRecordUrl,
                                  ),
                                  SizedBox(height: 12),
                                ],
                              ],

                              // Offers
                              if (piece.offers.isNotEmpty) ...[
                                Text(
                                  'العروض المتاحة:',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                SizedBox(
                                  height: 260,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: piece.offers.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(width: 14),
                                    padding: const EdgeInsets.only(bottom: 4),
                                    itemBuilder: (context, index) {
                                      final offer = piece.offers[index];
                                      final offerIndex =
                                          startOfferIndex + index;
                                      return Material(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          onTap: () =>
                                              _openOfferDetail(context, offer),
                                          child: Container(
                                            width: 220,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                _buildOfferImageSlider(
                                                  offer,
                                                  offerIndex,
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 10,
                                                        ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (offer
                                                            .description
                                                            .isNotEmpty) ...[
                                                          Text(
                                                            'الوصف',
                                                            style:
                                                                GoogleFonts.cairo(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700,
                                                                ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            offer.description,
                                                            style:
                                                                GoogleFonts.cairo(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          SizedBox(height: 10),
                                                        ],
                                                        Text(
                                                          'فرق السعر',
                                                          style:
                                                              GoogleFonts.cairo(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .grey
                                                                    .shade700,
                                                              ),
                                                        ),
                                                        SizedBox(height: 6),
                                                        Text(
                                                          '${offer.differencePrice}',
                                                          style:
                                                              GoogleFonts.cairo(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppColors
                                                                    .four,
                                                              ),
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
                                    },
                                  ),
                                ),
                                SizedBox(height: 14),
                              ],
                            ],
                          ),
                        );
                      }).toList();
                    })(),

                    // Admin Note
                    if (request.adminNote != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.deepOrangeAccent.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.note,
                                  color: Colors.deepOrangeAccent,
                                ),
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
        ],
      ),
    );
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

class ExchangeOfferDetailPage extends StatefulWidget {
  final ExchangePieceOffer offer;

  const ExchangeOfferDetailPage({super.key, required this.offer});

  @override
  State<ExchangeOfferDetailPage> createState() =>
      _ExchangeOfferDetailPageState();
}

class _ExchangeOfferDetailPageState extends State<ExchangeOfferDetailPage> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openImageViewer(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(imageUrl),
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
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final imageList = offer.images.isNotEmpty
        ? offer.images
        : offer.imageUrl.isNotEmpty
        ? [
            ExchangePieceImage(
              id: offer.id,
              image: offer.image,
              imageUrl: offer.imageUrl,
            ),
          ]
        : [];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: Color(0xFFF7F8FA))),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.32,
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
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
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
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey.shade200,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: imageList.isEmpty
                                ? Container(
                                    height: 250,
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                        size: 60,
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    height: 260,
                                    child: Stack(
                                      children: [
                                        PageView.builder(
                                          controller: _pageController,
                                          itemCount: imageList.length,
                                          onPageChanged: (index) {
                                            setState(
                                              () => _currentPage = index,
                                            );
                                          },
                                          itemBuilder: (context, index) {
                                            final image = imageList[index];
                                            return GestureDetector(
                                              onTap: () => _openImageViewer(
                                                image.imageUrl,
                                              ),
                                              child: Image.network(
                                                image.imageUrl,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Container(
                                                      color:
                                                          Colors.grey.shade300,
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey,
                                                          size: 32,
                                                        ),
                                                      ),
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                        if (imageList.length > 1)
                                          Positioned(
                                            bottom: 12,
                                            left: 0,
                                            right: 0,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: List.generate(
                                                imageList.length,
                                                (index) => Container(
                                                  width: _currentPage == index
                                                      ? 10
                                                      : 8,
                                                  height: _currentPage == index
                                                      ? 10
                                                      : 8,
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: _currentPage == index
                                                        ? Colors.white
                                                        : Colors.white54,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'الوصف كامل:',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.four,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          offer.description.isNotEmpty
                              ? offer.description
                              : 'لا يوجد وصف متاح.',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'فرق السعر',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                offer.differencePrice.isNotEmpty
                                    ? offer.differencePrice
                                    : '-',
                                style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.four,
                                ),
                              ),
                              if (widget.offer.images.length > 1) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'الصور:',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 96,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: widget.offer.images.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 10),
                                    itemBuilder: (context, index) {
                                      final image = widget.offer.images[index];
                                      return GestureDetector(
                                        onTap: () =>
                                            _openImageViewer(image.imageUrl),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          child: Image.network(
                                            image.imageUrl,
                                            width: 96,
                                            height: 96,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      color:
                                                          Colors.grey.shade200,
                                                      width: 96,
                                                      height: 96,
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
