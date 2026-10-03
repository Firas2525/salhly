class ServicesModel {
  final int id;
  final String title;
  final String image;
  final bool isGolden;

  ServicesModel({
    required this.id,
    required this.title,
    required this.image,
    this.isGolden = false,
  });

  factory ServicesModel.fromJson(Map<String, dynamic> json, {bool isGolden = false}) {
    return ServicesModel(
      id: json["id"] is int ? json["id"] : (int.tryParse(json["id"]?.toString() ?? '0') ?? 0),
      title: json["title"]?.toString() ?? json["name"]?.toString() ?? "",
      image: json["image"]?.toString() ?? "",
      isGolden: isGolden || json['is_golden'] == 1 || json['is_golden'] == true,
    );
  }

  String get fullImageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http://') || image.startsWith('https://')) return image;
    final clean = image.startsWith('/') ? image.substring(1) : image;
    if (clean.startsWith('storage/')) return 'https://www.salhly.lareenmedco.com/$clean';
    return 'https://www.salhly.lareenmedco.com/storage/$clean';
  }
}

