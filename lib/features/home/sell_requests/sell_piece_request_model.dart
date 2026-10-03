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
              .map((p) => SellPiece.fromJson(p))
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

class SellPiece {
  final int id;
  final String description;
  final String expectedPrice;
  final String? currency;
  final String? voiceRecord;
  final String? voiceRecordUrl;
  final String? adminDescription;
  final String? adminExpectedPrice;
  final List<SellPieceImage> images;

  SellPiece({
    required this.id,
    required this.description,
    required this.expectedPrice,
    this.currency,
    this.voiceRecord,
    this.voiceRecordUrl,
    this.adminDescription,
    this.adminExpectedPrice,
    required this.images,
  });

  factory SellPiece.fromJson(Map<String, dynamic> json) {
    return SellPiece(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      expectedPrice: json['expected_price']?.toString() ?? '',
      currency: json['currency']?.toString(),
      voiceRecord: json['voice_record']?.toString(),
      voiceRecordUrl: json['voice_record_url']?.toString(),
      adminDescription: json['admin_description']?.toString(),
      adminExpectedPrice: json['admin_expected_price']?.toString(),
      images: json['images'] is List
          ? (json['images'] as List)
              .map((i) => SellPieceImage.fromJson(i))
              .toList()
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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      image: json['image']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }
}