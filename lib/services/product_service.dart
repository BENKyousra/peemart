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
}