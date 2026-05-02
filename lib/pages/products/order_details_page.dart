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

  Future<Map<String, dynamic>> fetchOrderDetails() async {
    // Récupérer la commande + entreprise de livraison
    final order = await supabase
        .from('orders')
        .select('*, delivery_companies(name, logo_url, phone)')
        .eq('id', widget.orderId)
        .single();

    // Récupérer les items
    final items = await supabase
        .from('order_items')
        .select('*, products(title, image)')
        .eq('order_id', widget.orderId);

    return {
      'order': order,
      'items': items,
    };
  }

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

  String getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'shipped':
        return 'Expédiée';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 0, 169, 191);
    const darkBlue = Color.fromARGB(255, 0, 1, 59);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [darkBlue, Color.fromARGB(255, 0, 2, 105)],
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Détails commande',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchOrderDetails(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final order =
              snapshot.data!['order'] as Map<String, dynamic>;
          final items =
              snapshot.data!['items'] as List<dynamic>;
          final company =
              order['delivery_companies'] as Map<String, dynamic>?;

          final shortId =
              widget.orderId.substring(0, 6).toUpperCase();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── STATUT ─────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Commande #$shortId',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(order['status'])
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              getStatusLabel(order['status']),
                              style: TextStyle(
                                color:
                                    getStatusColor(order['status']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Total : ${order['total']} DA',
                        style: const TextStyle(
                            fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ─── LIVRAISON ───────────────────────────────
                if (company != null) ...[
                  _sectionTitle('🚚 Informations de livraison'),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Entreprise
                        Row(
                          children: [
                            if (company['logo_url'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  company['logo_url'],
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.local_shipping,
                                          size: 44),
                                ),
                              )
                            else
                              const Icon(Icons.local_shipping,
                                  size: 44, color: Colors.grey),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  company['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                if (company['phone'] != null)
                                  Text(
                                    company['phone'],
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        _infoRow(Icons.local_shipping_outlined,
                            'Type', order['delivery_type'] ?? '-'),
                        _infoRow(Icons.home_outlined, 'Adresse',
                            order['delivery_address'] ?? '-'),
                        _infoRow(Icons.location_city_outlined,
                            'Ville', order['delivery_city'] ?? '-'),
                        _infoRow(Icons.phone_outlined, 'Téléphone',
                            order['delivery_phone'] ?? '-'),
                        _infoRow(Icons.schedule_outlined,
                            'Délai estimé',
                            order['estimated_delivery'] ?? '-'),
                        _infoRow(
                          Icons.payments_outlined,
                          'Frais livraison',
                          '${order['delivery_price'] ?? 0} DA',
                        ),
                        if (order['tracking_code'] != null)
                          _infoRow(Icons.qr_code_outlined,
                              'Code suivi',
                              order['tracking_code']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ─── PRODUITS ────────────────────────────────
                _sectionTitle('📦 Produits commandés'),
                const SizedBox(height: 10),

                ...items.map((item) {
                  final product =
                      item['products'] as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            product['image'] ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['title'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Qté: ${item['quantity']}  •  ${item['price']} DA',
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(item['price'] * item['quantity']).toStringAsFixed(0)} DA',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 0, 1, 59),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label : ',
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
