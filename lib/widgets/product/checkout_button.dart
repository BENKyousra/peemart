import 'package:flutter/material.dart';
import '../../models/cart_model.dart';
import '../../pages/products/checkout_page.dart';

class CheckoutButton extends StatelessWidget {
  final List<CartModel> cartItems;
  final double subtotal;
  final VoidCallback onSuccess;

  const CheckoutButton({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CheckoutPage(
                cartItems: cartItems,
                subtotal: subtotal,
              ),
            ),
          ).then((_) => onSuccess());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 0, 169, 191),
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Commander",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
