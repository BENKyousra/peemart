import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final service = NotificationService();
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser!;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 0, 1, 59),
                Color.fromARGB(255, 0, 2, 105),
              ],
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Notifications',
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.streamUserNotifications(user.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!;

          if (notifications.isEmpty) {
            return const Center(
              child: Text("Aucune notification"),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];

              final isRead = notif['is_read'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: Icon(
                    isRead
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                    color: isRead ? Colors.grey : Color.fromARGB(255, 0, 169, 191),
                  ),

                  title: Text(
                    notif['title'] ?? '',
                    style: TextStyle(
                      fontWeight:
                          isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(notif['body'] ?? ''),

                  trailing: isRead
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(Icons.fiber_new, color: Color.fromARGB(255, 255, 10, 88)),

                  onTap: () async {
                    await service.markAllAsRead(user.id);
                    setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}