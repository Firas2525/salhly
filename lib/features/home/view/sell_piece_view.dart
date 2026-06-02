import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/core/utils/ui_utils.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app.dart';
import '../controller/home_controller.dart';

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

  List<File> _images = [];
  bool _isLoading = false;

  // Audio recording & playback
  final Record _recorder = Record();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? audioFilePath;
  bool isRecording = false;
  bool isPlaying = false;

  // recording timer
  Duration recordingDuration = Duration.zero;
  Timer? _recordTimer;

  // playback tracking
  Duration playbackDuration = Duration.zero;
  Duration playbackPosition = Duration.zero;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _positionSub;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final source = await Get.bottomSheet<ImageSource?>(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.black87),
              title: const Text('التصوير بالكاميرا'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.black87),
              title: const Text('اختيار من المعرض'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.redAccent),
              title: const Text(
                'إلغاء',
                style: TextStyle(color: Colors.redAccent),
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
      if (pickedFiles != null) {
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
    } catch (e, st) {
      print('startRecording error: $e');
      print(st);
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
    } catch (e, st) {
      print('stopRecording error: $e');
      print(st);
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
    } catch (e, st) {
      print('playAudio error: $e');
      print(st);
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
    } catch (e, st) {
      print('stopAudio error: $e');
      print(st);
    }
  }

  Future<void> seekAudio(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      playbackPosition = position;
      setState(() {});
    } catch (e, st) {
      print('seekAudio error: $e');
      print(st);
    }
  }

  String get recordingDurationStr {
    final minutes = recordingDuration.inMinutes.toString().padLeft(2, '0');
    final seconds = (recordingDuration.inSeconds % 60).toString().padLeft(
      2,
      '0',
    );
    return '$minutes:$seconds';
  }

  Future<void> _submitForm() async {
    if (isRecording) {
      await stopRecording();
    }

    if (!_formKey.currentState!.validate()) {
      if (_nameController.text.isEmpty) {
        showAppSnackbar('تحقق', 'يرجى إدخال اسم القطعة', isError: true);
        return;
      } else if (_priceController.text.isEmpty) {
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

      // fields
      request.fields['pieces[0]'] = _nameController.text;
      request.fields['pieces[0][expected_price]'] = _priceController.text;
      request.fields['pieces[0][description]'] = _descriptionController.text;

      // attach audio if present
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
        } else {
          print('Audio file does not exist: $audioFilePath');
        }
      }

      // attach images
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

      // Logging request summary
      try {
        print('Submitting sell request to: ${request.url}');
        print('Headers: ${request.headers}');
        print('Fields: ${request.fields}');
        print('Files count: ${request.files.length}');
      } catch (_) {}

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print('Sell submit response status: ${response.statusCode}');
      // Truncate long HTML responses in logs
      final truncated = responseData.length > 200
          ? responseData.substring(0, 200) + '... (truncated)'
          : responseData;
      print('Sell submit response body (truncated): $truncated');

      // Try parse JSON; if it's not JSON, handle gracefully
      dynamic data;
      try {
        data = jsonDecode(responseData);
      } on FormatException catch (fe) {
        print('submitForm parse error: $fe');
        showAppSnackbar(
          'خطأ',
          'الخادم أعاد استجابة غير متوقعة (صفحة HTML أو خطأ).',
          isError: true,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final successMessage = data['message'] ?? 'تم إرسال طلب البيع بنجاح';

      if (response.statusCode == 200 || response.statusCode == 201) {
        showAppSnackbar('نجح', successMessage);
        await Future.delayed(const Duration(seconds: 3));
        Get.back();
      } else {
        showAppSnackbar(
          'خطأ',
          data['message'] ?? 'فشل في إرسال الطلب',
          isError: true,
        );
      }
    } catch (e, st) {
      print('submitForm error: $e');
      print(st);
      showAppSnackbar('خطأ', 'حدث خطأ أثناء الإرسال', isError: true);
    }

    setState(() {
      _isLoading = false;
    });
  }

  String get _whatsappNumber {
    if (Get.isRegistered<HomeController>()) {
      return Get.find<HomeController>().contactUsModel?.phoneNumber ?? '';
    }
    return '';
  }

  Future<void> _openWhatsApp() async {
    final wa = _whatsappNumber;
    if (wa.isEmpty) return;
    await launchUrl(Uri.parse('https://wa.me/$wa'));
  }

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

  @override
  Widget build(BuildContext context) {
    final mainColor = AppColors.four;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
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
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        'بيع قطعتك',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 35),

                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image(
                            image: AssetImage('assets/images/12.jpg'),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.four.withOpacity(0.6),
                                AppColors.four,
                              ],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Container(
                              margin: EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 0.8,
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.sell,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "بيع قطعتك بسهولة",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Text(
                                "املأ البيانات وأرفق صور وتسجيل صوتي إن أمكن",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Personal info card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'البيانات الأساسية',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'اسم القطعة',
                              prefixIcon: Icon(
                                Icons.inventory,
                                color: AppColors.four,
                              ),
                              filled: true,
                              fillColor: AppColors.four.withOpacity(0.04),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.four),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'يرجى إدخال اسم القطعة';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'السعر المتوقع',
                              prefixIcon: Icon(
                                Icons.attach_money,
                                color: AppColors.four,
                              ),
                              filled: true,
                              fillColor: AppColors.four.withOpacity(0.04),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.four),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'يرجى إدخال السعر المتوقع';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Details card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تفاصيل إضافية',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),

                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount: _images.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _images.length) {
                                return GestureDetector(
                                  onTap: _pickImages,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.four.withOpacity(0.5),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          color: AppColors.four,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'اضافة صورة',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.four,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _images[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red.withOpacity(0.9),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 12),
                          // Audio recording section
                          Text(
                            'تسجيل صوتي (اختياري)',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: isRecording
                                        ? stopRecording
                                        : startRecording,
                                    child: Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: mainColor.withOpacity(0.5),
                                          width: 2,
                                        ),
                                        color: isRecording
                                            ? Colors.red.withOpacity(0.1)
                                            : Colors.grey.shade100,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          isRecording ? Icons.stop : Icons.mic,
                                          size: 28,
                                          color: isRecording
                                              ? Colors.red
                                              : mainColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!isRecording &&
                                      audioFilePath != null) ...[
                                    const SizedBox(width: 10),
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 72,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color: Colors.grey.shade100,
                                            border: Border.all(
                                              color: mainColor.withOpacity(0.5),
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: IconButton(
                                              onPressed: isPlaying
                                                  ? stopAudio
                                                  : playAudio,
                                              icon: Icon(
                                                isPlaying
                                                    ? Icons.pause_circle_filled
                                                    : Icons.play_circle_fill,
                                                color: mainColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: -6,
                                          right: -6,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                audioFilePath = null;
                                                isPlaying = false;
                                                playbackPosition =
                                                    Duration.zero;
                                                playbackDuration =
                                                    Duration.zero;
                                              });
                                            },
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isRecording
                                    ? 'جاري التسجيل: $recordingDurationStr'
                                    : audioFilePath != null
                                    ? 'مدة التسجيل: $recordingDurationStr'
                                    : 'اضغط على الميكروفون لتسجيل صوت',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'اكتب وصفاً قصيراً للقطعة...',
                              prefixIcon: Icon(
                                Icons.note,
                                color: AppColors.four,
                              ),
                              filled: true,
                              fillColor: AppColors.four.withOpacity(0.04),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.four),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  mainColor.withOpacity(0.97),
                                  mainColor.withOpacity(0.80),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: mainColor.withOpacity(0.13),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.info,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ملاحظة',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'عند الوصف بشكل دقيق و ارفاق صورة و صوت يمكننا تقدير السعر بشكل أفضل',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Submit button
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _isLoading
                                      ? 'جارٍ الإرسال...'
                                      : 'إرسال الطلب',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'أو',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _openWhatsApp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                'تواصل على واتس اب',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.four),
              ),
            ),
        ],
      ),
    );
  }
}
