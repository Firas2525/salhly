class SellPieceRequest {
  final int id;
  final String status;
  final String? adminNote;
  final DateTime createdAt;
  final User user;
  final List<SellPiece> pieces;

  SellPieceRequest({
    required this.id,
    required this.status,
    this.adminNote,
    required this.createdAt,
    required this.user,
    required this.pieces,
  });

  factory SellPieceRequest.fromJson(Map<String, dynamic> json) {
    return SellPieceRequest(
      id: json['id'],
      status: json['status'] ?? '',
      adminNote: json['admin_note'],
      createdAt: DateTime.parse(json['created_at']),
      user: User.fromJson(json['user']),
      pieces: json['pieces'] != null
          ? (json['pieces'] as List).map((p) => SellPiece.fromJson(p)).toList()
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

class SellPiece {
  final int id;
  final String description;
  final String expectedPrice;
  final String? voiceRecord;
  final String? voiceRecordUrl;
  final String? adminDescription;
  final String? adminExpectedPrice;
  final List<SellPieceImage> images;

  SellPiece({
    required this.id,
    required this.description,
    required this.expectedPrice,
    this.voiceRecord,
    this.voiceRecordUrl,
    this.adminDescription,
    this.adminExpectedPrice,
    required this.images,
  });

  factory SellPiece.fromJson(Map<String, dynamic> json) {
    return SellPiece(
      id: json['id'],
      description: json['description'] ?? '',
      expectedPrice: json['expected_price'] ?? '',
      voiceRecord: json['voice_record'],
      voiceRecordUrl: json['voice_record_url'],
      adminDescription: json['admin_description'],
      adminExpectedPrice: json['admin_expected_price'],
      images: json['images'] != null
          ? (json['images'] as List).map((i) => SellPieceImage.fromJson(i)).toList()
          : [],
    );
  }
}

class SellPieceImage {
  final int id;
  final String image;
  final String imageUrl;

  SellPieceImage({
    required this.id,
    required this.image,
    required this.imageUrl,
  });

  factory SellPieceImage.fromJson(Map<String, dynamic> json) {
    return SellPieceImage(
      id: json['id'],
      image: json['image'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}