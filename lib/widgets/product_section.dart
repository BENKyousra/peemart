import 'package:flutter/material.dart';
import 'product_card.dart';

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Color.fromARGB(255, 0, 2, 105),
                      size: 22,
                    ), // un peu plus petit
                    const SizedBox(width: 8), // petit espace collé au titre
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

          // ===== PRODUITS (scroll horizontal) =====
          SizedBox(
            height: 360,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: products.length > 9 ? 9 : products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return ProductCard(
                  title: product['title'],
                  imageUrl: product['image_url'],
                  price:
                      product['price'] is double
                          ? product['price']
                          : double.tryParse(product['price'].toString()) ?? 0.0,
                  shopName: product['shop_name'],
                  shopAvatar: product['shop_avatar'],
                  rating:
                      product['rating'] is double
                          ? product['rating']
                          : (product['rating'] as num).toDouble(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
