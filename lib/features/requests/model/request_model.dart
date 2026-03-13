import 'package:salhly/core/utils/app_api.dart';


class ServiceModel {
  final int id;
  final String name;
  final String image;

  ServiceModel({required this.id, required this.name, required this.image});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['title'] ?? "",
      image: json['image'] ?? "",
    );
  }
}

class SubServiceModel {
  final int id;
  final String name;
  final String image;

  SubServiceModel({required this.id, required this.name, required this.image});

  factory SubServiceModel.fromJson(Map<String, dynamic> json) {
    return SubServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['title'] ?? "",
      image: json['image'] ?? "",
    );
  }
}

class RequestFile {
  final int id;
  final int maintenanceRequestId;
  final String fileType;
  final String filePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RequestFile({
    required this.id,
    required this.maintenanceRequestId,
    required this.fileType,
    required this.filePath,
    this.createdAt,
    this.updatedAt,
  });

  factory RequestFile.fromJson(Map<String, dynamic> json) {
    return RequestFile(
      id: json['id'] ?? 0,
      maintenanceRequestId: json['maintenance_request_id'] ?? 0,
      fileType: json['file_type'] ?? "",
      filePath: json['file_path'] ?? "",
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  // helper to get full remote URL for the file
  String get fullUrl {
    // AppApi.baseUrl = https://www.salhly.lareenmedco.com/api
    final base = AppApi.baseUrl.replaceFirst('/api', '');
    return '$base/storage/$filePath';
  }

  bool get isImage {
    final t = fileType.toLowerCase();
    return ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'].contains(t) || filePath.toLowerCase().contains('.png') || filePath.toLowerCase().contains('.jpg') || filePath.toLowerCase().contains('.jpeg');
  }

  bool get isAudio {
    final t = fileType.toLowerCase();
    return ['m4a', 'mp3', 'wav', 'aac', 'ogg', 'm4b', 'mp4'].contains(t) || filePath.toLowerCase().contains('.mp3') || filePath.toLowerCase().contains('.m4a') || filePath.toLowerCase().contains('.mp4');
  }
}

class RequestModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String description;
  final String status;
  final ServiceModel? service;
  final SubServiceModel? subService;
  final String? reportDescription;
  final String? reportAmountPaid;
  final String? reportWorkerName;
  final List<RequestFile>? reportFiles;
  final List<RequestFile> files;
  final DateTime? createdAt;

  RequestModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.description,
    required this.status,
    this.service,
    this.subService,
    this.reportDescription,
    this.reportAmountPaid,
    this.reportWorkerName,
    this.reportFiles,
    required this.files,
    this.createdAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    String? reportDescription;
    String? reportAmountPaid;
    String? reportWorkerName;
    List<RequestFile>? reportFiles;
    if (json['report'] != null && json['report'] is Map) {
      final report = json['report'] as Map<String, dynamic>;
      reportDescription = report['description']?.toString();
      reportAmountPaid = report['amount_paid']?.toString();
      reportWorkerName = report['worker_name']?.toString();
      if (report['report_files'] != null && report['report_files'] is List) {
        reportFiles = (report['report_files'] as List)
            .map((f) => RequestFile(
                  id: 0,
                  maintenanceRequestId: 0,
                  fileType: f.toString().split('.').last,
                  filePath: f.toString(),
                  createdAt: null,
                  updatedAt: null,
                ))
            .toList();
      }
    }
    return RequestModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? "",
      phoneNumber: json['phone_number'] ?? "",
      address: json['address'] ?? "",
      description: json['description'] ?? "",
      status: json['status'] ?? "",
      service: json['service'] != null ? ServiceModel.fromJson(json['service']) : null,
      subService: json['sub_service'] != null ? SubServiceModel.fromJson(json['sub_service']) : null,
      reportDescription: reportDescription,
      reportAmountPaid: reportAmountPaid,
      reportWorkerName: reportWorkerName,
      reportFiles: reportFiles,
      files: json['files'] != null
          ? List<RequestFile>.from((json['files'] as List).map((e) => RequestFile.fromJson(e)))
          : [],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}

