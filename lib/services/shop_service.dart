import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopService {
  final SupabaseClient supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  // =========================
  // 👤 GET SHOP
  // =========================
  Future<Map<String, dynamic>?> getMyShop() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    return await supabase
        .from('shops')
        .select('*')
        .eq('owner_id', user.id)
        .maybeSingle();
  }

  // =========================
  // 📸 PICK IMAGE
  // =========================
  Future<Uint8List?> pickImageBytes() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return null;

    return await image.readAsBytes();
  }

  // =========================
  // 👤 UPLOAD AVATAR SHOP
  // =========================
  Future<String?> uploadShopAvatar(
      Uint8List bytes, String shopId) async {
    final bucket = supabase.storage.from('shops');
    final path = '$shopId/avatar.png';

    try {
      await bucket.remove([path]);
      await bucket.uploadBinary(path, bytes);

      String url = bucket.getPublicUrl(path);

      // 🔥 CLEAN URL + CACHE BUSTER
      final finalUrl =
          "$url?v=${DateTime.now().millisecondsSinceEpoch}";

      await supabase
          .from('shops')
          .update({'avatar': finalUrl})
          .eq('id', shopId);

      return finalUrl;
    } catch (e) {
      print("❌ Avatar upload error: $e");
      return null;
    }
  }

  // =========================
  // 🖼️ UPLOAD COVER SHOP
  // =========================
  Future<String?> uploadShopCover(
      Uint8List bytes, String shopId) async {
    final bucket = supabase.storage.from('shops');
    final path = '$shopId/cover.png';

    try {
      await bucket.remove([path]);
      await bucket.uploadBinary(path, bytes);

      String url = bucket.getPublicUrl(path);

      final finalUrl =
          "$url?v=${DateTime.now().millisecondsSinceEpoch}";

      await supabase
          .from('shops')
          .update({'cover_image': finalUrl})
          .eq('id', shopId);

      return finalUrl;
    } catch (e) {
      print("❌ Cover upload error: $e");
      return null;
    }
  }

  // =========================
  // 🏪 UPDATE SHOP NAME
  // =========================
  Future<void> updateShop({
    required String shopId,
    String? name,
  }) async {
    final data = <String, dynamic>{};

    if (name != null && name.isNotEmpty) {
      data['name'] = name;
    }

    if (data.isEmpty) return;

    await supabase
        .from('shops')
        .update(data)
        .eq('id', shopId);
  }

  // =========================
  // 🌍 GET ALL SHOPS
  // =========================
  Future<List<Map<String, dynamic>>> getAllShops() async {
    final res = await supabase.from('shops').select('*');
    return List<Map<String, dynamic>>.from(res);
  }

  // =========================
  // 📍 FILTER BY WILAYA
  // =========================
  Future<List<Map<String, dynamic>>> getShopsByWilaya(
      String wilaya) async {
    final res = await supabase
        .from('shops')
        .select('*')
        .ilike('location', '%$wilaya%');

    return List<Map<String, dynamic>>.from(res);
  }
}