class MaintenanceOrderModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String description;
  final String status;
  final int paymentProcessed;
  final ServiceData service;
  final SubServiceData subService;
  final dynamic report;
  final List<dynamic> files;
  final String createdAt;

  MaintenanceOrderModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.description,
    required this.status,
    this.paymentProcessed = 0,
    required this.service,
    required this.subService,
    this.report,
    required this.files,
    required this.createdAt,
  });

  bool get isPaymentProcessed => paymentProcessed == 1;

  factory MaintenanceOrderModel.fromJson(Map<String, dynamic> json) {
    int paymentProcessed = 0;
    final dynamic rawPayment = json['payment_processed'] ??
        json['is_paid'] ??
        (json['report'] is Map ? (json['report']['payment_processed'] ?? json['report']['is_paid']) : null);
    if (rawPayment != null) {
      if (rawPayment is int) {
        paymentProcessed = rawPayment == 1 ? 1 : 0;
      } else if (rawPayment is bool) {
        paymentProcessed = rawPayment ? 1 : 0;
      } else {
        paymentProcessed = int.tryParse(rawPayment.toString()) ?? 0;
      }
    }

    return MaintenanceOrderModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      paymentProcessed: paymentProcessed,
      service: ServiceData.fromJson(json['service'] ?? {}),
      subService: SubServiceData.fromJson(json['sub_service'] ?? {}),
      report: json['report'],
      files: json['files'] ?? [],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class ServiceData {
  final int id;
  final String name;
  final String image;

  ServiceData({
    required this.id,
    required this.name,
    required this.image,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class SubServiceData {
  final int id;
  final String name;
  final String image;

  SubServiceData({
    required this.id,
    required this.name,
    required this.image,
  });

  factory SubServiceData.fromJson(Map<String, dynamic> json) {
    return SubServiceData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
