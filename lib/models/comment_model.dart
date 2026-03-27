class CommentModel {
  final String id;
  final String productId;
  final String name;
  final int rating;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.rating,
    required this.content,
    required this.createdAt,
  });
 factory CommentModel.fromMap(Map<String, dynamic> map) {
  return CommentModel(
    id: map['id'] ?? '',
    productId: map['product_id'] ?? '',
    name: map['username'] ?? 'Utilisateur', // ou vide si pas de join
    rating: (map['rating'] ?? 0),
    content: map['content'] ?? '',
    createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
  );
}
}
