import 'package:flutter/material.dart';
import '../../services/cart_service.dart';
import '../../services/promo_service.dart';
import '../../models/cart_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final cartService = CartService();
  final refreshNotifier = ValueNotifier(0);
  final promoService = PromoService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Panier")),

      body: ValueListenableBuilder(
        valueListenable: refreshNotifier,
        builder: (context, value, _) {
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: cartService.cartStreamRaw(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return FutureBuilder<List<CartModel>>(
                future: cartService.buildCart(snapshot.data!),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = snap.data!;

                  double total = 0;

                  for (var item in items) {
                    double itemTotal = item.price * item.quantity;

                    if (item.discount > 0) {
                      itemTotal = itemTotal - (itemTotal * item.discount);
                    }

                    total += itemTotal;
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];

                            final promoController = TextEditingController();

                            return Card(
                              margin: const EdgeInsets.all(10),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Image.network(
                                          item.imageUrl,
                                          width: 80,
                                          height: 80,
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              Text("${item.price} DA"),

                                              if (item.selectedColor != null)
                                                Text(
                                                  "Couleur: ${item.selectedColor}",
                                                ),

                                              if (item.selectedSize != null)
                                                Text(
                                                  "Taille: ${item.selectedSize}",
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    // 🔥 PROMO PRODUIT
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: promoController,
                                            decoration: InputDecoration(
                                              hintText: "Code promo produit",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),

                                        IconButton(
                                          icon: const Icon(Icons.check),
                                          onPressed: () async {
                                            String code =
                                                promoController.text.trim();

                                            final promo = await promoService
                                                .validatePromo(
                                                  productId: item.productId,
                                                  code: code,
                                                );

                                            if (promo == null) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Code invalide ❌",
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            await cartService.applyPromoToItem(
                                              itemId: item.id,
                                              code: code,
                                              discount: promo.discount,
                                            );

                                            await promoService.incrementUsage(
                                              promo.id,
                                            );

                                            refreshNotifier.value++;
                                          },
                                        ),
                                      ],
                                    ),

                                    if (item.discount > 0)
                                      Text(
                                        "-${(item.discount * 100).toInt()}% appliqué",
                                        style: const TextStyle(
                                          color: Colors.green,
                                        ),
                                      ),

                                    const SizedBox(height: 10),

                                    // 🔢 QUANTITY
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            if (item.quantity > 1) {
                                              cartService.updateQuantity(
                                                item.id,
                                                item.quantity - 1,
                                              );
                                            }
                                          },
                                        ),
                                        Text("${item.quantity}"),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            cartService.updateQuantity(
                                              item.id,
                                              item.quantity + 1,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () async {
                                            await cartService.removeItem(
                                              item.id,
                                            );
                                            refreshNotifier.value++;
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // 🔥 TOTAL
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              "Total: ${total.toStringAsFixed(0)} DA",
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text("Commander"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
