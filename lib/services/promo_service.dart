import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/promo_model.dart';

class PromoService {
  final supabase = Supabase.instance.client;

  // 🔍 VALIDER PROMO
  Future<PromoModel?> validatePromo({
    required String productId,
    required String code,
  }) async {
    final res = await supabase
        .from('promotions')
        .select()
        .eq('product_id', productId)
        .eq('code', code)
        .maybeSingle();

    if (res == null) return null;

    final promo = PromoModel.fromMap(res);

    // ⏳ expiration
    if (promo.expiresAt != null &&
        DateTime.now().isAfter(promo.expiresAt!)) {
      return null;
    }

    // 🔒 limite usage
    if (promo.usedCount >= promo.maxUsage) {
      return null;
    }

    return promo;
  }

  // 🔥 increment usage
  Future<void> incrementUsage(String promoId) async {
    await supabase.rpc('increment_promo_usage', params: {
      'promo_id': promoId,
    });
  }
}