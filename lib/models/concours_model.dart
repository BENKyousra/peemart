class ConcoursModel {
  final String id;
  final String shopName;
  final String? avatarUrl;
  final String? imageUrl;
  final String? description;
  final DateTime date;
  final String type;

  ConcoursModel({
    required this.id,
    required this.shopName,
    this.avatarUrl,
    this.imageUrl,
    this.description,
    required this.date,
    required this.type,
  });

  factory ConcoursModel.fromJson(Map<String, dynamic> json) {
    return ConcoursModel(
      id: json['id'],
      shopName: json['shop_name'] ?? '',
      avatarUrl: json['avatar_url'],
      imageUrl: json['image_url'],
      description: json['description'],

      // 🔥 FIX IMPORTANT
      date: DateTime.parse(
        json['date'] ?? json['created_at'] ?? DateTime.now().toIso8601String(),
      ),

      type: json['type'] ?? 'raffle',
    );
  }
}