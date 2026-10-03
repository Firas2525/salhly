class MaintenanceOrderModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String serviceName;
  final String subServiceName;
  final String description;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? pendingAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime? completedAt;
  final List<OrderFile>? files;
  final String? reportDescription;
  final String? amountPaid;
  final String? repairPercentage;
  final String? workerName;
  final int paymentProcessed;
  final List<OrderFile>? reportFiles;

  MaintenanceOrderModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.serviceName,
    required this.subServiceName,
    required this.description,
    required this.status,
    this.paymentProcessed = 0,
    this.createdAt,
    this.updatedAt,
    this.pendingAt,
    this.approvedAt,
    this.rejectedAt,
    this.completedAt,
    this.files,
    this.reportDescription,
    this.amountPaid,
    this.repairPercentage,
    this.workerName,
    this.reportFiles,
  });

  bool get isPaymentProcessed => paymentProcessed == 1;

  factory MaintenanceOrderModel.fromJson(Map<String, dynamic> json) {
    // Handle service as either string or object
    String serviceName = '';
    if (json['service'] is String) {
      serviceName = json['service'] ?? '';
    } else if (json['service'] is Map) {
      serviceName = json['service']['name'] ?? '';
    } else if (json['service_name'] is String) {
      serviceName = json['service_name'] ?? '';
    }

    // Handle sub_service as either string or object
    String subServiceName = '';
    if (json['sub_service'] is String) {
      subServiceName = json['sub_service'] ?? '';
    } else if (json['sub_service'] is Map) {
      subServiceName = json['sub_service']['name'] ?? '';
    } else if (json['sub_service_name'] is String) {
      subServiceName = json['sub_service_name'] ?? '';
    }

    // Handle files - check for both 'files' and 'file_path'
    List<OrderFile> files = [];
    if (json['files'] != null && json['files'] is List) {
      files = (json['files'] as List)
          .map((f) => OrderFile.fromJson(f as Map<String, dynamic>))
          .toList();
    }

    // تقرير الإنهاء من كائن report
    String? reportDescription;
    String? amountPaid;
    String? repairPercentage;
    String? workerName;
    List<OrderFile>? reportFiles;
    if (json['report'] != null && json['report'] is Map) {
      final report = json['report'] as Map<String, dynamic>;
      reportDescription = report['description']?.toString();
      amountPaid = report['amount_paid']?.toString();
      repairPercentage = report['repair_percentage']?.toString();
      workerName = report['worker_name']?.toString();
      if (report['report_files'] != null && report['report_files'] is List) {
        reportFiles = (report['report_files'] as List)
            .map((f) => OrderFile(
                  id: 0,
                  type: f.toString().split('.').last,
                  path: f.toString(),
                ))
            .toList();
      }
    }
    repairPercentage ??= json['repair_percentage']?.toString();

    int paymentProcessed = 0;
    if (json['payment_processed'] != null) {
      paymentProcessed = json['payment_processed'] is int
          ? json['payment_processed']
          : int.tryParse(json['payment_processed'].toString()) ?? 0;
    }

    return MaintenanceOrderModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phone'] ?? '',
      address: json['address'] ?? '',
      serviceName: serviceName,
      subServiceName: subServiceName,
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      paymentProcessed: paymentProcessed,
      createdAt:
          json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt:
          json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      pendingAt:
          json['pending_at'] != null ? DateTime.tryParse(json['pending_at'].toString()) : null,
      approvedAt:
          json['approved_at'] != null ? DateTime.tryParse(json['approved_at'].toString()) : null,
      rejectedAt:
          json['rejected_at'] != null ? DateTime.tryParse(json['rejected_at'].toString()) : null,
      completedAt:
          json['completed_at'] != null ? DateTime.tryParse(json['completed_at'].toString()) : null,
      files: files,
      reportDescription: reportDescription,
      amountPaid: amountPaid,
      repairPercentage: repairPercentage,
      workerName: workerName,
      reportFiles: reportFiles,
    );
  }
}

class OrderFile {
  final int id;
  final String type;
  final String path;

  OrderFile({
    required this.id,
    required this.type,
    required this.path,
  });

  bool get isImage => type.toLowerCase().contains('png') || type.toLowerCase().contains('jpg') || type.toLowerCase().contains('jpeg');
  bool get isAudio => type.toLowerCase().contains('m4a') || type.toLowerCase().contains('mp3') || type.toLowerCase().contains('audio');
  bool get isVideo => type.toLowerCase().contains('mp4') || type.toLowerCase().contains('video');

  String get fullUrl => 'https://www.salhly.lareenmedco.com/storage/$path';

  factory OrderFile.fromJson(Map<String, dynamic> json) {
    String fileType = json['file_type'] ?? json['type'] ?? '';
    String filePath = json['file_path'] ?? json['path'] ?? '';
    
    return OrderFile(
      id: json['id'] ?? 0,
      type: fileType,
      path: filePath,
    );
  }
}
