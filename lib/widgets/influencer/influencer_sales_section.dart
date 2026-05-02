import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InfluencerSalesSection extends StatefulWidget {
  final String influencerId;

  const InfluencerSalesSection({super.key, required this.influencerId});

  @override
  State<InfluencerSalesSection> createState() => _InfluencerSalesSectionState();
}

class _InfluencerSalesSectionState extends State<InfluencerSalesSection> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  int followersCount = 0;
  double commissionRate = 0;
  double totalSales = 0;
  double totalCommission = 0;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  double getCommissionRate(int followers) {
    if (followers >= 800000) return 0.15;
    if (followers >= 400000) return 0.10;
    if (followers >= 100000) return 0.05;
    return 0;
  }

  Future<void> fetchData() async {
    // 1. جلب بيانات المؤثر (discount_code + followers_count)
    final influencer =
        await supabase
            .from('influencers')
            .select('discount_code, followers_count')
            .eq('id', widget.influencerId)
            .single();

    final code = influencer['discount_code'];
    final followers = (influencer['followers_count'] ?? 0) as int;
    final rate = getCommissionRate(followers);

    // 2. جلب الطلبات التي استخدمت كوده
    List<Map<String, dynamic>> ordersList = [];
    double sales = 0;

    if (code != null && code.toString().isNotEmpty) {
      final res = await supabase
          .from('orders')
          .select('id, total, created_at, status')
          .eq('influencer_code', code)
          .order('created_at', ascending: false);

      ordersList = List<Map<String, dynamic>>.from(res);
      sales = ordersList.fold(0, (sum, o) => sum + (o['total'] ?? 0));
    }

    setState(() {
      followersCount = followers;
      commissionRate = rate;
      totalSales = sales;
      totalCommission = sales * rate;
      orders = ordersList;
      isLoading = false;
    });
  }

  String formatFollowers(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(0)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 STATS CARDS
          Row(
            children: [
              _statCard(
                'Abonnés',
                formatFollowers(followersCount),
                Icons.people_outline,
                const Color.fromARGB(255, 0, 2, 105),
              ),
              const SizedBox(width: 12),
              _statCard(
                'Commission',
                '${(commissionRate * 100).toInt()}%',
                Icons.percent,
                const Color.fromARGB(255, 0, 169, 191),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _statCard(
                'Ventes totales',
                '${totalSales.toStringAsFixed(0)} DA',
                Icons.shopping_bag_outlined,
                Colors.orange,
              ),
              const SizedBox(width: 12),
              _statCard(
                'Gains estimés',
                '${totalCommission.toStringAsFixed(0)} DA',
                Icons.monetization_on_outlined,
                Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 🔥 COMMISSION TIERS
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Niveaux de commission',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 12),
                _tierRow(
                  '100K – 300K abonnés',
                  '5%',
                  followersCount >= 100000 && followersCount < 400000,
                ),
                _tierRow(
                  '400K – 800K abonnés',
                  '10%',
                  followersCount >= 400000 && followersCount < 800000,
                ),
                _tierRow('+800K abonnés', '15%', followersCount >= 800000),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 ORDERS LIST
          const Text(
            'Commandes via mon code',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),

          const SizedBox(height: 10),

          if (orders.isEmpty)
            Center(
              child: Text(
                'Aucune commande pour le moment',
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final total = (order['total'] ?? 0).toDouble();
                final commission = total * commissionRate;
                final date = DateTime.tryParse(order['created_at'] ?? '');

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Commande #${order['id'].toString().substring(0, 8)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (date != null)
                              Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            Text(
                              order['status'] ?? '',
                              style: TextStyle(
                                color:
                                    order['status'] == 'pending'
                                        ? Colors.orange
                                        : Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${total.toStringAsFixed(0)} DA',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '+${commission.toStringAsFixed(0)} DA',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tierRow(String label, String percent, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isActive ? Colors.green : Colors.grey[300],
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            percent,
            style: TextStyle(
              color: isActive ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
