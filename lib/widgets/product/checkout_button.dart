import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/order_service.dart';

class CheckoutButton extends StatefulWidget {
  final VoidCallback onSuccess;

  const CheckoutButton({
    super.key,
    required this.onSuccess,
  });

  @override
  State<CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<CheckoutButton> {
  final service = OrderService();
  bool loading = false;

  Future<void> handleCheckout() async {
    setState(() => loading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      await service.checkout(user.id);

      widget.onSuccess();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Commande envoyée ✅")),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : handleCheckout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 0, 169, 191) , // bleu moderne
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 20,color: Colors.white),
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