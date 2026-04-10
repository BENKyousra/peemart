class PromoModel {
  final String id;
  final String productId;
  final String code;
  final double discount;
  final int maxUsage;
  final int usedCount;
  final DateTime? expiresAt;

  PromoModel({
    required this.id,
    required this.productId,
    required this.code,
    required this.discount,
    required this.maxUsage,
    required this.usedCount,
    this.expiresAt,
  });

  factory PromoModel.fromMap(Map<String, dynamic> map) {
    return PromoModel(
      id: map['id'],
      productId: map['product_id'],
      code: map['code'],
      discount: (map['discount'] as num).toDouble(),
      maxUsage: map['max_usage'] ?? 0,
      usedCount: map['used_count'] ?? 0,
      expiresAt: map['expires_at'] != null
          ? DateTime.parse(map['expires_at'])
          : null,
    );
  }
}