import 'package:supabase_flutter/supabase_flutter.dart';

class ShopService {
  final supabase = Supabase.instance.client;

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
}