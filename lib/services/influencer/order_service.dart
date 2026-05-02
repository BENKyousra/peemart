import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/order_model.dart';

class OrderService {
  final supabase = Supabase.instance.client;

  Future<List<OrderModel>> getOrders() async {
    final response = await supabase
        .from('orders')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<void> checkout({
    required String userId,
    String? influencerCode,
  }) async {
    // 1. get cart
    final cartItems = await supabase
        .from('cart_items')
        .select()
        .eq('user_id', userId);

    if (cartItems.isEmpty) return;

    // 2. calculate total
    double total = 0;
    for (var item in cartItems) {
      double price = (item['price'] ?? 0).toDouble();
      double itemTotal = price * item['quantity'];
      if ((item['discount'] ?? 0) > 0) {
        itemTotal -= itemTotal * item['discount'];
      }
      total += itemTotal;
    }

    // 3. create order 🔥 مع influencer_code
    final order =
        await supabase
            .from('orders')
            .insert({
              'user_id': userId,
              'total': total,
              'status': 'pending',
              if (influencerCode != null) 'influencer_code': influencerCode,
            })
            .select()
            .single();

    final orderId = order['id'];

    // 4. notification
    await supabase.from('notifications').insert({
      'user_id': userId,
      'title': 'Commande créée 🛒',
      'body':
          'Votre commande #${orderId.toString().substring(0, 6)} est en attente de traitement',
    });

    // 5. insert order_items
    for (var item in cartItems) {
      await supabase.from('order_items').insert({
        'order_id': orderId,
        'product_id': item['product_id'],
        'quantity': item['quantity'],
        'price': item['price'],
      });
    }

    // 6. clear cart
    await supabase.from('cart_items').delete().eq('user_id', userId);

    // 7. notification finale
    await supabase.from('notifications').insert({
      'user_id': userId,
      'title': 'Commande validée ✅',
      'body': 'Votre commande a été enregistrée avec succès',
    });
  }
}
