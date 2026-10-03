import 'package:salhly/core/utils/app_api.dart';

class ServiceModel {
  final int id;
  final String name;
  final String image;

  ServiceModel({required this.id, required this.name, required this.image});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? json['title']?.toString() ?? "",
      image: json['image']?.toString() ?? "",
    );
  }

  String get fullImageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http://') || image.startsWith('https://')) return image;
    final clean = image.startsWith('/') ? image.substring(1) : image;
    if (clean.startsWith('storage/')) return 'https://www.salhly.lareenmedco.com/$clean';
    return 'https://www.salhly.lareenmedco.com/storage/$clean';
  }
}

class SubServiceModel {
  final int id;
  final String name;
  final String image;

  SubServiceModel({required this.id, required this.name, required this.image});

  factory SubServiceModel.fromJson(Map<String, dynamic> json) {
    return SubServiceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? json['title']?.toString() ?? "",
      image: json['image']?.toString() ?? "",
    );
  }

  String get fullImageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http://') || image.startsWith('https://')) return image;
    final clean = image.startsWith('/') ? image.substring(1) : image;
    if (clean.startsWith('storage/')) return 'https://www.salhly.lareenmedco.com/$clean';
    return 'https://www.salhly.lareenmedco.com/storage/$clean';
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

class WorkerModel {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkerModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? "",
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      image: json['image']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  String get fullImageUrl {
    if (image == null || image!.isEmpty) return '';
    if (image!.startsWith('http://') || image!.startsWith('https://')) {
      return image!;
    }
    final cleanPath = image!.startsWith('/') ? image!.substring(1) : image!;
    if (cleanPath.startsWith('storage/')) {
      return 'https://www.salhly.lareenmedco.com/$cleanPath';
    }
    return 'https://www.salhly.lareenmedco.com/storage/$cleanPath';
  }
}

class RequestModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String description;
  final String status;
  final int paymentProcessed;
  final ServiceModel? service;
  final SubServiceModel? subService;
  final String? reportDescription;
  final String? reportAmountPaid;
  final String? repairPercentage;
  final String? reportWorkerName;
  final List<RequestFile>? reportFiles;
  final WorkerModel? worker;
  final List<RequestFile> files;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? pendingAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime? completedAt;

  RequestModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.description,
    required this.status,
    this.paymentProcessed = 0,
    this.service,
    this.subService,
    this.reportDescription,
    this.reportAmountPaid,
    this.repairPercentage,
    this.reportWorkerName,
    this.reportFiles,
    this.worker,
    required this.files,
    this.createdAt,
    this.updatedAt,
    this.pendingAt,
    this.approvedAt,
    this.rejectedAt,
    this.completedAt,
  });

  bool get isPaymentProcessed => paymentProcessed == 1;

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    String? reportDescription;
    String? reportAmountPaid;
    String? repairPercentage;
    String? reportWorkerName;
    List<RequestFile>? reportFiles;
    if (json['report'] != null && json['report'] is Map) {
      final report = json['report'] as Map<String, dynamic>;
      reportDescription = report['description']?.toString();
      reportAmountPaid = report['amount_paid']?.toString();
      repairPercentage = report['repair_percentage']?.toString();
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
    repairPercentage ??= json['repair_percentage']?.toString();

    WorkerModel? worker;
    if (json['worker'] != null && json['worker'] is Map) {
      worker = WorkerModel.fromJson(json['worker'] as Map<String, dynamic>);
    }

    int paymentProcessed = 0;
    final dynamic rawPayment = json['payment_processed'] ??
        json['is_paid'] ??
        json['payment_status'] ??
        (json['report'] is Map ? (json['report']['payment_processed'] ?? json['report']['is_paid']) : null);

    if (rawPayment != null) {
      if (rawPayment is int) {
        paymentProcessed = rawPayment == 1 ? 1 : 0;
      } else if (rawPayment is bool) {
        paymentProcessed = rawPayment ? 1 : 0;
      } else {
        final str = rawPayment.toString().toLowerCase().trim();
        if (str == '1' || str == 'true' || str == 'paid' || str.contains('تم الدفع') || str.contains('مدفوع')) {
          paymentProcessed = 1;
        } else {
          paymentProcessed = int.tryParse(str) ?? 0;
        }
      }
    }

    return RequestModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fullName: json['full_name']?.toString() ?? "",
      phoneNumber: json['phone_number']?.toString() ?? "",
      address: json['address']?.toString() ?? "",
      description: json['description']?.toString() ?? "",
      status: json['status']?.toString() ?? "",
      paymentProcessed: paymentProcessed,
      service: json['service'] != null ? ServiceModel.fromJson(json['service']) : null,
      subService: json['sub_service'] != null ? SubServiceModel.fromJson(json['sub_service']) : null,
      reportDescription: reportDescription,
      reportAmountPaid: reportAmountPaid,
      repairPercentage: repairPercentage,
      reportWorkerName: reportWorkerName,
      reportFiles: reportFiles,
      worker: worker,
      files: json['files'] != null
          ? List<RequestFile>.from((json['files'] as List).map((e) => RequestFile.fromJson(e)))
          : [],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      pendingAt: json['pending_at'] != null ? DateTime.tryParse(json['pending_at'].toString()) : null,
      approvedAt: json['approved_at'] != null ? DateTime.tryParse(json['approved_at'].toString()) : null,
      rejectedAt: json['rejected_at'] != null ? DateTime.tryParse(json['rejected_at'].toString()) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'].toString()) : null,
    );
  }

  /// Get the date corresponding specifically to current status
  DateTime? get currentStatusDate {
    final s = status.toLowerCase();
    if (s.contains('approved') || s.contains('موافق')) {
      return approvedAt ?? updatedAt ?? createdAt;
    }
    if (s.contains('completed') || s.contains('مكتمل')) {
      return completedAt ?? updatedAt ?? createdAt;
    }
    if (s.contains('reject') || s.contains('cancel') || s.contains('رفض') || s.contains('ملغ')) {
      return rejectedAt ?? updatedAt ?? createdAt;
    }
    if (s.contains('pending') || s.contains('قيد')) {
      return pendingAt ?? createdAt;
    }
    return updatedAt ?? createdAt;
  }

  /// Get status label for date
  String get currentStatusDateLabel {
    final s = status.toLowerCase();
    if (s.contains('approved') || s.contains('موافق')) {
      return 'الموافقة';
    }
    if (s.contains('completed') || s.contains('مكتمل')) {
      return 'الاكتمال';
    }
    if (s.contains('reject') || s.contains('cancel') || s.contains('رفض') || s.contains('ملغ')) {
      return 'الإلغاء';
    }
    if (s.contains('pending') || s.contains('قيد')) {
      return 'الطلب';
    }
    return '';
  }

  /// Display worker name (from worker object or report)
  String? get displayWorkerName {
    if (worker != null && worker!.name.trim().isNotEmpty) {
      return worker!.name.trim();
    }
    if (reportWorkerName != null && reportWorkerName!.trim().isNotEmpty) {
      return reportWorkerName!.trim();
    }
    return null;
  }
}

