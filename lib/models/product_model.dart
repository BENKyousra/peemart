class ProductModel {
  final String title;
  final String description;
  final double price;
  final String image; // image principale
  final List<String> images; // galerie

  ProductModel({
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.images,
  });

  /// ✅ toutes les images (image principale en premier)
  List<String> get allImages {
    return [
      image,
      ...images,
    ];
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'image': image,
      'product_images': images,
    };
  }

  /// 🔥 conversion depuis Supabase
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      image: map['image'] ?? '',
      images: map['product_images'] != null
          ? List<String>.from(
              map['product_images']
                  .map((img) => img['image_url']),
            )
          : [],
    );
  }
}