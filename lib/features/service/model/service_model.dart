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
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      title: json['title']?.toString() ?? json['name']?.toString() ?? "",
      image: json['image']?.toString() ?? "",
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
