class PrivacyPolicyModel {
  final int id;
  final String description;

  PrivacyPolicyModel({
    required this.id,
    required this.description,
  });

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyModel(
      id: json["id"] ?? 0,
      description: json["description"] ?? "",
    );
  }
}
