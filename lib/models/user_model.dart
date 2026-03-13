class UserModel {
  final int id;
  final String? name;
  final String? phone;
  final String? email;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    this.name,
    this.phone,
    this.email,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      image: json['image']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
