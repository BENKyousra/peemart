import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'product_card.dart';
import '../../widgets/see_more_card.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final List<ProductModel> products;
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
          // ===== HEADER =====
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

          // ===== LISTE PRODUITS =====
          SizedBox(
            height: 365,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount:
                  products.length > maxItems ? maxItems + 1 : products.length,
              itemBuilder: (context, index) {
                // ===== SEE MORE =====
                if (index == maxItems && products.length > maxItems) {
                  return SeeMoreCard(
                    remaining: products.length - maxItems,
                    onTap: onSeeMore,
                  );
                }

                final product = products[index];

                return ProductCard(
                  product: product, // 🔥 CLEAN
                  reviewCount: 0, // 👉 adapte si tu l’as dans ton model
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}