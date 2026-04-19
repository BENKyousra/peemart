import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchItems() async {
    final data = await supabase
        .from('order_items')
        .select('*, products(title, image)')
        .eq('order_id', widget.orderId);

    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Détails commande")),
      body: FutureBuilder(
        future: fetchItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;

          if (items.isEmpty) {
            return const Center(child: Text("Commande vide"));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final product = item['products'];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(
                    product['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product['title']),
                  subtitle: Text(
                    "Qty: ${item['quantity']}  •  ${item['price']} DA",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}