import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';

class CommentService {
  final supabase = Supabase.instance.client;

  // 🔹 Récupérer tous les commentaires d'un produit
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
          .select('username')
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
      createdAt: DateTime.tryParse(e['created_at'] ?? '') ?? DateTime.now(),
      userId: userId,
    ));
  }

  return comments;
}

  // 🔹 Ajouter un commentaire
  Future<void> addComment({
    required String productId,
    required String text,
    required int rating,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
  await supabase.from('comments').insert({
    'product_id': productId,
    'user_id': user.id,
    'content': text,
    'rating': rating,
  });
} catch (e) {
  debugPrint('Erreur Supabase addComment: $e');
}

await supabase.rpc('update_product_rating', params: {
  'p_id': productId,
});
  }

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

    await supabase.rpc(
      'update_product_rating',
      params: {'p_id': productId},
    );
  } catch (e) {
    debugPrint("Erreur updateComment: $e");
  }
}

Future<void> deleteComment(String commentId, String productId) async {
  try {
    await supabase
        .from('comments')
        .delete()
        .eq('id', commentId);

    await supabase.rpc('update_product_rating', params: {
  'p_id': productId,
});
  } catch (e) {
    debugPrint("Erreur deleteComment: $e");
  }
}

  Future<String> getUsername(String userId) async {
  final res = await supabase
      .from('users')
      .select('username')
      .eq('id', userId)
      .single();

  return res['username'] ?? 'Utilisateur';
}

  // 🔹 Subscribe to comments (Realtime)
  Stream<List<CommentModel>> commentStream(String productId) {
    return supabase
        .from('comments:product_id=eq.$productId')
        .stream(primaryKey: ['id'])
        .map((List<dynamic> payload) {
          return payload.map((e) => CommentModel.fromMap(e)).toList();
        });
  }
}