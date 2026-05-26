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
      id: json['id'],
      status: json['status'] ?? '',
      adminNote: json['admin_note'],
      createdAt: DateTime.parse(json['created_at']),
      user: User.fromJson(json['user']),
      pieces: json['pieces'] != null
          ? (json['pieces'] as List).map((p) => ExchangePiece.fromJson(p)).toList()
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
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
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
      id: json['id'],
      description: json['description'] ?? '',
      voiceRecord: json['voice_record'],
      voiceRecordUrl: json['voice_record_url'],
      adminDescription: json['admin_description'],
      adminEstimatedPrice: json['admin_estimated_price'],
      offers: json['offers'] != null
          ? (json['offers'] as List)
              .map((o) => ExchangePieceOffer.fromJson(o))
              .toList()
          : [],
      images: json['images'] != null
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
      id: json['id'],
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      imageUrl: json['image_url'] ?? '',
      differencePrice: json['difference_price'] ?? '',
      images: json['images'] != null
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
      id: json['id'],
      image: json['image'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}