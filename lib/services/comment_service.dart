import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';

class CommentService {
  final supabase = Supabase.instance.client;

  // 🔹 Récupérer tous les commentaires d'un produit
  static Future<List<CommentModel>> fetchComments(String productId) async {
    final response = await Supabase.instance.client
        .from('comments')
        .select('id, content, rating, created_at, user_id')
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    final data =
        (response as List<dynamic>)
            .map((e) => CommentModel.fromMap(e))
            .toList();

    return data;
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
      final response = await supabase.from('comments').insert({
        'product_id': productId,
        'user_id': user.id, // 🔥 lie le commentaire à l'utilisateur
        'content': text,
        'rating': rating,
      });
      if (response.error != null) {
        throw Exception('Supabase error: ${response.error!.message}');
      }
    } catch (e, st) {
      debugPrint('Supabase échec: $e\n$st');
      // afficher widget/snackbar pour utilisateur
    }
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
