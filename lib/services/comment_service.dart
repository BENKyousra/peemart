import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';

class CommentService {
  final supabase = Supabase.instance.client;

  // 🔹 FETCH (avec username depuis users)
  static Future<List<CommentModel>> fetchComments(String productId) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('comments')
        .select('id, content, rating, created_at, user_id')
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    final List data = response;

    List<CommentModel> comments = [];

    for (var e in data) {
      String userId = e['user_id'];
      String username = 'Utilisateur';

      try {
        final userRes = await supabase
            .from('users')
            .select('username, avatar_url')
            .eq('id', userId)
            .single();

        username = userRes['username'] ?? 'Utilisateur';
      } catch (_) {
        username = 'Utilisateur';
      }

      comments.add(CommentModel(
        id: e['id'],
        productId: productId,
        name: username,
        rating: (e['rating'] ?? 0),
        content: e['content'] ?? '',
        createdAt:
            DateTime.tryParse(e['created_at'] ?? '') ?? DateTime.now(),
        userId: userId,
        avatarUrl: e['avatar_url'] ?? '',

      ));
    }

    return comments;
  }

  // 🔹 ADD COMMENT (inchangé)
  Future<void> addComment({
  required String productId,
  required String text,
  required int rating,
}) async {
  final user = supabase.auth.currentUser;
  if (user == null) return;

  try {
    final userData = await supabase
        .from('users')
        .select('username, avatar_url')
        .eq('id', user.id)
        .single();

    await supabase.from('comments').insert({
      'product_id': productId,
      'user_id': user.id,
      'content': text,
      'rating': rating,
      'username': userData['username'],
      'avatar': userData['avatar_url'], // ⚠️ important
    });

  } catch (e) {
    debugPrint('Erreur Supabase addComment: $e');
  }

  await supabase.rpc('update_product_rating', params: {
    'p_id': productId,
  });
}
  // 🔹 UPDATE
  Future<void> updateComment({
    required String commentId,
    required String text,
    required int rating,
    required String productId,
  }) async {
    try {
      await supabase
          .from('comments')
          .update({
            'content': text,
            'rating': rating,
          })
          .eq('id', commentId);

      await supabase.rpc('update_product_rating', params: {
        'p_id': productId,
      });
    } catch (e) {
      debugPrint("Erreur updateComment: $e");
    }
  }

  // 🔹 DELETE
  Future<void> deleteComment(String commentId, String productId) async {
    try {
      await supabase.from('comments').delete().eq('id', commentId);

      await supabase.rpc('update_product_rating', params: {
        'p_id': productId,
      });
    } catch (e) {
      debugPrint("Erreur deleteComment: $e");
    }
  }

  // 🔹 GET USERNAME
  Future<String> getUsername(String userId) async {
    final res = await supabase
        .from('users')
        .select('username')
        .eq('id', userId)
        .single();

    return res['username'] ?? 'Utilisateur';
  }

  // 🔹 STREAM (CORRIGÉ ⚠️)
  Stream<List<CommentModel>> commentStream(String productId) {
    return supabase
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('product_id', productId)
        .order('created_at')
        .map((data) {
          return data.map((e) {
            return CommentModel(
              id: e['id'],
              productId: e['product_id'],
              name: e['username'] ?? 'Utilisateur', // ⚠️ IMPORTANT
              avatarUrl: e['avatar'] ?? '',
              rating: e['rating'] ?? 0,
              content: e['content'] ?? '',
              createdAt: DateTime.tryParse(e['created_at'] ?? '') ??
                  DateTime.now(),
              userId: e['user_id'],
            );
          }).toList();
        });
  }

  Future<int> getCommentsCount(String productId) async {
  final response = await supabase
      .from('comments')
      .select('id')
      .eq('product_id', productId);

  return response.length;
}
}