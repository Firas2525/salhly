import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../app.dart';
import '../../../core/utils/app_api.dart';
import '../../../core/utils/ui_utils.dart';
import '../../auth/view/login.dart';
import '../../home/controller/home_controller.dart';
import '../../home/model/service_model.dart';
import '../../service/model/service_model.dart';
import 'home_worker_controller.dart';

class CreateWorkerMaintenanceController extends GetxController {
  bool isLoading = false;
  bool isLoadingServices = false;
  bool isLoadingSubServices = false;

  // Form Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController reportDescriptionController = TextEditingController();
  final TextEditingController amountPaidController = TextEditingController();
  final TextEditingController repairPercentageController = TextEditingController();

  // Services & Subservices
  List<ServicesModel> services = [];
  List<SubServiceModel> subServices = [];

  ServicesModel? selectedService;
  SubServiceModel? selectedSubService;

  // Issue Media (files[...])
  List<File> imageFiles = [];

  // Report Media (report_files[...])
  List<File> reportFiles = [];

  // Audio Recording & Playback
  final Record _recorder = Record();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? audioFilePath;
  bool isRecording = false;
  bool isPlaying = false;
  Duration recordingDuration = Duration.zero;
  Timer? _recordTimer;
  Duration playbackDuration = Duration.zero;
  Duration playbackPosition = Duration.zero;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _positionSub;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    reportDescriptionController.dispose();
    amountPaidController.dispose();
    repairPercentageController.dispose();

