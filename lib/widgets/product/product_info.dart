import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../widgets/product/rating_stars.dart';
import '../../widgets/product/add_to_cart_button.dart';
import '../../pages/shop_page.dart';

class ProductInfo extends StatefulWidget {
  final ProductModel product;
  final int commentsCount;
  final String shopId;
  final String shopAvatar;
  final String shopName;
  final List<Map<String, dynamic>> variants;

  const ProductInfo({
    super.key,
    required this.product,
    required this.commentsCount,
    required this.shopId,
    required this.shopAvatar,
    required this.shopName,
    required this.variants,
  });

  @override
  State<ProductInfo> createState() => _ProductInfoState();
}

class _ProductInfoState extends State<ProductInfo> {
  String? selectedColor;
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final colors =
        widget.variants
            .map((v) => v['color'] as String?)
            .where((c) => c != null && c.isNotEmpty)
            .toSet()
            .toList();

    final sizes =
        widget.variants
            .map((v) => v['size'] as String?)
            .where((s) => s != null && s.isNotEmpty)
            .toSet()
            .toList();

    final filteredSizes =
        widget.variants
            .where((v) => v['color'] == selectedColor)
            .map((v) => v['size'] as String?)
            .where((s) => s != null && s.isNotEmpty)
            .toSet()
            .toList();

    double finalPrice = product.price;

    final selectedVariant = widget.variants.firstWhere(
      (v) => v['color'] == selectedColor && v['size'] == selectedSize,
      orElse: () => {},
    );

    if (selectedVariant.isNotEmpty && selectedVariant['price'] != null) {
      finalPrice = double.parse(selectedVariant['price'].toString());
    }

    bool _canAddToCart() {
      final hasVariants = widget.variants.isNotEmpty;

      if (!hasVariants) return true;

      if (selectedColor == null) return false;
      if (selectedSize == null) return false;

      final variantExists = widget.variants.any(
        (v) => v['color'] == selectedColor && v['size'] == selectedSize,
      );

      return variantExists;
    }

    print("VARIANTS = ${widget.variants}");
    print("COLORS = $colors");
    print("SIZES = $sizes");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.title, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 20),

        Text(
          "$finalPrice DA",
          style: const TextStyle(
            fontSize: 26,
            color: Color.fromARGB(255, 0, 169, 191),
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            RatingStars(rating: product.rating),
            Text(" (${widget.commentsCount})"),
          ],
        ),

        const SizedBox(height: 20),

        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShopPage(shopId: widget.shopId),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  widget.shopAvatar.isNotEmpty
                      ? widget.shopAvatar
                      : 'https://picsum.photos/100',
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.shopName.isNotEmpty ? widget.shopName : "Boutique",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text(product.description),

        const SizedBox(height: 20),

        if (colors.isNotEmpty) ...[
          const Text("Couleurs", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            children:
                colors.map((color) {
                  return ChoiceChip(
                    label: Text(color!),
                    selected: selectedColor == color,
                    onSelected: (_) {
                      setState(() {
                        selectedColor = color;
                        selectedSize = null;
                      });
                    },
                  );
                }).toList(),
          ),
        ],
        // 📏 TAILLES
        if (product.sizes != null && product.sizes!.isNotEmpty) ...[
          const Text("Tailles", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (filteredSizes.isNotEmpty) ...[
            const Text(
              "Tailles",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children:
                  filteredSizes.map((size) {
                    final isSelected = selectedSize == size;

                    return ChoiceChip(
                      label: Text(size!),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedSize = size;
                        });
                      },
                    );
                  }).toList(),
            ),

            const SizedBox(height: 20),
          ],

          Wrap(
            spacing: 10,
            children:
                product.sizes!.map((size) {
                  final isSelected = selectedSize == size;

                  return ChoiceChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedSize = size;
                      });
                    },
                  );
                }).toList(),
          ),
        ],

        const SizedBox(height: 20),

        // 🔥 BOUTON PANIER
        AddToCartButton(
          productId: product.id,
          selectedColor: selectedColor,
          selectedSize: selectedSize,
          variantId: selectedVariant.isNotEmpty ? selectedVariant['id'] : null,
        ),
      ],
    );
  }
}
