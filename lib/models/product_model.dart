class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;

  final String image; // image principale
  final List<String> images; // galerie

  final String shopName;
  final String shopId;
  final String shopAvatar;

  final double rating;
  final List<String> colors;
  final List<String> sizes;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.images,
    required this.shopName,
    required this.shopId,
    required this.shopAvatar,
    required this.rating,
    this.colors = const [],
    this.sizes = const [],
  });

  /// ✅ toutes les images
  List<String> get allImages => [image, ...images];

  /// ✅ pour insert/update
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'image': image,
      'product_images': images,
    };
  }

  /// 🔥 conversion Supabase PRO
 factory ProductModel.fromMap(Map<String, dynamic> map) {
  final shop = map['shops'] as Map<String, dynamic>?;

  return ProductModel(
    id: map['id']?.toString() ?? '',
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    price: (map['price'] ?? 0).toDouble(),

    // ⚠️ adapte selon ta DB
    image: map['image'] ?? '',

    images: map['product_images'] != null
        ? List<String>.from(
            (map['product_images'] as List).map(
              (img) => img['image_url'] ?? '',
            ),
          )
        : [],

    // 🔥 SHOP CORRECT
    shopName: shop?['name'] ?? '',
    shopId: shop?['id']?.toString() ?? '',
    shopAvatar: shop?['avatar'] ?? '',

    rating: (map['rating'] ?? 0).toDouble(),
    colors: map['colors'] != null ? List<String>.from(map['colors']) : [],
    sizes: map['sizes'] != null ? List<String>.from(map['sizes']) : [],
  );
}
}