// widgets/influencer/dashboard/influencer_posts_section.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InfluencerPostsSection extends StatefulWidget {
  final String influencerId;

  const InfluencerPostsSection({super.key, required this.influencerId});

  @override
  State<InfluencerPostsSection> createState() => _InfluencerPostsSectionState();
}

class _InfluencerPostsSectionState extends State<InfluencerPostsSection> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final res = await supabase
        .from('posts')
        .select('''
          *,
          post_images(image_url),
          products(id, title, price, image)
        ''')
        .eq('influencer_id', widget.influencerId)
        .order('created_at', ascending: false);

    setState(() {
      posts = List<Map<String, dynamic>>.from(res);
      isLoading = false;
    });
  }

  Future<void> deletePost(String postId) async {
    try {
      // 1. احذف الصور أولاً
      await supabase.from('post_images').delete().eq('post_id', postId);

      // 2. احذف الـ post
      await supabase.from('posts').delete().eq('id', postId);

      // 3. حدّث الواجهة
      setState(() {
        posts.removeWhere((p) => p['id'] == postId);
      });
    } catch (e) {
      print('❌ Erreur suppression: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (posts.isEmpty) {
      return const Center(
        child: Text(
          'Aucun post pour le moment',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final product = post['products'];
        final images = post['post_images'] as List? ?? [];
        final imageUrl =
            images.isNotEmpty
                ? images[0]['image_url']
                : product?['image'] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // IMAGE (كما هو)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
                child: Image.network(
                  imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              // INFO
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product?['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post['description'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${product?['price']} DA',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 169, 191),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔥 زر الحذف
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Supprimer le post ?'),
                          content: const Text('Cette action est irréversible.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Supprimer',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );

                  if (confirm == true) {
                    await deletePost(post['id']);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
