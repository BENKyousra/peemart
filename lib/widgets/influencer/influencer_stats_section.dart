// widgets/influencer/dashboard/influencer_stats_section.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InfluencerStatsSection extends StatefulWidget {
  final String influencerId;

  const InfluencerStatsSection({super.key, required this.influencerId});

  @override
  State<InfluencerStatsSection> createState() => _InfluencerStatsSectionState();
}

class _InfluencerStatsSectionState extends State<InfluencerStatsSection> {
  final supabase = Supabase.instance.client;

  int totalPosts = 0;
  int totalLikes = 0;
  int totalComments = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    // جلب posts
    final posts = await supabase
        .from('posts')
        .select('id, products(id)')
        .eq('influencer_id', widget.influencerId);

    final postList = List<Map<String, dynamic>>.from(posts);
    final productIds = postList
        .map((p) => p['products']?['id'])
        .where((id) => id != null)
        .toList();

    int likes = 0;
    int comments = 0;

    if (productIds.isNotEmpty) {
      // likes
      final likesRes = await supabase
          .from('likes')
          .select('id')
          .in_('product_id', productIds);
      likes = (likesRes as List).length;

      // comments
      final commentsRes = await supabase
          .from('comments')
          .select('id')
          .in_('product_id', productIds);
      comments = (commentsRes as List).length;
    }

    setState(() {
      totalPosts = postList.length;
      totalLikes = likes;
      totalComments = comments;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              _statCard('Posts', totalPosts.toString(), Icons.grid_on, const Color.fromARGB(255, 0, 2, 105)),
              const SizedBox(width: 12),
              _statCard('Likes', totalLikes.toString(), Icons.favorite, const Color.fromARGB(255, 255, 10, 88)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard('Commentaires', totalComments.toString(), Icons.chat_bubble_outline, const Color.fromARGB(255, 0, 169, 191)),
              const SizedBox(width: 12),
              // قابل للتطوير
              _statCard('Partages', '—', Icons.share_outlined, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      ),
    );
  }
}