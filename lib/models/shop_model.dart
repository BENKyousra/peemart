class ShopModel {
  final String id;
  final String name;
  final String? avatar;
  final String? coverImage;
  final String location;
  final String? phone;
  final String? email;

  ShopModel({
    required this.id,
    required this.name,
    required this.location,
    this.avatar,
    this.coverImage,
    this.phone,
    this.email,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'],
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      avatar: json['avatar'],
      coverImage: json['cover_image'],
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'avatar': avatar,
      'cover_image': coverImage,
      'phone': phone,
      'email': email,
    };
  }
}