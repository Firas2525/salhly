class SubServiceModel {
  final int id;
  final String title;
  final String image;

  SubServiceModel({
    required this.id,
    required this.title,
    required this.image,
  });

  factory SubServiceModel.fromJson(Map<String, dynamic> json) {
    return SubServiceModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      image: json['image'] ?? "",
    );
  }
}
