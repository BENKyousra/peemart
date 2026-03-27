import 'package:flutter/material.dart';
import 'product_card.dart';
import 'see_more_card.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> products;
  final VoidCallback onSeeMore;
  final IconData icon;

  const ProductSection({
    super.key,
    required this.title,
    required this.products,
    required this.onSeeMore,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const int maxItems = 8;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== TITRE + VOIR PLUS =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: const Color.fromARGB(255, 0, 2, 105),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 0, 2, 105),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onSeeMore,
                  child: const Text(
                    'Voir plus',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 2, 105),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // ===== PRODUITS =====
          SizedBox(
            height: 360,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount:
                  products.length > maxItems ? maxItems + 1 : products.length,
              itemBuilder: (context, index) {
                // ===== CARTE VOIR PLUS =====
                if (index == maxItems && products.length > maxItems) {
                  return SeeMoreCard(
                    remaining: products.length - maxItems,
                    onTap: onSeeMore,
                  );
                }

                final product = products[index];

                // ===== IMAGES =====
                final images =
                    (product['product_images'] as List<dynamic>?)
                        ?.map((e) => e['image_url'] as String)
                        .toList() ??
                    [];

                final imageUrl =
                    images.isNotEmpty
                        ? images[0]
                        : 'https://via.placeholder.com/150';

                // ===== SHOP =====
                final shop = product['shops'] as Map<String, dynamic>?;

                return ProductCard(
                  productId: product['id'].toString(),
                  title: product['title'] ?? '',
                  imageUrl: imageUrl,
                  images: images,
                  price: (product['price'] as num?)?.toDouble() ?? 0.0,

                  // ✅ CORRECTION ICI
                  shopName: shop?['name'] ?? '',
                  shopAvatar: shop?['avatar'] ?? '',

                  // ✅ IMPORTANT
                  shopId: product['shop_id'].toString(),

                  rating: (product['rating'] as num?)?.toDouble() ?? 0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
