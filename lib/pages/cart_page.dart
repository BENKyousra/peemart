import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../models/cart_model.dart';
import '../pages/product_detail_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final cartService = CartService();
  final refreshNotifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 0, 1, 59),
                Color.fromARGB(255, 0, 2, 105),
              ],
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Mon Panier',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),

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
                    total += item.price * item.quantity;
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProductDetailPage(
                                          productId: item.productId,
                                          title: item.title,
                                          imageUrl: item.imageUrl,
                                          images: [item.imageUrl],
                                          price: item.price,
                                          shopName: item.shopName,
                                          shopId: item.shopId,
                                          shopAvatar: item.shopAvatar,
                                          rating: item.rating,
                                          description: item.description,
                                        ),
                                  ),
                                );
                              },
                              leading: Image.network(
                                item.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.black, // 🔥 couleur du titre
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),

                              subtitle: Text(
                                "${item.price} DA",
                                style: const TextStyle(
                                  color: Color.fromARGB(
                                                255,
                                                0,
                                                169,
                                                191), // 🔥 couleur du prix
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove,
                                      color: Colors.red, // 🔥 couleur bouton -
                                    ),
                                    onPressed: () {
                                      if (item.quantity > 1) {
                                        cartService.updateQuantity(
                                          item.id,
                                          item.quantity - 1,
                                        );
                                      }
                                    },
                                  ),

                                  Text(
                                    "${item.quantity}",
                                    style: const TextStyle(
                                      color: Colors.blue, // 🔥 couleur quantité
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color:
                                          Colors.green, // 🔥 couleur bouton +
                                    ),
                                    onPressed: () {
                                      cartService.updateQuantity(
                                        item.id,
                                        item.quantity + 1,
                                      );
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color:
                                          Colors.redAccent, // 🔥 couleur delete
                                    ),
                                    onPressed: () async {
                                      await cartService.removeItem(item.id);
                                      refreshNotifier.value++;
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              "Total: $total DA",
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
