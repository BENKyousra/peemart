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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading
            ? null
            : () async {
                setState(() => loading = true);

                final user = Supabase.instance.client.auth.currentUser;

                if (user == null) return;

                await service.checkout(user.id);

                setState(() => loading = false);

                widget.onSuccess();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Commande envoyée ✅")),
                );
              },
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Commander"),
      ),
    );
  }
}