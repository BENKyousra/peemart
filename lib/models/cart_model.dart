class CartModel {
  final String id;
  final String productId;
  final String title;
  final double price;
  final String imageUrl;
  final int quantity;
   final String shopName;
  final String shopId;
  final String shopAvatar;
  final double rating;
  final String description;

  CartModel({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.shopName,
    required this.shopId,
    required this.shopAvatar,
    required this.rating,
    required this.description,
  });
}
