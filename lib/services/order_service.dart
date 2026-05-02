import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';

class OrderService {
  final supabase = Supabase.instance.client;

  Future<List<OrderModel>> getOrders() async {
    final response = await supabase
        .from('orders')
        .select('*, delivery_companies(name)')
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => OrderModel.fromJson(e))
        .toList();
  }

  /// Checkout COMPLET avec livraison
  Future<void> checkout({
    required String userId,
    required String deliveryCompanyId,
    required String deliveryCompanyName,
    required String deliveryType, // 'standard' ou 'express'
    required String deliveryAddress,
    required String deliveryCity,
    required String deliveryPhone,
    required double deliveryPrice,
    required String estimatedDelivery,
    required String shopId,
  }) async {
    // 1. Récupérer le panier
    final cartItems = await supabase
        .from('cart_items')
        .select()
        .eq('user_id', userId);

    if (cartItems.isEmpty) return;

    // 2. Calculer total produits
    double total = 0;
    for (var item in cartItems) {
      double price = (item['price'] ?? 0).toDouble();
      double itemTotal = price * item['quantity'];
      if ((item['discount'] ?? 0) > 0) {
        itemTotal -= itemTotal * (item['discount'] / 100);
      }
      total += itemTotal;
    }

    // 3. Ajouter frais de livraison
    final totalWithDelivery = total + deliveryPrice;

    // 4. Créer la commande
    final order = await supabase
        .from('orders')
        .insert({
          'user_id': userId,
          'total': totalWithDelivery,
          'status': 'pending',
          'shop_id': shopId,
          // 🚚 Livraison
          'delivery_company_id': deliveryCompanyId,
          'delivery_type': deliveryType,
          'delivery_address': deliveryAddress,
          'delivery_city': deliveryCity,
          'delivery_phone': deliveryPhone,
          'delivery_status': 'pending',
          'delivery_price': deliveryPrice,
          'estimated_delivery': estimatedDelivery,
        })
        .select()
        .single();

    final orderId = order['id'];

    // 5. Insérer les items de la commande
    for (var item in cartItems) {
      await supabase.from('order_items').insert({
        'order_id': orderId,
        'product_id': item['product_id'],
        'quantity': item['quantity'],
        'price': item['price'],
      });
    }

    // 6. Vider le panier
    await supabase.from('cart_items').delete().eq('user_id', userId);

    // 7. Notification avec entreprise de livraison
    final shortId = orderId.toString().substring(0, 6).toUpperCase();

    await supabase.from('notifications').insert({
      'user_id': userId,
      'title': 'Commande #$shortId confirmée ✅',
      'body':
          'Votre commande sera livrée par $deliveryCompanyName ($deliveryType). Délai estimé : $estimatedDelivery',
      'type': 'order',
    });
  }

  /// Update status + notification
  Future<void> updateStatus(String orderId, String status) async {
    await supabase
        .from('orders')
        .update({'status': status}).eq('id', orderId);

    final order = await supabase
        .from('orders')
        .select('user_id, delivery_companies(name)')
        .eq('id', orderId)
        .single();

    final userId = order['user_id'];
    final companyName =
        (order['delivery_companies'] as Map?)?['name'] ?? 'le livreur';
    final shortId = orderId.substring(0, 6).toUpperCase();

    String title = '';
    String body = '';

    switch (status) {
      case 'confirmed':
        title = 'Commande confirmée ✅';
        body = 'Votre commande #$shortId a été confirmée';
        break;
      case 'shipped':
        title = 'Commande expédiée 🚚';
        body =
            'Votre commande #$shortId est en route avec $companyName';
        break;
      case 'delivered':
        title = 'Commande livrée 📦';
        body =
            'Votre commande #$shortId a été livrée avec succès. Merci !';
        break;
      case 'cancelled':
        title = 'Commande annulée ❌';
        body = 'Votre commande #$shortId a été annulée';
        break;
      default:
        title = 'Mise à jour commande';
        body = 'Statut : $status';
    }

    await supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
      'type': 'order',
    });
  }
}
