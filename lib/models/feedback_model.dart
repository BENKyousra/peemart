class FeedbackModel {
  final String id;
  final String userId;
  final String content;
  final String username;
  final String? avatarUrl;
  final DateTime createdAt;
  final List<String> images;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.username,
    this.avatarUrl,
    required this.createdAt,
    required this.images, 
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      username: json['users']?['username'] ?? 'User',
      avatarUrl: json['users']?['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      images: (json['feedback_images'] as List?)
              ?.map((e) => e['image_url'].toString())
              .toList() ??
          [],
    );
  }
}