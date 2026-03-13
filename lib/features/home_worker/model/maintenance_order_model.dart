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
  final List<OrderFile>? files;
  final String? reportDescription;
  final String? amountPaid;
  final String? workerName;
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
    this.createdAt,
    this.files,
    this.reportDescription,
    this.amountPaid,
    this.workerName,
    this.reportFiles,
  });

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
    String? workerName;
    List<OrderFile>? reportFiles;
    if (json['report'] != null && json['report'] is Map) {
      final report = json['report'] as Map<String, dynamic>;
      reportDescription = report['description']?.toString();
      amountPaid = report['amount_paid']?.toString();
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

    return MaintenanceOrderModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phone'] ?? '',
      address: json['address'] ?? '',
      serviceName: serviceName,
      subServiceName: subServiceName,
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt:
          json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      files: files,
      reportDescription: reportDescription,
      amountPaid: amountPaid,
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
