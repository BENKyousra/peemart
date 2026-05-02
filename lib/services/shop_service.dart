import 'package:supabase_flutter/supabase_flutter.dart';

class ShopService {
  final SupabaseClient supabase = Supabase.instance.client;

  // 👤 GET MY SHOP (owner)
  Future<Map<String, dynamic>?> getMyShop() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final res = await supabase
        .from('shops')
        .select()
        .eq('owner_id', user.id)
        .maybeSingle();

    return res;
  }

  // 🏪 GET ALL SHOPS
  Future<List<Map<String, dynamic>>> getAllShops() async {
    final res = await supabase.from('shops').select('*');
    return List<Map<String, dynamic>>.from(res);
  }

  // 📍 GET SHOPS BY WILAYA (recommended DB field)
  Future<List<Map<String, dynamic>>> getShopsByWilaya(String wilaya) async {
    final res = await supabase
        .from('shops')
        .select('*')
        .ilike('location', '%$wilaya%'); // flexible matching

    return List<Map<String, dynamic>>.from(res);
  }

  // 🔍 SEARCH SHOPS
  Future<List<Map<String, dynamic>>> searchShops(String query) async {
    final res = await supabase
        .from('shops')
        .select('*')
        .ilike('name', '%$query%');

    return List<Map<String, dynamic>>.from(res);
  }

  // ➕ CREATE SHOP
  Future<void> createShop(Map<String, dynamic> data) async {
    await supabase.from('shops').insert(data);
  }

  // ✏️ UPDATE SHOP
  Future<void> updateShop(String id, Map<String, dynamic> data) async {
    await supabase.from('shops').update(data).eq('id', id);
  }

  // ❌ DELETE SHOP
  Future<void> deleteShop(String id) async {
    await supabase.from('shops').delete().eq('id', id);
  }
}