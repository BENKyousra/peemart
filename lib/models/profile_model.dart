class ProfileModel {
  final String id;
  final String username;
  final String email;
  final String avatarUrl;
  final String bio;
  final bool isSeller;
  final int favoritesCount;
  final int cartCount;
  final int notificationsCount;

  ProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.bio,
    required this.isSeller,
    required this.favoritesCount,
    required this.cartCount,
    required this.notificationsCount,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'],
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatar_url'] ?? '',
      bio: map['bio'] ?? '',
      isSeller: map['is_seller'] ?? false,
      favoritesCount: map['favorites_count'] ?? 0,
      cartCount: map['cart_count'] ?? 0,
      notificationsCount: map['notifications_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
      'is_seller': isSeller,
    };
  }
}