import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_model.dart';

class CartService {
  final supabase = Supabase.instance.client;

  // 🔹 STREAM SIMPLE
  Stream<List<Map<String, dynamic>>> cartStreamRaw() {
    final user = supabase.auth.currentUser;
    if (user == null) return const Stream.empty();

    return supabase
        .from('cart_items')
        .stream(primaryKey: ['id'])
        .map((event) => List<Map<String, dynamic>>.from(event));
  }

  // ✅ BUILD CART — JOIN products + shops pour avoir shop_id, shop_name, shop_avatar
  Future<List<CartModel>> buildCart(
      List<Map<String, dynamic>> cartData) async {
    if (cartData.isEmpty) return [];

    final productIds = cartData.map((e) => e['product_id']).toList();

    // ✅ JOIN avec shops pour récupérer les infos du shop
    final products = await supabase
        .from('products')
        .select('*, shops(id, name, avatar)')
        .in_('id', productIds);

    return cartData.map((item) {
      final product = (products as List).firstWhere(
        (p) => p['id'] == item['product_id'],
      );

      final shop = product['shops'] as Map<String, dynamic>?;

      return CartModel(
        id: item['id'],
        productId: item['product_id'],
        quantity: item['quantity'],
        title: product['title'] ?? '',
        price: (product['price'] as num).toDouble(),
        imageUrl: product['image'] ?? '',
        // ✅ shop_id vient du produit directement (FK)
        shopId: product['shop_id'] ?? '',
        // ✅ shop_name et avatar viennent du JOIN shops
        shopName: shop?['name'] ?? '',
        shopAvatar: shop?['avatar'] ?? '',
        rating: (product['rating'] as num?)?.toDouble() ?? 0.0,
        description: product['description'] ?? '',
        discount: (item['discount'] as num?)?.toDouble() ?? 0.0,
        promoCode: item['promo_code'],
      );
    }).toList();
  }

  // 🔹 ADD TO CART
  Future<void> addToCart(String productId) async {
    final user = supabase.auth.currentUser;

    final product = await supabase
        .from('products')
        .select('price')
        .eq('id', productId)
        .single();

    final existing = await supabase
        .from('cart_items')
        .select()
        .eq('user_id', user!.id)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      await supabase.from('cart_items').update({
        'quantity': existing['quantity'] + 1,
      }).eq('id', existing['id']);
    } else {
      await supabase.from('cart_items').insert({
        'user_id': user.id,
        'product_id': productId,
        'quantity': 1,
        'price': product['price'],
      });
    }
  }

  // 🔹 REMOVE
  Future<void> removeItem(String id) async {
    await supabase.from('cart_items').delete().eq('id', id);
    supabase.realtime.disconnect();
    supabase.realtime.connect();
  }

  // 🔹 UPDATE QTY
  Future<void> updateQuantity(String id, int qty) async {
    await supabase
        .from('cart_items')
        .update({'quantity': qty}).eq('id', id);
  }

  // 🔹 APPLY PROMO
  Future<void> applyPromoToItem({
    required String itemId,
    required String code,
    required double discount,
  }) async {
    await supabase.from('cart_items').update({
      'promo_code': code,
      'discount': discount,
    }).eq('id', itemId);
  }
}