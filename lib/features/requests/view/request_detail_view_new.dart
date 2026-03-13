import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:intl/intl.dart';
import 'package:salhly/features/requests/model/request_model.dart';

import '../../../core/utils/ui_utils.dart';

class RequestDetailView extends StatefulWidget {
  final RequestModel request;
  const RequestDetailView({super.key, required this.request});

  @override
  State<RequestDetailView> createState() => _RequestDetailViewState();
}

class _RequestDetailViewState extends State<RequestDetailView>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    String formatDate(DateTime? dt) {
      if (dt == null) return '-';
      try {
        // Use English locale to ensure Latin digits are used,
        // and format time without seconds (HH:mm).
        return DateFormat('yyyy-MM-dd HH:mm', 'en').format(dt.toLocal());
      } catch (e) {
        // Fallback: produce date/time without seconds and convert digits to latin by using toIso8601-like format
        final local = dt.toLocal();
        final y = local.year.toString();
        final m = local.month.toString().padLeft(2, '0');
        final d = local.day.toString().padLeft(2, '0');
        final hh = local.hour.toString().padLeft(2, '0');
        final min = local.minute.toString().padLeft(2, '0');
        return '$y-$m-$d $hh:$min';
      }
    }

    final images = r.files.where((f) => f.isImage).toList();
    final audios = r.files.where((f) => f.isAudio).toList();
    // تقرير الإنهاء للطلبات المنتهية
    final isCompleted =
        r.status.toLowerCase().contains('completed') ||
        r.status.toLowerCase().contains('مكتمل');
    final reportDescription = r.reportDescription ?? '';
    final reportAmountPaid = r.reportAmountPaid ?? '';
    final reportWorkerName = r.reportWorkerName ?? '';
    final reportFiles = r.reportFiles ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header Hero Section - Pinned as small AppBar
              SliverAppBar(
                elevation: 0,
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.four,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeroHeader(r),
                  collapseMode: CollapseMode.parallax,
                ),
              ),

              // Content sections
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 20),

                    // Quick Info Pills
                    _buildQuickInfo(r, formatDate),
                    SizedBox(height: 24),

                    // Service Details Card
                    _buildServiceCard(r),
                    SizedBox(height: 24),

                    // Images section
                    if (images.isNotEmpty) ...[
                      _buildImageGallery(images),
                      SizedBox(height: 24),
                    ],

                    // Audio section
                    if (audios.isNotEmpty) ...[
                      _buildAudioSection(audios),
                      SizedBox(height: 24),
                    ],

                    // Details Cards Grid
                    _buildDetailsGrid(r, formatDate),
                    SizedBox(height: 24),

                    // تقرير الإنهاء
                    if (isCompleted &&
                        (reportDescription.isNotEmpty ||
                            reportAmountPaid.isNotEmpty ||
                            reportWorkerName.isNotEmpty ||
                            reportFiles.isNotEmpty)) ...[
                      SizedBox(height: 12),
                      Text(
                        'تقرير الإنهاء',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      if (reportWorkerName.isNotEmpty || reportAmountPaid.isNotEmpty || reportDescription.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.four.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.four.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (reportWorkerName.isNotEmpty) ...[
                                    Icon(Icons.person, size: 16, color: AppColors.four),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('اسم العامل', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                                          SizedBox(height: 4),
                                          Text(reportWorkerName, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (reportAmountPaid.isNotEmpty) ...[
                                    SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('المبلغ المدفوع', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                                        SizedBox(height: 4),
                                        Text(reportAmountPaid, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              if (reportDescription.isNotEmpty) ...[
                                SizedBox(height: 12),
                                Text('ملاحظات الإنهاء', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                                SizedBox(height: 6),
                                Text(reportDescription, style: GoogleFonts.cairo(fontSize: 13, color: Colors.black87), textAlign: TextAlign.start),
                              ],
                            ],
                          ),
                        ),
                      if (reportFiles.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Text(
                          'ملفات التقرير',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...reportFiles.map(
                          (f) => f.isImage
                              ? Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: GestureDetector(
                                      onTap: () => _openImageViewer(
                                        reportFiles.where((r) => r.isImage).toList(),
                                        reportFiles.where((r) => r.isImage).toList().indexOf(f),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: f.fullUrl,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        placeholder: (c, u) => Container(
                                          height: 180,
                                          color: Colors.grey.shade100,
                                          child: Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (c, u, e) => Container(
                                          height: 180,
                                          color: Colors.grey.shade200,
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : f.isAudio
                                  ? Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: _AudioCard(file: f),
                                    )
                                  : SizedBox(),
                        ),
                      ],
                      SizedBox(height: 16),
                    ],
                    // معلومات إضافية
                    _buildAdditionalInfo(r, formatDate),
                    SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openImageViewer(List<RequestFile> images, int initialIndex) {
    if (images.isEmpty) return;
    final imageProviders = images.map((f) => CachedNetworkImageProvider(f.fullUrl)).toList();
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
              loadingBuilder: (context, event) => Center(child: CircularProgressIndicator()),
            ),
            Positioned(
              top: 28,
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

  Widget _buildHeroHeader(RequestModel r) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.four, Color(0xFF0D3B66)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Stack(
        children: [
          // Animated background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: _BackgroundPatternPainter()),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Badge
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      "",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Main Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.fullName,
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            r.address,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  Widget _buildQuickInfo(
    RequestModel r,
    String Function(DateTime?) formatDate,
  ) {
    return Row(
      children: [
        Expanded(
          child: _QuickInfoPill(
            icon: Icons.phone,
            label: 'الهاتف',
            value: r.phoneNumber,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _QuickInfoPill(
            icon: Icons.calendar_today,
            label: 'التاريخ',
            value: r.createdAt != null ? formatDate(r.createdAt) : '-',
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(RequestModel r) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.four.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.four.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.four.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_bag,
                  color: AppColors.four,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الخدمة',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      r.service?.name ?? '',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.four.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.category, color: AppColors.four, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'النوع الفرعي',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      r.subService?.name ?? '',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 14),
          Text(
            'الوصف',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            r.description,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<RequestFile> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الصورة',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (images.length > 1)
              Text(
                '${_currentImageIndex + 1}/${images.length}',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.four,
                ),
              ),
          ],
        ),
        SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onTap: () => _openImageViewer(images, _currentImageIndex),
            child: CachedNetworkImage(
              imageUrl: images[_currentImageIndex].fullUrl,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              placeholder: (c, u) => Container(
                height: 280,
                color: Colors.grey.shade100,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (c, u, e) => Container(
                height: 280,
                color: Colors.grey.shade200,
                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            ),
          ),
        ),
        if (images.length > 1) ...[
          SizedBox(height: 14),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 10),
                    child: GestureDetector(
                    onTap: () => setState(() => _currentImageIndex = index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _currentImageIndex == index
                                ? AppColors.four
                                : Colors.grey.shade300,
                            width: _currentImageIndex == index ? 3 : 1,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () => _openImageViewer(images, index),
                          child: CachedNetworkImage(
                            imageUrl: images[index].fullUrl,
                            fit: BoxFit.cover,
                            placeholder: (c, u) =>
                                Container(color: Colors.grey.shade100),
                            errorWidget: (c, u, e) =>
                                Container(color: Colors.grey.shade200),
                          ),
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
    );
  }

  Widget _buildAudioSection(List<RequestFile> audios) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التسجيلات الصوتية',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        ...audios
            .map(
              (audio) => Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: _AudioCard(file: audio),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildDetailsGrid(
    RequestModel r,
    String Function(DateTime?) formatDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفاصيل الطلب',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DetailCard(
                icon: Icons.phone,
                title: 'الهاتف',
                value: r.phoneNumber,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _DetailCard(
                icon: Icons.calendar_today,
                title: 'التاريخ',
                value: r.createdAt != null ? formatDate(r.createdAt) : '-',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo(
    RequestModel r,
    String Function(DateTime?) formatDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات إضافية',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFF8FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoItem('الحالة الحالية', r.status),
              SizedBox(height: 12),
              Divider(color: Colors.grey.shade200, height: 1),
              SizedBox(height: 12),
              _InfoItem(
                'تاريخ الإنشاء',
                r.createdAt != null ? formatDate(r.createdAt) : '-',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _InfoItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('pending') ||
        status.toLowerCase().contains('قيد')) {
      return Color(0xFFFF9800);
    } else if (status.toLowerCase().contains('done') ||
        status.toLowerCase().contains('مكتمل')) {
      return Color(0xFF4CAF50);
    } else if (status.toLowerCase().contains('cancelled') ||
        status.toLowerCase().contains('ملغى')) {
      return Color(0xFFF44336);
    }
    return AppColors.four;
  }
}

class _QuickInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QuickInfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.four.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.four.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.four),
              SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.four,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool fullWidth;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.four.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.four.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.four),
              SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AudioCard extends StatefulWidget {
  final RequestFile file;
  const _AudioCard({required this.file});

  @override
  State<_AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<_AudioCard> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
    _player.onPlayerComplete.listen(
      (_) => setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      }),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      try {
        await _player.play(UrlSource(widget.file.fullUrl));
        setState(() => _isPlaying = true);
      } catch (e) {
        showAppSnackbar('خطأ', 'لا يمكن تشغيل التسجيل الصوتي');
      }
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.four.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.four.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _toggle,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.four,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تسجيل صوتي',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatDuration(_position) +
                          ' / ' +
                          _formatDuration(_duration),
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _duration.inMilliseconds > 0
                  ? _position.inMilliseconds / _duration.inMilliseconds
                  : 0,
              minHeight: 5,
              backgroundColor: AppColors.four.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw diagonal lines pattern0
    for (int i = 0; i < 10; i++) {
      canvas.drawLine(
        Offset(i * 40.0, 0),
        Offset(i * 40.0 + size.height, size.height),
        paint..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
