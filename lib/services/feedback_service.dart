import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackService {
  final supabase = Supabase.instance.client;

  // ==============================
  // 📥 GET FEEDBACKS
  // mentions vient directement de la colonne jsonb feedbacks.mentions
  // ==============================
  Future<List<Map<String, dynamic>>> getFeedbacks() async {
    final response = await supabase
        .from('feedbacks')
        .select('''
          id,
          content,
          created_at,
          user_id,
          mentions,
          users(username, avatar_url),
          feedback_images(image_url, display_order)
        ''')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ==============================
  // 🆕 CREATE FEEDBACK + MENTIONS JSONB
  // ==============================
  Future<String?> createFeedback({
    required String content,
    required List<Map<String, dynamic>> taggedShops, // [{id, name}]
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    // Build mentions jsonb: [{id, name, type: 'shop'}]
    final mentions = taggedShops
        .map((s) => {'id': s['id'], 'name': s['name'], 'type': 'shop'})
        .toList();

    final response = await supabase
        .from('feedbacks')
        .insert({
          'user_id': user.id,
          'content': content.trim(),
          'mentions': mentions,
        })
        .select('id')
        .single();

    return response['id'];
  }

  // ==============================
  // 🏷 INSERT TAGS (feedback_tags table)
  // ==============================
  Future<void> insertTags({
    required String feedbackId,
    required List<String> shopIds,
  }) async {
    if (shopIds.isEmpty) return;

    final rows = shopIds
        .toSet()
        .map((id) => {'feedback_id': feedbackId, 'shop_id': id})
        .toList();

    await supabase.from('feedback_tags').insert(rows);
  }

  // ==============================
  // ☁️ UPLOAD IMAGE
  // ==============================
  Future<String> uploadImage({
    required Uint8List bytes,
    required String bucketName,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${supabase.auth.currentUser!.id}.jpg';

    await supabase.storage.from(bucketName).uploadBinary(fileName, bytes);
    return supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  // ==============================
  // 🖼 ADD IMAGE TO FEEDBACK
  // ==============================
  Future<void> addImageToFeedback({
    required String feedbackId,
    required String imageUrl,
    required int order,
  }) async {
    await supabase.from('feedback_images').insert({
      'feedback_id': feedbackId,
      'image_url': imageUrl,
      'display_order': order,
    });
  }

  // ==============================
  // 🚀 CREATE FULL FEEDBACK (TEXT + IMAGES + TAGS)
  // ==============================
  Future<void> createFullFeedback({
    required String content,
    required List<Uint8List> images,
    required List<Map<String, dynamic>> taggedShops, // [{id, name}]
    Uint8List? mainImage,
    String bucket = 'feedback-images',
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // 1. Create feedback row (with mentions jsonb)
    final feedbackId = await createFeedback(
      content: content,
      taggedShops: taggedShops,
    );
    if (feedbackId == null) return;

    // 2. Insert rows in feedback_tags
    final shopIds =
        taggedShops.map<String>((s) => s['id'] as String).toList();
    await insertTags(feedbackId: feedbackId, shopIds: shopIds);

    int index = 0;

    // 3. Main image
    if (mainImage != null) {
      final url = await uploadImage(bytes: mainImage, bucketName: bucket);
      await addImageToFeedback(
          feedbackId: feedbackId, imageUrl: url, order: index);
      index++;
    }

    // 4. Gallery images
    for (final img in images) {
      final url = await uploadImage(bytes: img, bucketName: bucket);
      await addImageToFeedback(
          feedbackId: feedbackId, imageUrl: url, order: index);
      index++;
    }
  }

  // ==============================
  // ❤️ LIKE / UNLIKE
  // ==============================
  Future<void> likeFeedback(String feedbackId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    await supabase
        .from('feedback_likes')
        .insert({'feedback_id': feedbackId, 'user_id': user.id});
  }

  Future<void> unlikeFeedback(String feedbackId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    await supabase
        .from('feedback_likes')
        .delete()
        .match({'feedback_id': feedbackId, 'user_id': user.id});
  }

  Future<int> getLikesCount(String feedbackId) async {
    final res = await supabase
        .from('feedback_likes')
        .select('id')
        .eq('feedback_id', feedbackId);
    return (res as List).length;
  }

  Future<bool> isLiked(String feedbackId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;
    final res = await supabase
        .from('feedback_likes')
        .select('id')
        .match({'feedback_id': feedbackId, 'user_id': user.id});
    return (res as List).isNotEmpty;
  }

  // ==============================
  // 🗑 DELETE FEEDBACK
  // ==============================
  Future<void> deleteFeedback(String feedbackId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase
        .from('feedback_images')
        .delete()
        .eq('feedback_id', feedbackId);
    await supabase
        .from('feedback_likes')
        .delete()
        .eq('feedback_id', feedbackId);
    await supabase
        .from('feedback_tags')
        .delete()
        .eq('feedback_id', feedbackId);
    await supabase.from('feedbacks').delete().eq('id', feedbackId);
  }
}