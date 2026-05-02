import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/concours_model.dart';

class ConcoursService {
  final SupabaseClient client = Supabase.instance.client;

  // =====================================================
  // 📥 GET ALL CONCOURS
  // =====================================================
  Future<List<ConcoursModel>> getConcours() async {
    try {
      final res = await client
          .from('concours')
          .select()
          .order('date', ascending: false);

      return (res as List)
          .map((e) => ConcoursModel.fromJson(e))
          .toList();
    } catch (e) {
      print("❌ getConcours error: $e");
      return [];
    }
  }

  // =====================================================
  // ❓ GET QUIZ QUESTIONS
  // =====================================================
  Future<List<Map<String, dynamic>>> getQuestions(String concoursId) async {
    try {
      final res = await client
          .from('concours_questions')
          .select()
          .eq('concours_id', concoursId)
          .order('order_index');

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ getQuestions error: $e");
      return [];
    }
  }

  // =====================================================
  // 🎯 CREATE CONCOURS
  // =====================================================
  Future<String?> createConcours(Map<String, dynamic> data) async {
    try {
      final res = await client
          .from('concours')
          .insert(data)
          .select()
          .single();

      return res['id'];
    } catch (e) {
      print("❌ createConcours error: $e");
      return null;
    }
  }

  // =====================================================
  // ➕ ADD QUIZ QUESTION
  // =====================================================
  Future<void> addQuestion({
    required String concoursId,
    required String question,
    required String correctAnswer,
    required int orderIndex,
  }) async {
    try {
      await client.from('concours_questions').insert({
        'concours_id': concoursId,
        'question': question,
        'correct_answer': correctAnswer,
        'order_index': orderIndex,
      });
    } catch (e) {
      print("❌ addQuestion error: $e");
    }
  }

  // =====================================================
  // 🎁 ADD RAFFLE OPTIONS (6 gifts max UI)
  // =====================================================
  Future<void> addRaffleOptions({
    required String concoursId,
    required List<String> options,
  }) async {
    try {
      if (options.length < 2) {
        print("❌ RAFFLE ERROR: min 2 options required");
        return;
      }

      final data = options.map((e) => {
        'concours_id': concoursId,
        'label': e,
      }).toList();

      await client.from('raffle_options').insert(data);

      print("✅ raffle options inserted: ${data.length}");
    } catch (e) {
      print("❌ addRaffleOptions error: $e");
    }
  }

  // =====================================================
  // 📥 GET RAFFLE OPTIONS
  // =====================================================
  Future<List<String>> getRaffleOptions(String concoursId) async {
    try {
      final res = await client
          .from('raffle_options')
          .select('label')
          .eq('concours_id', concoursId);

      return (res as List)
          .map((e) => e['label'].toString())
          .toList();
    } catch (e) {
      print("❌ getRaffleOptions error: $e");
      return [];
    }
  }

  // =====================================================
  // 👤 PARTICIPATE (QUIZ + RAFFLE)
  // =====================================================
  Future<void> participate({
  required String concoursId,
  required String userId,
  required List answers,
}) async {
  try {
    final res = await client
        .from('participations')
        .insert({
          'concours_id': concoursId,
          'user_id': userId,
          'answers': answers,
        })
        .select();

    print("🔥 PARTICIPATION INSERTED => $res");

  } catch (e) {
    print("❌ participate error: $e");
  }
}
  // =====================================================
  // 🔒 CLOSE CONCOURS
  // =====================================================
  Future<void> closeConcours(String id) async {
    try {
      await client
          .from('concours')
          .update({'is_closed': true})
          .eq('id', id);
    } catch (e) {
      print("❌ closeConcours error: $e");
    }
  }

  // =====================================================
  // ⚙️ CHECK IF CAN PARTICIPATE
  // =====================================================
  bool canParticipate(Map concours) {
    if (concours['is_closed'] == true) return false;

    final max = concours['max_participants'];
    final current = concours['current_participants'];

    if (max != null && current != null && current >= max) {
      return false;
    }

    return true;
  }

  Future<void> debugRaffle(String id) async {
  final res = await client.from('raffle_options').select().eq('concours_id', id);

  print("🔥 RAFFLE RAW DATA => $res");
}
}