class ExchangePieceRequest {
  final int id;
  final String status;
  final String? adminNote;
  final DateTime createdAt;
  final User user;
  final List<ExchangePiece> pieces;

  ExchangePieceRequest({
    required this.id,
    required this.status,
    this.adminNote,
    required this.createdAt,
    required this.user,
    required this.pieces,
  });

  factory ExchangePieceRequest.fromJson(Map<String, dynamic> json) {
    return ExchangePieceRequest(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? '',
      adminNote: json['admin_note']?.toString(),
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'])
          : User(id: 0, name: '', phone: ''),
      pieces: json['pieces'] is List
          ? (json['pieces'] as List)
              .map((p) => ExchangePiece.fromJson(p))
              .toList()
          : [],
    );
  }
}

class User {
  final int id;
  final String name;
  final String phone;

  User({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

class ExchangePiece {
  final int id;
  final String description;
  final String? voiceRecord;
  final String? voiceRecordUrl;
  final String? adminDescription;
  final String? adminEstimatedPrice;
  final List<ExchangePieceOffer> offers;
  final List<ExchangePieceImage> images;

  ExchangePiece({
    required this.id,
    required this.description,
    this.voiceRecord,
    this.voiceRecordUrl,
    this.adminDescription,
    this.adminEstimatedPrice,
    required this.offers,
    required this.images,
  });

  factory ExchangePiece.fromJson(Map<String, dynamic> json) {
    return ExchangePiece(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      voiceRecord: json['voice_record']?.toString(),
      voiceRecordUrl: json['voice_record_url']?.toString(),
      adminDescription: json['admin_description']?.toString(),
      adminEstimatedPrice: json['admin_estimated_price']?.toString(),
      offers: json['offers'] is List
          ? (json['offers'] as List)
              .map((o) => ExchangePieceOffer.fromJson(o))
              .toList()
          : [],
      images: json['images'] is List
          ? (json['images'] as List)
              .map((i) => ExchangePieceImage.fromJson(i))
              .toList()
          : [],
    );
  }
}

class ExchangePieceOffer {
  final int id;
  final String description;
  final String image;
  final String imageUrl;
  final String differencePrice;
  final List<ExchangePieceImage> images;

  ExchangePieceOffer({
    required this.id,
    required this.description,
    required this.image,
    required this.imageUrl,
    required this.differencePrice,
    required this.images,
  });

  factory ExchangePieceOffer.fromJson(Map<String, dynamic> json) {
    return ExchangePieceOffer(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      differencePrice: json['difference_price']?.toString() ?? '',
      images: json['images'] is List
          ? (json['images'] as List)
              .map((i) => ExchangePieceImage.fromJson(i))
              .toList()
          : [],
    );
  }
}

class ExchangePieceImage {
  final int id;
  final String image;
  final String imageUrl;

  ExchangePieceImage({
    required this.id,
    required this.image,
    required this.imageUrl,
  });

  factory ExchangePieceImage.fromJson(Map<String, dynamic> json) {
    return ExchangePieceImage(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      image: json['image']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }
}