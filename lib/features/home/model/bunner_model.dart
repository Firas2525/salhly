class BannerModel {
  final int id;
  final String title;
  final String image;
  final String? description;

  BannerModel({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      image: json['image'] ?? "",
      description: json['description'] ?? "",
    );
  }
}
