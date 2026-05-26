import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/utils/ui_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:salhly/configs/app_colors.dart';

import '../controller/home_worker_controller.dart';
import '../model/maintenance_order_model.dart';

class OrderDetailWorkerView extends StatefulWidget {
  final MaintenanceOrderModel order;
  const OrderDetailWorkerView({super.key, required this.order});

  @override
  State<OrderDetailWorkerView> createState() => _OrderDetailWorkerViewState();
}

class _OrderDetailWorkerViewState extends State<OrderDetailWorkerView> {
  final controller = Get.find<HomeWorkerController>();
  late TextEditingController amountController;
  late TextEditingController reportController;
  bool isCompleting = false;
  int _currentImageIndex = 0;
  List<XFile>? _reportFiles = [];

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController();
    reportController = TextEditingController();
  }

  @override
  void dispose() {
    amountController.dispose();
    reportController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    try {
      // Use English locale to force Latin digits, show date only or date+time as needed
      return DateFormat('yyyy-MM-dd', 'en').format(dt.toLocal());
    } catch (e) {
      final local = dt.toLocal();
      final y = local.year.toString();
      final m = local.month.toString().padLeft(2, '0');
      final d = local.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }
  }

  Future<void> _pickFiles() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? picked = await picker.pickMultiImage();
      if (picked != null && picked.isNotEmpty) {
        setState(() {
          _reportFiles = picked;
        });
      }
    } catch (e) {
      showAppSnackbar('خطأ', 'فشل اختيار الملفات', isError: true);
    }
  }

  void _openImageViewer(List<OrderFile> images, int initialIndex) {
    if (images.isEmpty) return;
    final imageProviders = images
        .map((f) => CachedNetworkImageProvider(f.fullUrl))
        .toList();
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
              loadingBuilder: (context, event) =>
                  Center(child: CircularProgressIndicator()),
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

  void _completeOrder() async {
    if (amountController.text.isEmpty || reportController.text.isEmpty) {
      showAppSnackbar('تحقق', 'يرجى ملء جميع الحقول', isError: true);
      return;
    }

    setState(() => isCompleting = true);

    try {
      List<File>? files;
      if (_reportFiles != null && _reportFiles!.isNotEmpty) {
        files = _reportFiles!.map((x) => File(x.path)).toList();
      }

      await controller.completeOrder(
        orderId: widget.order.id,
        amountPaid: amountController.text,
        reportDescription: reportController.text,
        reportFiles: files,
      );

      setState(() => isCompleting = false);
    } catch (e) {
      setState(() => isCompleting = false);
      showAppSnackbar('خطأ', 'فشل إكمال الطلب', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isApproved = widget.order.status.toLowerCase().contains('approved');
    bool isCompleted = widget.order.status.toLowerCase().contains('completed');

    final images = widget.order.files?.where((f) => f.isImage).toList() ?? [];
    final audios = widget.order.files?.where((f) => f.isAudio).toList() ?? [];

    // تقرير الإنهاء (للطلبات المكتملة)
    final reportDescription = widget.order.reportDescription ?? '';
    final amountPaid = widget.order.amountPaid ?? '';
    final workerName = widget.order.workerName ?? '';
    final reportFiles = widget.order.reportFiles ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.four, AppColors.four.withOpacity(0.85)],
            ),
          ),
        ),
        title: Text(
          'تفاصيل الطلب',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.four.withOpacity(0.1), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.order.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(widget.order.status),
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.order.fullName,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.order.createdAt != null
                        ? 'التاريخ: ${_formatDate(widget.order.createdAt)}'
                        : '',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailCard(
                    icon: Icons.person,
                    label: 'العميل',
                    value: widget.order.fullName,
                  ),
                  SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.phone,
                    label: 'رقم الهاتف',
                    value: widget.order.phoneNumber,
                    isPhoneNumber: true,
                  ),
                  SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.location_on,
                    label: 'العنوان',
                    value: widget.order.address,
                  ),
                  SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.build,
                    label: 'الخدمة',
                    value: widget.order.serviceName,
                  ),
                  SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.category,
                    label: 'نوع الخدمة',
                    value: widget.order.subServiceName,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'الوصف',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      widget.order.description,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ),

                  if (images.isNotEmpty) ...[
                    SizedBox(height: 20),
                    _buildImageGallery(images),
                    SizedBox(height: 20),
                  ],

                  if (audios.isNotEmpty) ...[
                    Text(
                      'التسجيلات الصوتية',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...audios.map(
                      (a) => Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: _AudioCard(file: a),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],

                  if (isCompleted) ...[
                    SizedBox(height: 24),
                    Divider(),
                    SizedBox(height: 16),
                    Text(
                      'تقرير الإنهاء',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    if (workerName.isNotEmpty || amountPaid.toString().isNotEmpty || reportDescription.toString().isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (workerName.isNotEmpty) ...[
                                  Icon(Icons.person, color: AppColors.four, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('اسم العامل', style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                                        SizedBox(height: 4),
                                        Text(workerName, style: GoogleFonts.cairo(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                                if (amountPaid.toString().isNotEmpty) ...[
                                  SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('المبلغ المدفوع', style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                                      SizedBox(height: 4),
                                      Text(amountPaid.toString(), style: GoogleFonts.cairo(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            if (reportDescription.toString().isNotEmpty) ...[
                              SizedBox(height: 12),
                              Text('ملاحظات الإنهاء', style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                              SizedBox(height: 6),
                              Text(reportDescription.toString(), style: GoogleFonts.cairo(fontSize: 13, color: Colors.black87)),
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
                                      reportFiles
                                          .where((r) => r.isImage)
                                          .toList(),
                                      reportFiles
                                          .where((r) => r.isImage)
                                          .toList()
                                          .indexOf(f),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: f.fullUrl,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      placeholder: (c, u) => Container(
                                        height: 180,
                                        color: Colors.grey.shade200,
                                        child: Center(
                                          child: CircularProgressIndicator(),
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
                  if (isApproved) ...[
                    SizedBox(height: 24),
                    Divider(),
                    SizedBox(height: 16),
                    Text(
                      'إكمال المهمة',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'المبلغ المدفوع',
                        labelStyle: GoogleFonts.cairo(
                          color: Colors.grey.shade700,
                        ),
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color: AppColors.four,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.four,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: reportController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'ملاحظات الإنهاء',
                        labelStyle: GoogleFonts.cairo(
                          color: Colors.grey.shade700,
                        ),
                        prefixIcon: Icon(
                          Icons.description,
                          color: AppColors.four,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.four,
                            width: 2,
                          ),
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),

                    SizedBox(height: 20),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickFiles,
                          icon: Icon(Icons.attach_file, color: Colors.white),
                          label: Text(
                            'أرفق صورة',
                            style: GoogleFonts.cairo(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.four,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        if (_reportFiles != null && _reportFiles!.isNotEmpty)
                          Expanded(
                            child: Text(
                              '${_reportFiles!.length} ملف مرفق',
                              style: GoogleFonts.cairo(),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isCompleting ? null : _completeOrder,
                        icon: isCompleting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Icon(Icons.check_circle, color: Colors.white),
                        label: Text(
                          isCompleting ? 'جاري الإنهاء...' : 'تم اكمال المهمة',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    bool isPhoneNumber = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.four, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isPhoneNumber) ...[
            SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.four,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _launchPhoneCall(value);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.phone,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    try {
      await dialPhoneNumber(phoneNumber);
    } catch (e) {
      showAppSnackbar('خطأ', 'فشل الاتصال', isError: true);
    }
  }

  Widget _buildImageGallery(List<OrderFile> images) {
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
                color: Colors.grey.shade200,
                child: Center(child: CircularProgressIndicator()),
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
                                Container(color: Colors.grey.shade200),
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

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('pending')) return Colors.deepOrangeAccent;
    if (status.toLowerCase().contains('approved')) return Colors.blue;
    return Colors.green;
  }

  String _getStatusText(String status) {
    if (status.toLowerCase().contains('pending')) return 'قيد الانتظار';
    if (status.toLowerCase().contains('approved')) return 'موافق عليه';
    return 'مكتمل';
  }
}

class _AudioCard extends StatefulWidget {
  final OrderFile file;
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
