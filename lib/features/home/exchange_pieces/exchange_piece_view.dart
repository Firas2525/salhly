import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app.dart';
import '../../../core/utils/ui_utils.dart';
import '../../service/widgets/maintenance_success_dialog.dart';
import '../controller/home_controller.dart';
import '../exchange_requests/exchange_requests_view.dart';
import '../view/home_navigation_view.dart';

class ExchangePieceView extends StatefulWidget {
  const ExchangePieceView({super.key});

  @override
  State<ExchangePieceView> createState() => _ExchangePieceViewState();
}

class _ExchangePieceViewState extends State<ExchangePieceView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pieceName = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<File> _images = [];
  bool _isLoading = false;

  // Audio recording & playback
  final Record _recorder = Record();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? audioFilePath;
  bool isRecording = false;
  bool isPlaying = false;

  // Recording timer
  Duration recordingDuration = Duration.zero;
  Timer? _recordTimer;

  // Playback tracking
  Duration playbackDuration = Duration.zero;
  Duration playbackPosition = Duration.zero;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _positionSub;

  @override
  void dispose() {
    _pieceName.dispose();
    _descriptionController.dispose();
    _recordTimer?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _audioPlayer.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _removeImage(int index) {
    if (index >= 0 && index < _images.length) {
      setState(() {
        _images.removeAt(index);
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final source = await Get.bottomSheet<ImageSource?>(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Colors.blue),
              title: Text(
                'التقاط صورة بالكاميرا',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.blue),
              title: Text(
                'اختيار من المعرض',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.redAccent),
              title: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => Get.back(result: null),
            ),
          ],
        ),
      ),
      isDismissible: true,
      backgroundColor: Colors.transparent,
    );

    if (source == null) return;

    if (source == ImageSource.gallery) {
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _images.addAll(pickedFiles.map((e) => File(e.path)));
        });
      }
    } else {
      final picked = await picker.pickImage(source: source, imageQuality: 75);
      if (picked != null) {
        setState(() {
          _images.add(File(picked.path));
        });
      }
    }
  }

  // Audio recording
  Future<void> startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        showAppSnackbar('خطأ', 'لا يوجد صلاحيات لتسجيل الصوت');
        return;
      }

      if (isPlaying) {
        await stopAudio();
      }

      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/salhly_exchange_record_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(path: filePath, encoder: AudioEncoder.aacLc);
      audioFilePath = filePath;
      isRecording = true;
      recordingDuration = Duration.zero;
      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          recordingDuration = recordingDuration + const Duration(seconds: 1);
        });
      });
      setState(() {});
    } catch (e) {
      showAppSnackbar('خطأ', 'فشل بدء التسجيل');
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await _recorder.stop();
      isRecording = false;
      _recordTimer?.cancel();
      _recordTimer = null;
      if (path != null) {
        audioFilePath = path;
      }
      setState(() {});
    } catch (e) {
      showAppSnackbar('خطأ', 'فشل إيقاف التسجيل');
    }
  }

  Future<void> playAudio() async {
    if (audioFilePath == null) return;

    try {
      if (isRecording) {
        await stopRecording();
      }

      await _audioPlayer.stop();
      isPlaying = true;
      setState(() {});

      _durationSub?.cancel();
      _positionSub?.cancel();
      _durationSub = _audioPlayer.onDurationChanged.listen((d) {
        setState(() => playbackDuration = d);
      });
      _positionSub = _audioPlayer.onPositionChanged.listen((p) {
        setState(() => playbackPosition = p);
      });
      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          isPlaying = false;
          playbackPosition = Duration.zero;
        });
      });

      await _audioPlayer.play(DeviceFileSource(audioFilePath!));
    } catch (e) {
      isPlaying = false;
      setState(() {});
      showAppSnackbar('خطأ', 'فشل تشغيل الملف الصوتي');
    }
  }

  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      isPlaying = false;
      playbackPosition = Duration.zero;
      setState(() {});
    } catch (_) {}
  }

  void deleteAudio() {
    stopAudio();
    setState(() {
      audioFilePath = null;
      playbackPosition = Duration.zero;
      playbackDuration = Duration.zero;
      recordingDuration = Duration.zero;
    });
  }

  String get recordingDurationStr {
    final minutes = recordingDuration.inMinutes.toString().padLeft(2, '0');
    final seconds = (recordingDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _whatsappNumber {
    if (Get.isRegistered<HomeController>()) {
      return Get.find<HomeController>().contactUsModel?.phoneNumber ?? '';
    }
    return '';
  }

  Future<void> _openWhatsApp() async {
    final wa = _whatsappNumber.replaceAll(RegExp(r'[\s\-\(\)+]'), '');
    if (wa.isEmpty) {
      showAppSnackbar('تنبيه', 'رقم الواتساب غير متوفر حالياً');
      return;
    }
    final uri = Uri.parse('https://wa.me/$wa');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      showAppSnackbar('خطأ', 'تعذر فتح تطبيق الواتساب', isError: true);
    }
  }

  Future<void> _submitForm() async {
    if (isRecording) {
      await stopRecording();
    }

    if (!_formKey.currentState!.validate()) {
      if (_pieceName.text.trim().isEmpty) {
        showAppSnackbar('تحقق', 'يرجى إدخال اسم القطعة', isError: true);
        return;
      } else {
        showAppSnackbar('تحقق', 'يرجى تصحيح الحقول المطلوبة', isError: true);
        return;
      }
    }

    if (_images.isEmpty) {
      showAppSnackbar(
        'تحقق',
        'يرجى إضافة صورة واحدة على الأقل قبل الإرسال',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://www.salhly.lareenmedco.com/api/exchange-pieces/create',
        ),
      );

      String? token = App.prefs.getString('token');
      request.headers.addAll({
        'Accept': 'application/json',
        'Accept-Language': 'en',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields['pieces[0]'] = _pieceName.text.trim();
      request.fields['pieces[0][description]'] = _descriptionController.text.trim();

      // Audio
      if (audioFilePath != null) {
        final audioFile = File(audioFilePath!);
        if (await audioFile.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'pieces[0][voice_record]',
              audioFile.path,
              filename: p.basename(audioFile.path),
              contentType: MediaType('audio', 'm4a'),
            ),
          );
        }
      }

      // Images
      for (int i = 0; i < _images.length; i++) {
        final imageFile = _images[i];
        if (await imageFile.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'pieces[0][images][$i]',
              imageFile.path,
              filename: p.basename(imageFile.path),
            ),
          );
        }
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      dynamic data;
      try {
        data = jsonDecode(responseData);
      } catch (_) {
        showAppSnackbar(
          'خطأ',
          'استجابة غير متوقعة من الخادم.',
          isError: true,
        );
        setState(() => _isLoading = false);
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _pieceName.clear();
        _descriptionController.clear();
        _images.clear();
        deleteAudio();
        setState(() => _isLoading = false);

        Get.dialog(
          MaintenanceSuccessDialog(
            tagText: 'تم استلام طلب الاستبدال',
            title: 'شكراً لاختيارك صلحلي',
            subtitle:
                'طلبك قيد المراجعة والتقييم، وسيتم التواصل معك بالقطعة البديلة وفارق التكلفة.',
            bannerTitle: 'استبدال فوري وضمان',
            bannerHeader: 'قطع بديلة مفحوصة ومضمونة 🔄',
            bannerDesc:
                'نضمن لك فحص القطعة الجديدة والتأكد من مطابقتها التامة لراحتك.',
            primaryButtonText: 'طلبات الاستبدال',
            onPrimaryPressed: () {
              Get.back(); // close dialog
              Get.back(); // exit ExchangePieceView
              Get.to(() => const ExchangeRequestsView());
            },
            onHomePressed: () {
              Get.offAll(() => const HomeNavigationView());
            },
          ),
          barrierDismissible: false,
        );
        return;
      } else {
        showAppSnackbar(
          'خطأ',
          data['message'] ?? 'فشل في إرسال الطلب',
          isError: true,
        );
      }
    } catch (e) {
      showAppSnackbar('خطأ', 'حدث خطأ أثناء الإرسال', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          'استبدل قطعتك',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Banner
                  _buildTopBanner(primaryColor),
                  const SizedBox(height: 14),

                  // 2. Item Info Card
                  _buildBasicInfoCard(primaryColor),
                  const SizedBox(height: 14),

                  // 3. Description Card
                  _buildDescriptionCard(primaryColor),
                  const SizedBox(height: 14),

                  // 4. Attachments Card
                  _buildAttachmentsCard(primaryColor),
                  const SizedBox(height: 14),

                  // 5. Notice Card
                  _buildNoticeCard(primaryColor),
                  const SizedBox(height: 20),

                  // 6. Submit Button
                  _buildSubmitButton(primaryColor),
                  const SizedBox(height: 12),

                  // 7. WhatsApp Button
                  _buildWhatsAppButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        'جارٍ إرسال طلب الاستبدال...',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 1. Top Summary Banner
  Widget _buildTopBanner(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.swap_horiz_rounded,
              color: primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'استبدل قطعتك بسهولة',
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'استبدل قطعتك القديمة بقطعة جديدة مع تقييم الفارق ودفع الفرق فقط',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Basic Info Card
  Widget _buildBasicInfoCard(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'بيانات القطعة المراد استبدالها',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Name Input
          _buildInputField(
            controller: _pieceName,
            label: 'اسم ونوع القطعة الحالية',
            hint: 'مثال: كمبروسر 2 طن، بوردة ثلاجة...',
            icon: Icons.sync_alt_rounded,
            primaryColor: primaryColor,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'يرجى إدخال اسم القطعة'
                : null,
          ),
        ],
      ),
    );
  }

  // 3. Problem / Item Description Card
  Widget _buildDescriptionCard(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'تفاصيل القطعة والقطعة المطلوبة بدلها',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            style: GoogleFonts.cairo(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'اذكر حالة قطعتك الحالية وما هي القطعة أو المواصفات التي ترغب بالحصول عليها...',
              hintStyle: GoogleFonts.cairo(
                fontSize: 12.5,
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Attachments Card
  Widget _buildAttachmentsCard(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photos Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.photo_camera_back_outlined,
                    color: primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'صور القطعة',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (_images.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_images.length} صور',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Photos Grid
          SizedBox(
            height: 75,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _images.length + 1,
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _pickImages();
                    },
                    child: Container(
                      width: 75,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: primaryColor,
                            size: 24,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'إضافة صورة',
                            style: GoogleFonts.cairo(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final file = _images[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          file,
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 3,
                        right: 3,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 14),

          // Audio Header
          Row(
            children: [
              Icon(
                Icons.mic_none_rounded,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'تسجيل صوتي (اختياري)',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Audio Controls
          if (audioFilePath != null && !isRecording)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: isPlaying ? stopAudio : playAudio,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تم حفظ التسجيل الصوتي',
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          isPlaying
                              ? '${_formatDuration(playbackPosition)} / ${_formatDuration(playbackDuration)}'
                              : 'جاهز للإرسال مع الطلب',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: deleteAudio,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                isRecording ? stopRecording() : startRecording();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isRecording
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isRecording
                        ? Colors.redAccent
                        : primaryColor.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isRecording
                          ? Icons.stop_circle_rounded
                          : Icons.mic_rounded,
                      color: isRecording ? Colors.redAccent : primaryColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isRecording
                          ? 'جارٍ التسجيل: $recordingDurationStr (اضغط للإيقاف)'
                          : 'اضغط لتسجيل صوتي يشرح طلب الاستبدال بدقة',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isRecording
                            ? Colors.redAccent
                            : primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 5. Reassurance Notice Card
  Widget _buildNoticeCard(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: primaryColor,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'عند الوصف بشكل دقيق وإرفاق صور واضحة وتسجيل صوتي، يمكننا تقدير فارق السعر والتواصل معك بشكل أسرع.',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: const Color(0xFF1E40AF),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 6. Submit Button
  Widget _buildSubmitButton(Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () {
                HapticFeedback.heavyImpact();
                _submitForm();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.send_rounded, size: 18),
            const SizedBox(width: 8),
            Text(
              'إرسال طلب الاستبدال',
              style: GoogleFonts.cairo(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 7. WhatsApp Button
  Widget _buildWhatsAppButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _openWhatsApp();
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.06),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFF16A34A),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'تواصل عبر واتساب للتفاوض المباشر',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.cairo(fontSize: 13.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(
              fontSize: 12.5,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, color: primaryColor, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
