class DeliveryCompanyModel {
  final String id;
  final String name;
  final String? logoUrl;
  final String? phone;
  final String? description;
  final double priceStandard;
  final double priceExpress;
  final String delayStandard;
  final String delayExpress;
  final bool isActive;

  DeliveryCompanyModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.phone,
    this.description,
    required this.priceStandard,
    required this.priceExpress,
    this.delayStandard = '3-5 jours',
    this.delayExpress = '24h',
    this.isActive = true,
  });

  factory DeliveryCompanyModel.fromJson(Map<String, dynamic> json) {
    return DeliveryCompanyModel(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo_url'],
      phone: json['phone'],
      description: json['description'],
      priceStandard: (json['price_standard'] ?? 0).toDouble(),
      priceExpress: (json['price_express'] ?? 0).toDouble(),
      delayStandard: json['delay_standard'] ?? '3-5 jours',
      delayExpress: json['delay_express'] ?? '24h',
      isActive: json['is_active'] ?? true,
    );
  }
}
