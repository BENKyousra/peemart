import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final supabase = Supabase.instance.client;

  // 🔔 STREAM NOTIFICATIONS USER
  Stream<List<Map<String, dynamic>>> streamUserNotifications(String userId) {
    return supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at')
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // 🔢 COUNT UNREAD
  Stream<int> unreadCount(String userId) {
    return streamUserNotifications(userId).map(
      (list) => list.where((n) => n['is_read'] == false).length,
    );
  }

  // ✅ MARK ALL AS READ
  Future<void> markAllAsRead(String userId) async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId);
  }

  // 📩 CREATE NOTIFICATION
  Future<void> create({
    required String userId,
    required String title,
    String? body,
  }) async {
    await supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
    });
  }
}