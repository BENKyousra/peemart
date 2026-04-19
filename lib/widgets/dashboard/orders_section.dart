import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '/pages/products/order_details_page.dart';

class OrdersSection extends StatefulWidget {
  const OrdersSection({super.key});

  @override
  State<OrdersSection> createState() => _OrdersSectionState();
}

class _OrdersSectionState extends State<OrdersSection> {
  final OrderService service = OrderService();
  final supabase = Supabase.instance.client;

  late Future<List<OrderModel>> orders;

  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    orders = service.getOrders();
  }

  // 🔥 UPDATE STATUS
  Future<void> updateStatus(String orderId, String status) async {
  // 1. update order
  await supabase
      .from('orders')
      .update({'status': status})
      .eq('id', orderId);

  // 2. get user_id of order
  final order = await supabase
      .from('orders')
      .select('user_id')
      .eq('id', orderId)
      .single();

  final userId = order['user_id'];

  // 3. message dynamique selon status
  String title = "Commande mise à jour";
  String body = "";

  switch (status) {
    case 'confirmed':
      body = "Votre commande a été confirmée ✅";
      break;
    case 'shipped':
      body = "Votre commande a été expédiée 🚚";
      break;
    case 'delivered':
      body = "Votre commande est livrée 📦";
      break;
    case 'cancelled':
      body = "Votre commande a été annulée ❌";
      break;
    default:
      body = "Statut mis à jour : $status";
  }

  // 4. insert notification
  await supabase.from('notifications').insert({
    'user_id': userId,
    'title': title,
    'body': body,
  });

  // 5. refresh UI
  setState(() {
    orders = service.getOrders();
  });
}

  // 🔥 COLOR STATUS
  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 🔥 FILTER CHIP
  Widget filterChip(String status) {
  final isSelected = selectedFilter == status.toLowerCase();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: ChoiceChip(
      label: Text(
        status,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),

      selected: isSelected,

      onSelected: (value) {
        setState(() {
          selectedFilter = status.toLowerCase();
        });
      },

      // 🎨 COLORS
      selectedColor: Color.fromARGB(255, 0, 169, 191),
      backgroundColor: Colors.grey.shade200,
      labelStyle: const TextStyle(color: Colors.black),

      // bordure (optionnel mais pro)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Color.fromARGB(255, 0, 169, 191): Colors.grey.shade300,
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderModel>>(
      future: orders,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucune commande"));
        }

        // 🔥 FILTER LOGIC
        final data = selectedFilter == 'all'
            ? snapshot.data!
            : snapshot.data!
                .where((o) => o.status == selectedFilter)
                .toList();

        return Column(
          children: [
            // 🔥 FILTER BAR
            Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    filterChip("All"),
                    filterChip("pending"),
                    filterChip("confirmed"),
                    filterChip("shipped"),
                    filterChip("delivered"),
                  ],
                ),
              ),
            ),

            // 🔥 LIST
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final order = data[index];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Commande #${order.id.substring(0, 6)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                order.status,
                                style: TextStyle(
                                  color: getStatusColor(order.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // 🔹 TOTAL
                          Text(
                            "Total: ${order.total} DA",
                            style: const TextStyle(fontSize: 15),
                          ),

                          const SizedBox(height: 10),

                          // 🔥 ACTION BUTTONS
                          Wrap(
  spacing: 8,
  children: [
    if (order.status == 'pending')
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => updateStatus(order.id, 'confirmed'),
        child: const Text("Confirm"),
      ),

    if (order.status == 'confirmed')
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => updateStatus(order.id, 'shipped'),
        child: const Text("Ship"),
      ),

    if (order.status == 'shipped')
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => updateStatus(order.id, 'delivered'),
        child: const Text("Deliver"),
      ),
  ],
),

                          // 🔥 DETAILS BUTTON
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OrderDetailsPage(
                                            orderId: order.id),
                                  ),
                                );
                              },
                              child: const Text("Voir détails →",style: TextStyle(color: Color.fromARGB(255, 0, 169, 191)),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}