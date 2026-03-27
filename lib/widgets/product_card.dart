import 'package:flutter/material.dart';
import '../pages/product_detail_page.dart';
import '../pages/shop_page.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final List<String> images;
  final double price;
  final String shopName;
  final String shopAvatar;
  final double rating;
  final String shopId;
  final String productId;

  const ProductCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.images,
    required this.price,
    required this.shopName,
    required this.shopAvatar,
    required this.rating,
    required this.shopId,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailPage(
                  productId: productId,
                  title: title,
                  imageUrl: imageUrl,
                  images: images,
                  price: price,
                  shopName: shopName,
                  shopId: shopId,
                  shopAvatar: shopAvatar,
                  rating: rating,
                  description:
                      "Ceci est une description du produit. "
                      "Ici tu peux mettre tous les détails comme les sites e-commerce.",
                ),
          ),
        );
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
                imageUrl,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
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
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // 👈 points ...
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ===== PRIX =====
                  Text(
                    '${price.toStringAsFixed(0)} DA',
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
                      _buildStars(rating),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopPage(shopId: shopId),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(
                            (shopAvatar != null && shopAvatar.isNotEmpty)
                                ? shopAvatar
                                : 'https://picsum.photos/100', // image par défaut
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            (shopName != null && shopName.isNotEmpty)
                                ? shopName
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
