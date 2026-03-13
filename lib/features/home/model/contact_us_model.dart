class ContactUsModel {
  final int id;
  final String phoneNumber;
  final String whatsAppNumber;
  final String companyNumber;
  final String gmail;
  final String websiteLink;
  final String facebook;
  final String instagram;
  final String linkedin;

  ContactUsModel({
    required this.id,
    required this.phoneNumber,
    required this.whatsAppNumber,
    required this.companyNumber,
    required this.gmail,
    required this.websiteLink,
    required this.facebook,
    required this.instagram,
    required this.linkedin,
  });

  factory ContactUsModel.fromJson(Map<String, dynamic> json) {
    return ContactUsModel(
      id: json["id"],
      phoneNumber: json["phone_number"] ?? "",
      whatsAppNumber: json["whatsApp_number"] ?? "",
      companyNumber: json["company_number"] ?? "",
      gmail: json["gmail"] ?? "",
      websiteLink: json["website_link"] ?? "",
      facebook: json["facebook"] ?? "",
      instagram: json["instagram"] ?? "",
      linkedin: json["linkedin"] ?? "",
    );
  }
}
