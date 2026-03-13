class BannerModel {
  final int id;
  final String title;
  final String image;

  BannerModel({
    required this.id,
    required this.title,
    required this.image,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      image: json['image'] ?? "",
    );
  }
}
