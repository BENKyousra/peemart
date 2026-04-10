import 'product_model.dart';

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
  String? selectedColor;
  String? selectedSize;
  String? promoCode;
  double discount; 

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
    this.selectedColor,
    this.selectedSize,
    this.promoCode,
    this.discount = 0.0,

  });

  ProductModel toProduct() {
    return ProductModel(
      id: productId,
      title: title,
      image: imageUrl,
      images: [imageUrl],
      price: price,
      shopName: shopName,
      shopId: shopId,
      shopAvatar: shopAvatar,
      rating: rating,
      description: description,
      
    );
  }
}
