import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackService {
  final supabase = Supabase.instance.client;

  // ==============================
  // 📥 GET FEEDBACKS (feed)
  // ==============================
  Future<List<Map<String, dynamic>>> getFeedbacks() async {
    final response = await supabase
        .from('feedbacks')
        .select('''
          id,
          content,
          created_at,
          user_id,
          users(username, avatar_url),
          feedback_images(image_url, display_order)
        ''')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ==============================
  // 🆕 CREATE FEEDBACK
  // ==============================
  Future<String?> createFeedback({
    required String content,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('feedbacks')
        .insert({
          'user_id': user.id,
          'content': content.trim(),
        })
        .select('id')
        .single();

    return response['id'];
  }

  // ==============================
  // ☁️ UPLOAD IMAGE (Supabase Storage)
  // ==============================
  Future<String> uploadImage({
    required Uint8List bytes,
    required String bucketName,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${supabase.auth.currentUser!.id}.jpg';

    await supabase.storage
        .from(bucketName)
        .uploadBinary(fileName, bytes);

    final url = supabase.storage
        .from(bucketName)
        .getPublicUrl(fileName);

    return url;
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
  // 🚀 CREATE FULL FEEDBACK (TEXT + IMAGES)
  // ==============================
  Future<void> createFullFeedback({
    required String content,
    required List<Uint8List> images,
    Uint8List? mainImage,
    String bucket = 'feedback-images',
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // 1. create feedback
    final feedbackId = await createFeedback(content: content);
    if (feedbackId == null) return;

    int index = 0;

    // 2. upload main image first
    if (mainImage != null) {
      final url = await uploadImage(
        bytes: mainImage,
        bucketName: bucket,
      );

      await addImageToFeedback(
        feedbackId: feedbackId,
        imageUrl: url,
        order: index,
      );

      index++;
    }

    // 3. upload gallery images
    for (final img in images) {
      final url = await uploadImage(
        bytes: img,
        bucketName: bucket,
      );

      await addImageToFeedback(
        feedbackId: feedbackId,
        imageUrl: url,
        order: index,
      );

      index++;
    }
  }

  // ==============================
  // ❤️ LIKE FEEDBACK
  // ==============================
  Future<void> likeFeedback(String feedbackId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('feedback_likes').insert({
      'feedback_id': feedbackId,
      'user_id': user.id,
    });
  }

  // ==============================
  // 💔 UNLIKE FEEDBACK
  // ==============================
  Future<void> unlikeFeedback(String feedbackId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase
        .from('feedback_likes')
        .delete()
        .match({
          'feedback_id': feedbackId,
          'user_id': user.id,
        });
  }

  // ==============================
  // 🔢 COUNT LIKES
  // ==============================
  Future<int> getLikesCount(String feedbackId) async {
    final res = await supabase
        .from('feedback_likes')
        .select('id')
        .eq('feedback_id', feedbackId);

    return (res as List).length;
  }

  // ==============================
  // 🧠 CHECK IF USER LIKED
  // ==============================
  Future<bool> isLiked(String feedbackId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    final res = await supabase
        .from('feedback_likes')
        .select('id')
        .match({
          'feedback_id': feedbackId,
          'user_id': user.id, 
        });

    return (res as List).isNotEmpty;
  }

  Future<void> deleteFeedback(String feedbackId) async {
  final user = supabase.auth.currentUser;
  if (user == null) return;

  // 1. delete images first
  await supabase
      .from('feedback_images')
      .delete()
      .eq('feedback_id', feedbackId);

  // 2. delete likes
  await supabase
      .from('feedback_likes')
      .delete()
      .eq('feedback_id', feedbackId);

  // 3. delete feedback
  await supabase
      .from('feedbacks')
      .delete()
      .eq('id', feedbackId);
}
}