    _recordTimer?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    try {
      _audioPlayer.dispose();
    } catch (_) {}
    super.onClose();
  }

  // 1. Load all services (Standard + Golden)
  Future<void> loadServices() async {
    // Check if HomeController already has services or goldenServices
    final List<ServicesModel> initialList = [];
    if (Get.isRegistered<HomeController>()) {
      final homeCtrl = Get.find<HomeController>();
      if (homeCtrl.goldenServices.isNotEmpty) {
        initialList.addAll(homeCtrl.goldenServices.map((s) => ServicesModel(
              id: s.id,
              title: s.title,
              image: s.image,
              isGolden: true,
            )));
      }
      if (homeCtrl.services.isNotEmpty) {
        for (var s in homeCtrl.services) {
          if (!initialList.any((e) => e.id == s.id)) {
            initialList.add(ServicesModel(
              id: s.id,
              title: s.title,
              image: s.image,
              isGolden: false,
            ));
          }
        }
      }
    }

    if (initialList.isNotEmpty) {
      services = initialList;
      update();
    }

    isLoadingServices = services.isEmpty;
    update();

    try {
      final token = App.prefs.getString('token');
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Accept-Language': 'ar',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      // 1. Fetch Golden Services
      final goldenUri = Uri.parse(AppApi.getGoldenServices);
      print("\n--- [Fetch Golden Services] -> $goldenUri");
      final goldenResp = await http.get(goldenUri, headers: headers);
      print("--- [Golden Services Status] -> ${goldenResp.statusCode}");
      final List<ServicesModel> fetchedGolden = [];
      if (goldenResp.statusCode >= 200 && goldenResp.statusCode < 300) {
        final gData = jsonDecode(goldenResp.body);
        final dynamic gList = gData is Map ? (gData['data'] ?? gData['services']) : gData;
        if (gList is List) {
          fetchedGolden.addAll(gList.map((e) => ServicesModel.fromJson(e as Map<String, dynamic>, isGolden: true)));
        }
      }

      // 2. Fetch Regular Services
      final regularUri = Uri.parse("${AppApi.baseUrl}/service/get");
      print("--- [Fetch Regular Services] -> $regularUri");
      final regularResp = await http.get(regularUri, headers: headers);
      print("--- [Regular Services Status] -> ${regularResp.statusCode}");
      final List<ServicesModel> fetchedRegular = [];
      if (regularResp.statusCode >= 200 && regularResp.statusCode < 300) {
        final rData = jsonDecode(regularResp.body);
        final dynamic rList = rData is Map ? (rData['data'] ?? rData['services']) : rData;
        if (rList is List) {
          fetchedRegular.addAll(rList.map((e) => ServicesModel.fromJson(e as Map<String, dynamic>, isGolden: false)));
        }
      }

      // 3. Fallback: if regular is empty, try HomeController or /services endpoint
      if (fetchedRegular.isEmpty && fetchedGolden.isEmpty) {
        try {
          final fallbackUri = Uri.parse("${AppApi.baseUrl}/services");
          final fallbackResp = await http.get(fallbackUri, headers: headers);
          if (fallbackResp.statusCode >= 200 && fallbackResp.statusCode < 300) {
            final fbData = jsonDecode(fallbackResp.body);
            final dynamic fbList = fbData is Map ? (fbData['data'] ?? fbData['services']) : fbData;
            if (fbList is List) {
              fetchedRegular.addAll(fbList.map((e) => ServicesModel.fromJson(e as Map<String, dynamic>, isGolden: false)));
            }
          }
        } catch (_) {}
      }

      // 4. Merge: Golden services first, then Regular services (no duplicate IDs)
      final List<ServicesModel> merged = [];
      for (var g in fetchedGolden) {
        if (!merged.any((e) => e.id == g.id)) {
          merged.add(g);
        }
      }
      for (var r in fetchedRegular) {
        if (!merged.any((e) => e.id == r.id)) {
          merged.add(r);
        }
      }

      if (merged.isNotEmpty) {
        services = merged;
      }
      print("--- Total Services Loaded: ${services.length} (${fetchedGolden.length} golden, ${fetchedRegular.length} regular)\n");
    } catch (e) {
      print('Error loading services in CreateWorkerMaintenanceController: $e');
    } finally {
      isLoadingServices = false;
      update();
    }
  }

  // 2. Select service and load its sub-services
  void onSelectService(ServicesModel service) {
    selectedService = service;
    selectedSubService = null;
    subServices.clear();
    loadSubServices(service.id);
    update();
  }

  Future<void> loadSubServices(int serviceId) async {
    isLoadingSubServices = true;
    update();

    try {
      final token = App.prefs.getString('token');
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Accept-Language': 'ar',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      final uri = Uri.parse("${AppApi.baseUrl}/service/get_SubService?service_id=$serviceId");
      print("\n--- [Fetch Sub Services for serviceId=$serviceId] -> $uri");

      final response = await http.get(uri, headers: headers);
      print("--- [Sub Services Status] -> ${response.statusCode}");
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final dynamic rawList = data is Map ? (data['data'] ?? data['sub_services']) : data;
        if (rawList is List) {
          subServices = rawList.map((e) => SubServiceModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      print("--- Sub Services Loaded: ${subServices.length}\n");
    } catch (e) {
      print('Error loading subservices: $e');
    } finally {
      isLoadingSubServices = false;
      update();
    }
  }

  void onSelectSubService(SubServiceModel subService) {
    selectedSubService = subService;
    update();
  }

  // 3. Image Handling
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    final source = await Get.bottomSheet<ImageSource?>(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Colors.blue),
              title: const Text('التصوير بالكاميرا'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Colors.blue),
              title: const Text('اختيار من المعرض'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.close_rounded, color: Colors.redAccent),
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
      imageQuality: 80,
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

  // Report Images Handling (report_files)
  Future<void> pickReportImage() async {
    final ImagePicker picker = ImagePicker();

    final source = await Get.bottomSheet<ImageSource?>(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF16A34A)),
              title: const Text('التصوير بالكاميرا'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF16A34A)),
              title: const Text('اختيار من المعرض'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.close_rounded, color: Colors.redAccent),
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
      imageQuality: 80,
    );

    if (picked != null) {
      reportFiles.add(File(picked.path));
      update();
    }
  }

  void removeReportImage(int index) {
    if (index >= 0 && index < reportFiles.length) {
      reportFiles.removeAt(index);
      update();
    }
  }

  // 4. Audio Recording
  Future<void> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/salhly_worker_order_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(path: filePath, encoder: AudioEncoder.aacLc);
        audioFilePath = filePath;
        isRecording = true;
        recordingDuration = Duration.zero;
        _recordTimer?.cancel();
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
          recordingDuration = recordingDuration + const Duration(seconds: 1);
          update();
        });
        update();
      } else {
        showAppSnackbar('خطأ', 'لا يوجد إذن لتسجيل الصوت', isError: true);
      }
    } catch (e) {
      print('Error startRecording: $e');
      showAppSnackbar('خطأ', 'فشل بدء تسجيل الصوت', isError: true);
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await _recorder.stop();
      isRecording = false;
      _recordTimer?.cancel();
      _recordTimer = null;
      if (path != null) audioFilePath = path;
      update();
    } catch (e) {
      print('Error stopRecording: $e');
    }
  }

  Future<void> playAudio() async {
    if (audioFilePath == null) return;
    try {
      isPlaying = true;
      update();
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
      print('Error playAudio: $e');
      isPlaying = false;
      update();
      showAppSnackbar('خطأ', 'فشل تشغيل التسجيل الصوتي', isError: true);
    }
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

  Future<void> seekAudio(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      playbackPosition = position;
      update();
    } catch (_) {}
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

  // 5. Validation
  bool validate() {
    print("\n🔍 --- [Validating External Order Form] ---");
    if (fullNameController.text.trim().isEmpty) {
      print("❌ Validation Failed: Full name is empty");
      showAppSnackbar('تنبيه', 'يرجى إدخال اسم العميل', isError: true);
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      print("❌ Validation Failed: Phone number is empty");
      showAppSnackbar('تنبيه', 'يرجى إدخال رقم هاتف العميل', isError: true);
      return false;
    }
    if (addressController.text.trim().isEmpty) {
      print("❌ Validation Failed: Address is empty");
      showAppSnackbar('تنبيه', 'يرجى إدخال عنوان موقع الصيانة', isError: true);
      return false;
    }
    if (selectedService == null) {
      print("❌ Validation Failed: Service not selected");
      showAppSnackbar('تنبيه', 'يرجى تحديد نوع الخدمة الأساسية', isError: true);
      return false;
    }
    if (amountPaidController.text.trim().isEmpty) {
      print("❌ Validation Failed: Amount paid is empty");
      showAppSnackbar('تنبيه', 'يرجى إدخال المبلغ المدفوع / المقبوض', isError: true);
      return false;
    }
    if (repairPercentageController.text.trim().isEmpty) {
      print("❌ Validation Failed: Repair percentage is empty");
      showAppSnackbar('تنبيه', 'يرجى إدخال نسبة صلحلي (%)', isError: true);
      return false;
    }
    if (reportDescriptionController.text.trim().isEmpty) {
      print("❌ Validation Failed: Report description is empty");
      showAppSnackbar('تنبيه', 'يرجى كتابة تقرير الصيانة المنفذة', isError: true);
      return false;
    }
    print("✅ Form Validation Passed Successfully!");
    return true;
  }

  // 6. Submit Order by Worker
  Future<void> submitWorkerOrder() async {
    print("\n================== 🔘 [BUTTON PRESSED: Submit Worker Order] ==================");
    if (!validate()) {
      print("==============================================================================\n");
      return;
    }

    isLoading = true;
    update();

    try {
      String? token = App.prefs.getString('token');
      var uri = Uri.parse("${AppApi.baseUrl}/order/create_maintenance_by_worker");

      var request = http.MultipartRequest('POST', uri);
      final headers = {
        if (token != null) 'Authorization': 'Bearer $token',
        'Country-Id': '1',
        'Accept': 'application/json',
        'Accept-Language': 'ar',
      };
      request.headers.addAll(headers);

      final fullName = fullNameController.text.trim();
      final phoneNumber = phoneController.text.trim();
      final address = addressController.text.trim();
      final serviceIdStr = selectedService!.id.toString();
      final subServiceIdStr = selectedSubService?.id.toString();
      final description = descriptionController.text.trim().isNotEmpty
          ? descriptionController.text.trim()
          : (reportDescriptionController.text.trim());
      final reportDescription = reportDescriptionController.text.trim();
      final amountPaid = amountPaidController.text.trim();
      final repairPercentage = repairPercentageController.text.trim();

      request.fields['full_name'] = fullName;
      request.fields['phone_number'] = phoneNumber;
      request.fields['address'] = address;
      request.fields['service_id'] = serviceIdStr;
      if (subServiceIdStr != null && subServiceIdStr.isNotEmpty) {
        request.fields['sub_service_id'] = subServiceIdStr;
      }
      request.fields['description'] = description;
      request.fields['report_description'] = reportDescription;
      request.fields['amount_paid'] = amountPaid;
      request.fields['repair_percentage'] = repairPercentage;

      // Add issue media attachments (files[...])
      for (int i = 0; i < imageFiles.length; i++) {
        if (imageFiles[i].existsSync()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'files[$i]',
              imageFiles[i].path,
            ),
          );
        }
      }

      // Add audio recording if present (files[index])
      if (audioFilePath != null) {
        int audioIndex = imageFiles.length;
        request.files.add(
          await http.MultipartFile.fromPath(
            'files[$audioIndex]',
            audioFilePath!,
          ),
        );
      }

      // Add report completion files (report_files[...])
      for (int i = 0; i < reportFiles.length; i++) {
        if (reportFiles[i].existsSync()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'report_files[$i]',
              reportFiles[i].path,
            ),
          );
        }
      }

      // Print cURL command to console as requested
      final curl = StringBuffer()
        ..writeln("curl --location '$uri' \\")
        ..writeln(headers.entries.map((e) => "--header '${e.key}: ${e.value}'").join(' \\\n'))
        ..writeln(" \\")
        ..writeln(request.fields.entries.map((e) => "--form '${e.key}=\"${e.value}\"'").join(' \\\n'));

      for (var f in request.files) {
        curl.writeln(" \\\n--form '${f.field}=@\"${f.filename}\"'");
      }

      print("\n================== cURL [Create Maintenance By Worker] ==================");
      print(curl.toString());
      print("==========================================================================\n");

      final streamed = await request.send();
      final responseBody = await streamed.stream.bytesToString();

      print("\n================== [RESPONSE: Create Maintenance By Worker] ==================");
      print("📥 Status Code: ${streamed.statusCode}");
      print("📄 Raw Body:\n$responseBody");
      print("==============================================================================\n");

      if (streamed.statusCode == 401 || streamed.statusCode == 403) {
        await App.prefs.clear();
        Get.offAll(() => Login());
        return;
      }

      dynamic data;
      try {
        data = jsonDecode(responseBody);
        const encoder = JsonEncoder.withIndent('  ');
        print("📊 Decoded JSON:\n${encoder.convert(data)}\n==============================================================================\n");
      } catch (e) {
        print("⚠️ Response is not valid JSON: $e");
      }

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        final msg = data is Map ? (data['message'] ?? 'تم إنشاء طلب الصيانة والتقرير بنجاح') : 'تم إنشاء طلب الصيانة والتقرير بنجاح';
        final orderId = data is Map && data['data'] != null ? data['data']['id'] : null;

        // Refresh orders in HomeWorkerController if registered
        if (Get.isRegistered<HomeWorkerController>()) {
          Get.find<HomeWorkerController>().refreshAllOrders();
        }

        // Show Success Dialog
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF16A34A),
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تم تسجيل الطلب بنجاح',
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (orderId != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'رقم الطلب: #$orderId',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // close dialog
                        Get.back(); // close CreateWorkerMaintenanceView
                        showAppSnackbar('نجاح', msg);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'العودة للرئيسية',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      } else {
        final errorMsg = data is Map ? (data['message'] ?? 'فشل تسجيل الطلب، يرجى المحاولة ثانية') : 'فشل تسجيل الطلب (كود: ${streamed.statusCode})';
        showAppSnackbar(
          'خطأ',
          errorMsg,
          isError: true,
        );
      }
    } catch (e) {
      print('Exception in submitWorkerOrder: $e');
      showAppSnackbar('خطأ', 'حدث خطأ أثناء الاتصال بالخادم. حاول لاحقاً.', isError: true);
    } finally {
      isLoading = false;
      update();
    }
  }
}
