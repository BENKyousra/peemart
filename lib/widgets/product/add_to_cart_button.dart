import 'package:flutter/material.dart';
import '../../services/cart_service.dart';

class AddToCartButton extends StatelessWidget {
  final String productId;
  final String? selectedColor;
  final String? selectedSize;
  final String? variantId;

  const AddToCartButton({super.key, required this.productId, this.selectedColor, this.selectedSize, this.variantId });

 @override
Widget build(BuildContext context) {
  final cartService = CartService();

  return ElevatedButton(
    onPressed: () async {
      await cartService.addToCart(productId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ajouté au panier 🛒")),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 0, 169, 191), // couleur du bouton
      foregroundColor: Colors.white, // couleur du texte
    ),
    child: const Text("Ajouter au panier"),
  );
}
}