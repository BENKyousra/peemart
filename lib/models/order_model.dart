class OrderModel {
  final String id;
  final String userId;
  final double total;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      total: (json['total'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}