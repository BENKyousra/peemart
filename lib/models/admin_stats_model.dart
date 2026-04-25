class AdminStats {
  final int totalOrders;
  final int totalUsers;
  final int totalProducts;
  final double revenue;

  AdminStats({
    required this.totalOrders,
    required this.totalUsers,
    required this.totalProducts,
    required this.revenue,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalOrders: json['total_orders'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      totalProducts: json['total_products'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}