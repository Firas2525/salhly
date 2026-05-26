import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app.dart';
import '../../../core/utils/app_api.dart';
import '../../../core/utils/ui_utils.dart';
import '../model/service_model.dart';

class RequestServiceController extends GetxController {
  // Loading state
  bool isLoading = false;

  // Form controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Service IDs
  late int serviceId;
  int? selectedSubServiceId;

  // Subservices list
  List<SubServiceModel> subServices = [];

  // Images (support multiple)
  List<File> imageFiles = [];

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

  // Fetch sub-services for a service id
  Future<void> getService(int id) async {
    isLoading = true;
    update();

    try {
      String? token = App.prefs.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': 'ar',
      };
      var uri = Uri.parse("${AppApi.baseUrl}/service/get_SubService?service_id=$id");

      var request = http.Request('GET', uri);
      request.headers.addAll(headers);
      var response = await request.send();

      var data = jsonDecode(await response.stream.bytesToString());
      final List<dynamic> dataList = data['data'];

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 210) {
        subServices = dataList.map((e) => SubServiceModel.fromJson(e)).toList();
      } else {
        showAppSnackbar("خطأ", data['message'] ?? "حدث خطأ");
      }
    } catch (e) {
      print(e);
      showAppSnackbar("خطأ", "حدث خطأ أثناء الاتصال. حاول لاحقًا.");
    }

    isLoading = false;
    update();
  }

  Future<void> seekAudio(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      playbackPosition = position;
      update();
    } catch (e) {
      print(e);
    }
  }

  @override
  void onInit() {
    // allow passing via Get.arguments OR set later by the page
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      if (args.containsKey('serviceId')) serviceId = args['serviceId'];
      if (args.containsKey('subServiceId')) selectedSubServiceId = args['subServiceId'];
    }

    super.onInit();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    // اختر مصدر الصورة عبر Bottom Sheet أنظف مع أيقونات وزر إلغاء
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
              title: const Text('إلغاء', style: TextStyle(color: Colors.redAccent)),
              onTap: () => Get.back(result: null),
            ),
          ],
        ),
      ),
      isDismissible: true,
      backgroundColor: Colors.transparent,
    );

    if (source == null) return;

    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 75,
    );

    if (picked != null) {
      imageFiles.add(File(picked.path));
      update();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < imageFiles.length) {
      imageFiles.removeAt(index);
      update();
    }
  }

  // Audio recording
  Future<void> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/salhly_record_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(path: filePath, encoder: AudioEncoder.aacLc);
        audioFilePath = filePath;
        isRecording = true;
        // start recording timer
        recordingDuration = Duration.zero;
        _recordTimer?.cancel();
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
          recordingDuration = recordingDuration + const Duration(seconds: 1);
          update();
        });
        update();
      } else {
        showAppSnackbar('خطأ', 'لا يوجد صلاحيات لتسجيل الصوت');
      }
    } catch (e) {
      print(e);
      showAppSnackbar('خطأ', 'فشل بدء التسجيل');
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await _recorder.stop();
      isRecording = false;
      _recordTimer?.cancel();
      _recordTimer = null;
      // path may be null when using internal storage; keep audioFilePath if set
      if (path != null) audioFilePath = path;
      update();
    } catch (e) {
      print(e);
      showAppSnackbar('خطأ', 'فشل إيقاف التسجيل');
    }
  }

  Future<void> playAudio() async {
    if (audioFilePath == null) return;
    try {
      isPlaying = true;
      update();
      // listen for duration and position updates
      _durationSub?.cancel();
      _positionSub?.cancel();
      _durationSub = _audioPlayer.onDurationChanged.listen((d) {
        playbackDuration = d;
        update();
      });
      _positionSub = _audioPlayer.onPositionChanged.listen((p) {
        playbackPosition = p;
        update();
      });

      await _audioPlayer.play(DeviceFileSource(audioFilePath!));
      _audioPlayer.onPlayerComplete.listen((_) {
        isPlaying = false;
        playbackPosition = Duration.zero;
        update();
      });
    } catch (e) {
      print(e);
      isPlaying = false;
      update();
      showAppSnackbar('خطأ', 'فشل تشغيل الصوت');
    }
  }

  @override
  void onClose() {
    _recordTimer?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    try {
      _audioPlayer.dispose();
    } catch (_) {}
    super.onClose();
  }

  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    isPlaying = false;
    playbackPosition = Duration.zero;
    _durationSub?.cancel();
    _positionSub?.cancel();
    update();
  }

  Future<void> deleteAudio() async {
    try {
      await stopAudio();
      if (audioFilePath != null) {
        final f = File(audioFilePath!);
        if (await f.exists()) await f.delete();
      }
      audioFilePath = null;
      playbackDuration = Duration.zero;
      playbackPosition = Duration.zero;
      update();
    } catch (e) {
      print(e);
    }
  }

  String get recordingDurationStr {
    final m = recordingDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = recordingDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // Validation: require name/phone/address and at least one of (description, image, audio)
  bool validateInputs() {
    if (fullNameController.text.trim().isEmpty) {
      showAppSnackbar('تحقق', 'الرجاء إدخال الاسم الكامل');
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      showAppSnackbar('تحقق', 'الرجاء إدخال رقم الهاتف');
      return false;
    }
    if (addressController.text.trim().isEmpty) {
      showAppSnackbar('تحقق', 'الرجاء إدخال العنوان');
      return false;
    }

    final hasDescription = descriptionController.text.trim().isNotEmpty;
    final hasImage = imageFiles.isNotEmpty;
    final hasAudio = audioFilePath != null;

    if (!hasDescription && !hasImage && !hasAudio) {
      showAppSnackbar('تحقق', 'الرجاء إضافة وصف أو صورة أو تسجيل صوتي واحد على الأقل');
      return false;
    }

    return true;
  }

  // Submit order: multipart/form-data
  Future<void> submitOrder() async {
    if (!validateInputs()) return;

    isLoading = true;
    update();

    try {
      String? token = App.prefs.getString('token');
      var uri = Uri.parse('https://www.salhly.lareenmedco.com/api/order/create_maintenance');
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields['full_name'] = fullNameController.text.trim();
      request.fields['phone_number'] = phoneController.text.trim();
      request.fields['address'] = addressController.text.trim();
      request.fields['service_id'] = serviceId.toString();
      if (selectedSubServiceId != null) request.fields['sub_service_id'] = selectedSubServiceId.toString();
      if (descriptionController.text.trim().isNotEmpty) request.fields['description'] = descriptionController.text.trim();

      for (var imageFile in imageFiles) {
        request.files.add(await http.MultipartFile.fromPath('files[]', imageFile.path));
      }
      if (audioFilePath != null) {
        request.files.add(await http.MultipartFile.fromPath('files[]', audioFilePath!));
      }

      final streamed = await request.send();
      final respStr = await streamed.stream.bytesToString();
      final respJson = jsonDecode(respStr);
       print(respJson);
      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        showAppSnackbar('نجاح', respJson['message'] ?? 'تم إرسال الطلب بنجاح');
        // Clear form
        fullNameController.clear();
        phoneController.clear();
        addressController.clear();
        descriptionController.clear();
        imageFiles.clear();
        await deleteAudio();
      } else if (streamed.statusCode == 401) {
        showAppSnackbar('تنبيه', 'غير مصرح. الرجاء تسجيل الدخول مجدداً');
      } else {
        showAppSnackbar('خطأ', respJson['message'] ?? 'حدث خطأ أثناء الإرسال');
      }
    } catch (e) {
      print(e);
      showAppSnackbar('خطأ', 'فشل ارسال الطلب. حاول لاحقًا.');
    }

    isLoading = false;
    update();
  }
}
