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
import '../sell_requests/sell_requests_view.dart';
import 'home_navigation_view.dart';

class SellPieceView extends StatefulWidget {
  const SellPieceView({super.key});

  @override
  State<SellPieceView> createState() => _SellPieceViewState();
}

class _SellPieceViewState extends State<SellPieceView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<File> _images = [];
  String _selectedCurrency = 'SYP';
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
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _recordTimer?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _audioPlayer.dispose();
    _recorder.dispose();
    super.dispose();
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

  void _removeImage(int index) {
    if (index >= 0 && index < _images.length) {
      setState(() {
        _images.removeAt(index);
      });
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
          '${dir.path}/salhly_sell_record_${DateTime.now().millisecondsSinceEpoch}.m4a';
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
      if (_nameController.text.trim().isEmpty) {
        showAppSnackbar('تحقق', 'يرجى إدخال اسم القطعة', isError: true);
        return;
      } else if (_priceController.text.trim().isEmpty) {
        showAppSnackbar('تحقق', 'يرجى إدخال السعر المتوقع', isError: true);
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
        Uri.parse('https://www.salhly.lareenmedco.com/api/sell-pieces/create'),
      );

      String? token = App.prefs.getString('token');
      request.headers.addAll({
        'Accept': 'application/json',
        'Accept-Language': 'en',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields['pieces[0]'] = _nameController.text.trim();
      request.fields['pieces[0][expected_price]'] = _priceController.text.trim();
      request.fields['pieces[0][description]'] = _descriptionController.text.trim();
      request.fields['pieces[0][currency]'] = _selectedCurrency;

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
        _nameController.clear();
        _priceController.clear();
        _descriptionController.clear();
        _selectedCurrency = 'SYP';
        _images.clear();
        deleteAudio();
        setState(() => _isLoading = false);

        Get.dialog(
          MaintenanceSuccessDialog(
            tagText: 'تم استلام طلب البيع',
            title: 'شكراً لاختيارك صلحلي',
            subtitle:
                'طلبك قيد المراجعة والتقييم من قبل فريقنا، وسيتم التواصل معك بأسرع وقت.',
            bannerTitle: 'تقييم فوري وعادل',
            bannerHeader: 'أفضل سعر لقطعتك مع صلحلي 💼',
            bannerDesc:
                'ندرس تفاصيل وحالة القطعة بدقة لتقديم أفضل عرض شراء لك.',
            primaryButtonText: 'طلبات البيع',
            onPrimaryPressed: () {
              Get.back(); // close dialog
              Get.back(); // exit SellPieceView
              Get.to(() => const SellRequestsView());
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
          'بيع قطعتك',
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
                        'جارٍ إرسال طلب البيع...',
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
              Icons.monetization_on_outlined,
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
                  'بيع قطعتك بسهولة',
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'املأ البيانات وأرفق صور القطعة لتخمين السعر والشراء منك فوراً',
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
                'بيانات القطعة',
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
            controller: _nameController,
            label: 'اسم ونوع القطعة',
            hint: 'مثال: كمبروسر مكيف، موتور غسالة...',
            icon: Icons.sell_outlined,
            primaryColor: primaryColor,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'يرجى إدخال اسم القطعة'
                : null,
          ),
          const SizedBox(height: 14),

          // Currency Selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.currency_exchange_rounded,
                    color: primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'عملة السعر المطلوب',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    // SYP Option
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCurrency = 'SYP';
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _selectedCurrency == 'SYP'
                                ? primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedCurrency == 'SYP'
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '🇸🇾 ليرة سورية (SYP)',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedCurrency == 'SYP'
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // USD Option
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCurrency = 'USD';
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _selectedCurrency == 'USD'
                                ? primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedCurrency == 'USD'
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '💵 دولار أمريكي (USD)',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedCurrency == 'USD'
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Price Input
          _buildInputField(
            controller: _priceController,
            label: _selectedCurrency == 'USD'
                ? 'السعر المتوقع (بالدولار الأمريكي \$)'
                : 'السعر المتوقع (بالليرة السورية)',
            hint: _selectedCurrency == 'USD'
                ? 'أدخل السعر المطلوب بالدولار (مثال: 100)'
                : 'أدخل السعر المطلوب بالليرة (مثال: 1500000)',
            icon: Icons.payments_outlined,
            keyboardType: TextInputType.number,
            primaryColor: primaryColor,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'يرجى إدخال السعر المتوقع'
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
                'حالة ووصف القطعة (اختياري)',
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
              hintText: 'اذكر حالة القطعة (مستعملة، بحالة جيدة، تحتاج صيانة خفيفة)...',
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
                          : 'اضغط لتسجيل صوتي يشرح حالة القطعة',
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
              'عند الوصف بشكل دقيق وإرفاق صور واضحة وتسجيل صوتي، يمكننا تقدير السعر والتواصل معك بشكل أسرع.',
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
              'إرسال طلب البيع',
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
