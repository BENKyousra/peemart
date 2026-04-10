import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  // 🔹 récupérer shop_id
  Future<String> getUserShopId() async {
    final user = supabase.auth.currentUser;

    final res = await supabase
        .from('shops')
        .select('id')
        .eq('owner_id', user!.id)
        .single();

    return res['id'];
  }

  // 🔥 upload image
  Future<String> uploadImage(Uint8List bytes) async {
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

    await supabase.storage.from('products').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    return supabase.storage.from('products').getPublicUrl(fileName);
  }

  // 🔹 créer produit
  Future<String> createProduct({
    required String title,
    required String description,
    required double price,
    required String image,
    List<String> colors = const [],
    List<String> sizes = const [],
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
          'colors': colors,
          'sizes': sizes,
        })
        .select()
        .single();

    return res['id'];
  }

  // 🔹 ajouter images galerie
  Future<void> addImages({
    required String productId,
    required List<String> images,
  }) async {
    final data = images.map((url) {
      return {
        'product_id': productId,
        'image_url': url,
      };
    }).toList();

    await supabase.from('product_images').insert(data);
  }

  // 🔥 update produit
  Future<void> updateProduct({
    required String id,
    required String title,
    required String description,
    required double price,
    String? image,
  }) async {
    final data = {
      'title': title,
      'description': description,
      'price': price,
    };

    if (image != null && image.isNotEmpty) {
      data['image'] = image;
    }

    await supabase.from('products').update(data).eq('id', id);
  }

  // 🔥 supprimer produit
  Future<void> deleteProduct(String id) async {
    await supabase.from('product_images').delete().eq('product_id', id);
    await supabase.from('product_variants').delete().eq('product_id', id);
    await supabase.from('products').delete().eq('id', id);
  }

  // 🔥 supprimer UNE image
  Future<void> deleteSingleImage({
    required String productId,
    required String imageUrl,
  }) async {
    await supabase
        .from('product_images')
        .delete()
        .eq('product_id', productId)
        .eq('image_url', imageUrl);
  }

  // 🔥 update variantes (REPLACE COMPLET)
  Future<void> updateVariants({
    required String productId,
    required List<Map<String, dynamic>> variants,
  }) async {
    // ❗ supprimer anciennes variantes
    await supabase
        .from('product_variants')
        .delete()
        .eq('product_id', productId);

    // ❗ ajouter nouvelles variantes
    if (variants.isNotEmpty) {
      await supabase.from('product_variants').insert(
            variants.map((v) {
              return {
                'product_id': productId,
                'color': v['color'],
                'size': v['size'],
                'stock': v['stock'],
                'price': v['price'],
              };
            }).toList(),
          );
    }
  }

  // 🔥 récupérer variantes
  Future<List<Map<String, dynamic>>> getVariants(String productId) async {
    final response = await supabase
        .from('product_variants')
        .select()
        .eq('product_id', productId);

    return List<Map<String, dynamic>>.from(response);
  }
}