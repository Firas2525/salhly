class AboutUsModel {
  final int id;
  final String aboutUs;

  AboutUsModel({
    required this.id,
    required this.aboutUs,
  });

  factory AboutUsModel.fromJson(Map<String, dynamic> json) {
    return AboutUsModel(
      id: json["id"],
      aboutUs: json["about_us"] ?? "",
    );
  }
}
