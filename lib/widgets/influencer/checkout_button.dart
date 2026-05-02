import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/influencer/order_service.dart';

class CheckoutButton extends StatefulWidget {
  final VoidCallback onSuccess;

  const CheckoutButton({super.key, required this.onSuccess});

  @override
  State<CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<CheckoutButton> {
  final service = OrderService();
  final influencerCodeController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    influencerCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔥 حقل كود المؤثر
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: influencerCodeController,
                decoration: InputDecoration(
                  hintText: "Code influenceur (optionnel)",
                  prefixIcon: const Icon(Icons.stars_rounded, color: Color.fromARGB(255, 0, 2, 105)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loading
                ? null
                : () async {
                    setState(() => loading = true);

                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) return;

                    final code = influencerCodeController.text.trim();

                    await service.checkout(
                      userId: user.id,
                      influencerCode: code.isNotEmpty ? code : null,
                    );

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
        ),
      ],
    );
  }
}