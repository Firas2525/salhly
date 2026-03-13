class ServicesModel {
  final int id;
  final String title;
  final String image;

  ServicesModel({
    required this.id,
    required this.title,
    required this.image,
  });

  factory ServicesModel.fromJson(Map<String, dynamic> json) {
    return ServicesModel(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      image: json["image"] ?? "",
    );
  }
}
