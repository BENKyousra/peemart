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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',

      // 🔥 SAFE mapping (important)
      avatar: json['avatar'] ?? json['avatar'],
      coverImage: json['cover_image'] ?? json['cover'],

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

  // 🔥 helper utile
  ShopModel copyWith({
    String? name,
    String? avatar,
    String? coverImage,
    String? location,
    String? phone,
    String? email,
  }) {
    return ShopModel(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      avatar: avatar ?? this.avatar,
      coverImage: coverImage ?? this.coverImage,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}