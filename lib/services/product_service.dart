import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  // 🔹 récupérer shop_id du user
  Future<String> getUserShopId() async {
    final user = supabase.auth.currentUser;

    final res = await supabase
        .from('shops')
        .select('id')
        .eq('owner_id', user!.id)
        .single();

    return res['id'];
  }

  // 🔥 upload image (WEB)
 Future<String> uploadImage(Uint8List bytes) async {
  final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

  await supabase.storage.from('products').uploadBinary(
    fileName,
    bytes,
    fileOptions: const FileOptions(
      contentType: 'image/jpg',
    ),
  );

  return supabase.storage
      .from('products')
      .getPublicUrl(fileName);
}
  // 🔹 créer produit
  Future<String> createProduct({
    required String title,
    required String description,
    required double price,
    required String image,
  }) async {
    final shopId = await getUserShopId();

    final res = await supabase
        .from('products')
        .insert({
          'title': title,
          'description': description,
          'price': price,
          'image': image,
          'shop_id': shopId,
        })
        .select()
        .single();

    return res['id'];
  }

  // 🔹 images galerie
  Future<void> addImages({
    required String productId,
    required List<String> images,
  }) async {
    final data = images
        .map((url) => {
              'product_id': productId,
              'image_url': url,
            })
        .toList();

    await supabase.from('product_images').insert(data);
  }

  Future<Map<String, dynamic>> getProductById(String productId) async {
  final res = await supabase
      .from('products')
      .select('''
        *,
        influencers(*),
        product_images(*)
      ''')
      .eq('id', productId)
      .single();

    return res;
  }

  Future<int> getLikesCount(String productId) async {
  final res = await supabase
      .from('likes')
      .select()
      .eq('product_id', productId);

   return res.length;
  }

  Future<bool> isLiked(String productId) async {
  final user = supabase.auth.currentUser;

  final res = await supabase
      .from('likes')
      .select()
      .eq('product_id', productId)
      .eq('user_id', user!.id);

    return res.isNotEmpty;
  }

  Future<void> toggleLike(String productId) async {
  final user = supabase.auth.currentUser;

  final existing = await supabase
      .from('likes')
      .select()
      .eq('product_id', productId)
      .eq('user_id', user!.id);

  if (existing.isNotEmpty) {
    await supabase
        .from('likes')
        .delete()
        .eq('product_id', productId)
        .eq('user_id', user.id);
  } else {
    await supabase.from('likes').insert({
      'product_id': productId,
      'user_id': user.id,
    });
  }
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
  final res = await supabase
      .from('products')
      .select('id, title');

  return List<Map<String, dynamic>>.from(res);
}

}