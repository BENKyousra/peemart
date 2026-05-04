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

  int likesCount = 0;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    loadLikes();
  }

  // =========================
  // ❤️ LOAD LIKES
  // =========================
  Future<void> loadLikes() async {
    final user = supabase.auth.currentUser;

    final likes = await supabase
        .from('feedback_likes')
        .select()
        .eq('feedback_id', widget.feedback['id']);

    final liked = await supabase
        .from('feedback_likes')
        .select()
        .eq('feedback_id', widget.feedback['id'])
        .eq('user_id', user!.id);

    setState(() {
      likesCount = likes.length;
      isLiked = liked.isNotEmpty;
    });
  }

  // =========================
  // ❤️ TOGGLE LIKE (INSTANT)
  // =========================
  Future<void> toggleLike() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // 🔥 instant UI update
    setState(() {
      if (isLiked) {
        isLiked = false;
        likesCount--;
      } else {
        isLiked = true;
        likesCount++;
      }
    });

    try {
      if (isLiked) {
        await supabase.from('feedback_likes').insert({
          'feedback_id': widget.feedback['id'],
          'user_id': user.id,
        });
      } else {
        await supabase
            .from('feedback_likes')
            .delete()
            .eq('feedback_id', widget.feedback['id'])
            .eq('user_id', user.id);
      }
    } catch (e) {
      print("LIKE ERROR: $e");
    }
  }

  // =========================
  // 🗑 DELETE
  // =========================
  Future<void> deleteFeedback(String id) async {
    await supabase.from('feedback_images').delete().eq('feedback_id', id);
    await supabase.from('feedback_likes').delete().eq('feedback_id', id);
    await supabase.from('feedbacks').delete().eq('id', id);

    widget.onRefresh();
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer ?"),
        content: const Text("Action irréversible"),
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
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // =========================
  // 🔍 ZOOM IMAGE
  // =========================
  void openImageZoom(BuildContext context, List images, int index) {
    final controller = PageController(initialPage: index);

    showDialog(
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: PageView.builder(
            controller: controller,
            itemCount: images.length,
            itemBuilder: (_, i) {
              final img = images[i]['image_url'];

              return InteractiveViewer(
                child: Center(
                  child: Image.network(img, fit: BoxFit.contain),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String formatDate(String dateString) {
  final date = DateTime.parse(dateString);
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 1) {
    return "à l'instant";
  }

  if (diff.inMinutes < 60) {
    return "il y a ${diff.inMinutes} min";
  }

  if (diff.inHours < 24) {
    return "il y a ${diff.inHours} h";
  }

  if (diff.inDays == 1) {
    return "hier";
  }

  if (diff.inDays < 7) {
    return "il y a ${diff.inDays} jours";
  }

  // Format propre pour les dates anciennes
  return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
}

  @override
  Widget build(BuildContext context) {
    final f = widget.feedback;
    final user = f['users'];
    final images = f['feedback_images'] ?? [];
    final userId = supabase.auth.currentUser?.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      formatDate(f['created_at']),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const Spacer(),

                if (f['user_id'] == userId)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => EditTextSheet(
                              feedbackId: f['id'],
                              initialText: f['content'],
                              onUpdated: widget.onRefresh,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo, color: Colors.blue),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => EditImagesSheet(
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

            // ================= TEXT =================
            Text(f['content'] ?? ''),

            const SizedBox(height: 10),

            // ================= GALLERY =================
            if (images.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (_, i) {
                    final img = images[i]['image_url'];

                    return GestureDetector(
                      onTap: () => openImageZoom(context, images, i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 200,
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

            const SizedBox(height: 10),

            // ================= ❤️ LIKE =================
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Color.fromARGB(255, 255, 10, 88) : Colors.grey,
                  ),
                  onPressed: toggleLike,
                ),
                Text("$likesCount likes"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}