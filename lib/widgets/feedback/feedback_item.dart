import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_text_sheet.dart';
import 'edit_images_sheet.dart';
import '../../pages/shop_page.dart';

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

  // ❤️ LOAD LIKES
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

  // ❤️ TOGGLE LIKE
  Future<void> toggleLike() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

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
      debugPrint("LIKE ERROR: $e");
    }
  }

  // 🗑 DELETE
  Future<void> deleteFeedback(String id) async {
    await supabase.from('feedback_tags').delete().eq('feedback_id', id);
    await supabase.from('feedback_images').delete().eq('feedback_id', id);
    await supabase.from('feedback_likes').delete().eq('feedback_id', id);
    await supabase.from('feedbacks').delete().eq('id', id);
    widget.onRefresh();
  }

  // =========================
  // 🔥 BUILD MENTIONS
  // mentions = List<dynamic> depuis le jsonb: [{id, name, type}]
  // On trie par longueur de nom DESC pour éviter les faux-matches partiels
  // =========================
  List<InlineSpan> buildMentions(String text, List mentions) {
    if (text.isEmpty) {
      return [const TextSpan(text: '')];
    }

    if (mentions.isEmpty) {
      return [TextSpan(text: text, style: const TextStyle(color: Colors.black))];
    }

    // Cast propre + tri par longueur desc
    final sorted = List<Map>.from(mentions)
      ..sort((a, b) =>
          (b['name'] as String).length.compareTo((a['name'] as String).length));

    // Regex dynamique qui matche exactement les noms des shops taggés
    final pattern = sorted
        .map((m) => '@${RegExp.escape(m['name'] as String)}')
        .join('|');

    final regex = RegExp(pattern);
    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return [TextSpan(text: text, style: const TextStyle(color: Colors.black))];
    }

    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      // Texte avant la mention
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: const TextStyle(color: Colors.black),
        ));
      }

      final matchedText = match.group(0)!; // ex: "@Mon Shop"
      final nameOnly = matchedText.substring(1); // "Mon Shop"

      final mention = sorted.firstWhere(
        (m) => m['name'] == nameOnly,
        orElse: () => <String, dynamic>{},
      );

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: () {
              if (mention.isNotEmpty && mention['type'] == 'shop') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShopPage(shopId: mention['id'] as String),
                  ),
                );
              }
            },
            child: Text(
              matchedText,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Texte restant après la dernière mention
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(color: Colors.black),
      ));
    }

    return spans;
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
            child: const Text("Supprimer",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 🔍 ZOOM IMAGE
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
            itemBuilder: (_, i) => InteractiveViewer(
              child: Center(
                child: Image.network(
                  images[i]['image_url'],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "à l'instant";
    if (diff.inMinutes < 60) return "il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "il y a ${diff.inHours} h";
    if (diff.inDays == 1) return "hier";
    if (diff.inDays < 7) return "il y a ${diff.inDays} jours";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.feedback;
    final user = f['users'];
    final images = (f['feedback_images'] as List?) ?? [];
    // 🔥 mentions vient du jsonb, peut être null ou List
    final mentions = (f['mentions'] as List?) ?? [];
    final userId = supabase.auth.currentUser?.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    user['avatar_url'] ??
                        'https://cdn.pixabay.com/photo/2023/02/18/11/00/icon-7797704_1280.png',
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['username'] ?? 'User',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
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
                        icon: const Icon(Icons.delete,
                            color: Color.fromARGB(255, 255, 10, 88)),
                        onPressed: () => confirmDelete(f['id']),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // TEXT + MENTIONS CLIQUABLES
            RichText(
              text: TextSpan(
                children: buildMentions(f['content'] ?? '', mentions),
              ),
            ),

            const SizedBox(height: 10),

            // GALLERY
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

            // LIKE
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked
                        ? const Color.fromARGB(255, 255, 10, 88)
                        : Colors.grey,
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