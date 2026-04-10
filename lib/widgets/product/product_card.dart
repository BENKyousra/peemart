import 'package:flutter/material.dart';
import '../../pages/products/product_detail_page.dart';
import '../../pages/shop_page.dart';
import '../../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final int reviewCount;
  final VoidCallback? onRefresh;

  const ProductCard({
    super.key,
    required this.product,
    required this.reviewCount,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );

        if (result == true) {
          onRefresh?.call();
        }
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== IMAGE =====
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Image.network(
                product.image,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    height: 240,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (_, __, ___) {
                  return Container(
                    height: 240,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== NOM PRODUIT =====
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ===== PRIX =====
                  Text(
                    '${product.price.toStringAsFixed(0)} DA',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 169, 191),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ===== RATING =====
                  Row(
                    children: [
                      _buildStars(product.rating),
                      const SizedBox(width: 6),
                      Text(product.rating.toStringAsFixed(1)),
                      const SizedBox(width: 4),
                      Text(
                        "($reviewCount)",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ===== SHOP =====
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ShopPage(shopId: product.shopId),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(
                            product.shopAvatar.isNotEmpty
                                ? product.shopAvatar
                                : 'https://picsum.photos/100',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            product.shopName.isNotEmpty
                                ? product.shopName
                                : "Boutique",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 0, 2, 105),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== WIDGET ÉTOILES =====
  Widget _buildStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 14);
        } else if (index < rating) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 14);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 14);
        }
      }),
    );
  }
}