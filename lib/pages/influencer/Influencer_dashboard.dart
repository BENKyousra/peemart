import 'package:flutter/material.dart';
import '../../services/influencer/post_service.dart';
import '../../widgets/influencer/influencer_dashboard_header.dart';
import '../../widgets/influencer/influencer_dashboard_menu.dart';
import '../../widgets/influencer/influencer_posts_section.dart';
import '../../widgets/influencer/influencer_stats_section.dart';
import '../../widgets/influencer/influencer_sales_section.dart';

class InfluencerDashboardPage extends StatefulWidget {
  const InfluencerDashboardPage({super.key});

  @override
  State<InfluencerDashboardPage> createState() => _InfluencerDashboardPageState();
}

class _InfluencerDashboardPageState extends State<InfluencerDashboardPage> {
  int currentIndex = 0;
  Map<String, dynamic>? influencer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInfluencer();
  }

  Future<void> loadInfluencer() async {
    final data = await PostService().getMyInfluencer();
    setState(() {
      influencer = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
              'Mon Dashboard',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),

      body: Column(
        children: [
          InfluencerDashboardHeader(influencer: influencer),
          InfluencerDashboardMenu(
            currentIndex: currentIndex,
            onChanged: (i) => setState(() => currentIndex = i),
          ),
          const Divider(height: 1),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final influencerId = influencer?['id'] ?? '';
    switch (currentIndex) {
      case 0:
        return InfluencerPostsSection(influencerId: influencerId);
      case 1:
        return InfluencerStatsSection(influencerId: influencerId);
      case 2:
        return InfluencerSalesSection(influencerId: influencerId);
      default:
        return const SizedBox();
    }
  }
}