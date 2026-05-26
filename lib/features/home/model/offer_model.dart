bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value.trim()) ?? 0;
  }
  return 0;
}

class OfferImage {
  final int id;
  final String image;
  final String imageUrl;

  OfferImage({required this.id, required this.image, required this.imageUrl});

  factory OfferImage.fromJson(Map<String, dynamic> json) {
    return OfferImage(
      id: json['id'],
      image: json['image'],
      imageUrl: json['image_url'],
    );
  }
}

class Offer {
  final int id;
  final String name;
  final String description;
  final String oldPrice;
  final String newPrice;
  final String whatsapp;
  final String phone;
  final int status;
  final bool isSold;
  final List<OfferImage> images;

  Offer({
    required this.id,
    required this.name,
    required this.description,
    required this.oldPrice,
    required this.newPrice,
    required this.whatsapp,
    required this.phone,
    required this.status,
    required this.isSold,
    required this.images,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      oldPrice: json['old_price'],
      newPrice: json['new_price'],
      whatsapp: json['whatsapp'],
      phone: json['phone'],
      status: _parseInt(json['status']),
      isSold: _parseBool(json['is_sold']),
      images: (json['images'] as List)
          .map((e) => OfferImage.fromJson(e))
          .toList(),
    );
  }
}
