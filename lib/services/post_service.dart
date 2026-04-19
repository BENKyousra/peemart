import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getPosts() async {
    final response = await supabase
        .from('posts')
        .select('''
  *,
  influencers (
    id,
    name,
    avatar,
    is_verified,
    discount_code
  ),
  products (
    id,
    title,
    description,
    price,
    image,
    is_sponsored,
    product_images (
      image_url
    )
  ),
  post_images (
    image_url
  )
''')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getMyInfluencer() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    final res =
        await supabase
            .from('influencers')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

    return res;
  }

  Future<void> addPost({
    required String influencerId,
    required String productId,
    required String description,
  }) async {
    await supabase.from('posts').insert({
      'influencer_id': influencerId,
      'product_id': productId,
      'description': description,
    });
  }

  Future<String> uploadPostImage(Uint8List bytes) async {
    final fileName = "post_${DateTime.now().millisecondsSinceEpoch}.jpg";

    await supabase.storage
        .from('posts')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpg'),
        );

    return supabase.storage.from('posts').getPublicUrl(fileName);
  }

  Future<void> addPostWithImages({
    required String influencerId,
    required String productId,
    required String description,
    required List<String> imageUrls,
  }) async {
    // 🔹 إنشاء post
    final post =
        await supabase
            .from('posts')
            .insert({
              'influencer_id': influencerId,
              'product_id': productId,
              'description': description,
            })
            .select()
            .single();

    final postId = post['id'];

    // 🔹 إضافة الصور
    final imagesData =
        imageUrls
            .asMap()
            .entries
            .map(
              (entry) => {
                'post_id': postId,
                'image_url': entry.value,
                'display_order': entry.key,
              },
            )
            .toList();

    await supabase.from('post_images').insert(imagesData);
  }
}