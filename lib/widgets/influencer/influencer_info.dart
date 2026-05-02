import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InfluencerInfo extends StatefulWidget {
  final String influencerId;

  const InfluencerInfo({super.key, required this.influencerId});

  @override
  State<InfluencerInfo> createState() => _InfluencerInfoState();
}

class _InfluencerInfoState extends State<InfluencerInfo> {
  Map<String, dynamic>? influencer;

  @override
  void initState() {
    super.initState();
    fetchInfluencer();
  }

  Future<void> fetchInfluencer() async {
    final data =
        await Supabase.instance.client
            .from('influencers')
            .select()
            .eq('id', widget.influencerId)
            .single();

    setState(() => influencer = data);
  }

  String _formatFollowers(dynamic count) {
    if (count == null) return '';
    final n = (count as num).toInt();
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M 👥';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K 👥';
    return '$n 👥';
  }

  @override
  Widget build(BuildContext context) {
    if (influencer == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                influencer!['avatar'] != null
                    ? NetworkImage(influencer!['avatar'])
                    : null,
            child:
                influencer!['avatar'] == null ? const Icon(Icons.person) : null,
          ),

          const SizedBox(width: 15),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    influencer!['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (influencer!['is_verified'] == true)
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Icon(Icons.verified, color: Colors.blue, size: 16),
                    ),
                ],
              ),

              // 🔥 عدد المشتركين
              if ((influencer!['followers_count'] ?? 0) > 0)
                Text(
                  'Followers: ${_formatFollowers(influencer!['followers_count'])}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 169, 191),
                  ),
                ),

              const SizedBox(height: 5),

              Text(
                influencer!['discount_code'] ?? '',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
