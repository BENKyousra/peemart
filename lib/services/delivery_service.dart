import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/delivery_model.dart';

class DeliveryService {
  final supabase = Supabase.instance.client;

  /// Récupère les entreprises de livraison disponibles pour un shop donné
  Future<List<DeliveryCompanyModel>> getDeliveryCompaniesForShop(
      String shopId) async {
    final res = await supabase
        .from('shop_delivery_companies')
        .select('delivery_companies(*)')
        .eq('shop_id', shopId);

    return (res as List)
        .map((item) =>
            DeliveryCompanyModel.fromJson(item['delivery_companies']))
        .where((c) => c.isActive)
        .toList();
  }

  /// Récupère les entreprises de livraison pour une liste de shop_ids
  /// Retourne Map<shopId, List<DeliveryCompanyModel>>
  Future<Map<String, List<DeliveryCompanyModel>>>
      getDeliveryCompaniesForShops(List<String> shopIds) async {
    if (shopIds.isEmpty) return {};

    final res = await supabase
        .from('shop_delivery_companies')
        .select('shop_id, delivery_companies(*)')
        .in_('shop_id', shopIds);

    final Map<String, List<DeliveryCompanyModel>> result = {};

    for (final item in res as List) {
      final shopId = item['shop_id'] as String;
      final company =
          DeliveryCompanyModel.fromJson(item['delivery_companies']);

      if (!result.containsKey(shopId)) {
        result[shopId] = [];
      }
      if (company.isActive) {
        result[shopId]!.add(company);
      }
    }

    return result;
  }

  /// Récupère les shop_ids des produits dans le panier
  Future<List<String>> getShopIdsFromCart(String userId) async {
    final cartItems = await supabase
        .from('cart_items')
        .select('product_id')
        .eq('user_id', userId);

    if (cartItems.isEmpty) return [];

    final productIds =
        (cartItems as List).map((e) => e['product_id'] as String).toList();

    final products = await supabase
        .from('products')
        .select('shop_id')
        .in_('id', productIds);

    final shopIds =
        (products as List).map((e) => e['shop_id'] as String).toSet().toList();

    return shopIds;
  }
}
