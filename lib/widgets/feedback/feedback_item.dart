import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_text_sheet.dart';
import 'edit_images_sheet.dart';

class FeedbackItem extends StatefulWidget {
  final Map feedback;
  final VoidCallback onRefresh;

  const FeedbackItem({
    super.key,
    required this.feedback,
    required this.onRefresh,
  });

  @override
  State<FeedbackItem> createState() => _FeedbackItemState();
}

class _FeedbackItemState extends State<FeedbackItem> {
  final supabase = Supabase.instance.client;

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return "à l'instant";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min";
    if (diff.inHours < 24) return "${diff.inHours} h";
    if (diff.inDays < 7) return "${diff.inDays} j";

    return "${date.day}/${date.month}/${date.year}";
  }

  // =========================
  // 🗑 DELETE FEEDBACK
  // =========================
  Future<void> deleteFeedback(String id) async {
    try {
      await supabase.from('feedback_images').delete().eq('feedback_id', id);

      await supabase.from('feedback_likes').delete().eq('feedback_id', id);

      await supabase.from('feedbacks').delete().eq('id', id);

      widget.onRefresh();
    } catch (e) {
      print("DELETE ERROR: $e");
    }
  }

  Future<void> updateFeedback(String id, String newContent) async {
    if (newContent.trim().isEmpty) return;

    try {
      await supabase
          .from('feedbacks')
          .update({'content': newContent.trim()})
          .eq('id', id);

      widget.onRefresh(); // refresh UI
    } catch (e) {
      print("UPDATE ERROR: $e");
    }
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Supprimer le post ?"),
            content: const Text("Cette action est irréversible."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await deleteFeedback(id);
                },
                child: const Text(
                  "Supprimer",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void openImageZoom(BuildContext context, List images, int initialIndex) {
    final PageController controller = PageController(initialPage: initialIndex);

    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: PageView.builder(
              controller: controller,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final img = images[index]['image_url'];

                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Center(child: Image.network(img, fit: BoxFit.contain)),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.feedback;
    final user = f['users'];
    final images = f['feedback_images'] ?? [];
    final userId = supabase.auth.currentUser?.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // 👤 HEADER USER
            // =========================
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    user['avatar_url'] ?? 'https://via.placeholder.com/150',
                  ),
                ),
                const SizedBox(width: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['username'] ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                    ),
                    Text(
                      formatDate(f['created_at']),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),

                const Spacer(),

                // =========================
                // 🗑 DELETE BUTTON
                // =========================
                if (f['user_id'] == userId)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color.fromARGB(255, 0, 169, 191)),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder:
                                (_) => EditTextSheet(
                                  feedbackId: f['id'],
                                  initialText: f['content'],
                                  onUpdated: widget.onRefresh,
                                ),
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.photo, color: Color.fromARGB(255, 0, 169, 191)),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder:
                                (_) => EditImagesSheet(
                                  feedbackId: f['id'],
                                  images: images,
                                  onUpdated: widget.onRefresh,
                                ),
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Color.fromARGB(255, 255, 10, 88)),
                        onPressed: () => confirmDelete(f['id']),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // =========================
            // 📝 CONTENT
            // =========================
            Text(f['content'] ?? ''),

            const SizedBox(height: 10),

            // =========================
            // 🖼 GALLERY
            // =========================
            if (images.isNotEmpty)
              SizedBox(
                height: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, i) {
                    final img = images[i]['image_url'];

                    return GestureDetector(
                      onTap: () {
                        openImageZoom(context, images, i);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(img),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
