class OrderModel {
  final String id;
  final String userId;
  final double total;
  final String status;
  final DateTime createdAt;

  // 🚚 Livraison
  final String? deliveryCompanyId;
  final String? deliveryCompanyName;
  final String? deliveryType; // 'standard' ou 'express'
  final String? deliveryAddress;
  final String? deliveryCity;
  final String? deliveryPhone;
  final String? deliveryStatus;
  final double deliveryPrice;
  final String? estimatedDelivery;
  final String? trackingCode;

  OrderModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    required this.createdAt,
    this.deliveryCompanyId,
    this.deliveryCompanyName,
    this.deliveryType,
    this.deliveryAddress,
    this.deliveryCity,
    this.deliveryPhone,
    this.deliveryStatus,
    this.deliveryPrice = 0,
    this.estimatedDelivery,
    this.trackingCode,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final company = json['delivery_companies'] as Map<String, dynamic>?;

    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      total: (json['total'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      deliveryCompanyId: json['delivery_company_id'],
      deliveryCompanyName: company?['name'],
      deliveryType: json['delivery_type'],
      deliveryAddress: json['delivery_address'],
      deliveryCity: json['delivery_city'],
      deliveryPhone: json['delivery_phone'],
      deliveryStatus: json['delivery_status'] ?? 'pending',
      deliveryPrice: (json['delivery_price'] ?? 0).toDouble(),
      estimatedDelivery: json['estimated_delivery'],
      trackingCode: json['tracking_code'],
    );
  }
}
