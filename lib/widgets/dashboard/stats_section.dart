import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsSection extends StatefulWidget {
  const StatsSection({super.key});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;

  String? shopId;

  int productsCount = 0;
  int ordersCount = 0;
  int promosCount = 0;

  double totalRevenue = 0;

  List<Map<String, dynamic>> revenueByDay = [];
  List<Map<String, dynamic>> bestProducts = [];

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    setState(() => isLoading = true);

    try {
      final userId = supabase.auth.currentUser!.id;

      // 🏪 SHOP
      final shop =
          await supabase
              .from('shops')
              .select('id')
              .eq('owner_id', userId)
              .single();

      shopId = shop['id'];

      // 📦 PRODUCTS
      final products = await supabase
          .from('products')
          .select('id')
          .eq('shop_id', shopId!);

      productsCount = products.length;

      // 🎟 PROMOS
      final promos = await supabase
          .from('promotions')
          .select('*, products!inner(shop_id)')
          .eq('products.shop_id', shopId!);

      promosCount = promos.length;

      // 🛒 ORDER ITEMS (IMPORTANT FIX)
      final orderItems = await supabase
          .from('order_items')
          .select('''
            price,
            quantity,
            product_id,
            created_at,
            products!inner(id, title, shop_id)
          ''')
          .eq('products.shop_id', shopId!);

      ordersCount = orderItems.length;

      double revenue = 0;
      Map<String, double> daily = {};
      Map<String, Map<String, dynamic>> ranking = {};

      for (var item in orderItems) {
        final price = ((item['price'] ?? 0) as num).toDouble();
        final qty = ((item['quantity'] ?? 0) as num).toInt();

        final total = price * qty;
        revenue += total;

        // 📈 DATE (safe)
        final createdAt = item['created_at'];
        final date =
            createdAt != null
                ? DateTime.parse(createdAt).toIso8601String().split("T").first
                : DateTime.now().toIso8601String().split("T").first;

        daily[date] = (daily[date] ?? 0) + total;

        // 🏆 PRODUCT
        final product = item['products'];
        final productId = product['id'].toString();
        final title = product['title'] ?? "Unknown";

        ranking.putIfAbsent(
          productId,
          () => {"title": title, "sold": 0, "revenue": 0.0},
        );

        ranking[productId]!["sold"] += qty;
        ranking[productId]!["revenue"] += total;
      }

      totalRevenue = revenue;

      // 📊 SORT DAILY
      final sorted =
          daily.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

      revenueByDay =
          sorted.map((e) => {"date": e.key, "value": e.value}).toList();

      // 🏆 BEST PRODUCTS
      bestProducts =
          ranking.values.toList()
            ..sort((a, b) => b["sold"].compareTo(a["sold"]));

      setState(() => isLoading = false);
    } catch (e) {
      print("STATS ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  Widget statCard(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Color.fromARGB(255, 0, 169, 191)),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget revenueChart() {
    if (revenueByDay.isEmpty) {
      return const Text("Pas de données");
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 1, 59),
            Color.fromARGB(255, 0, 2, 105),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.white.withOpacity(0.05),
                  strokeWidth: 1,
                );
              },
            ),

            titlesData: FlTitlesData(
              show: true,

              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    int i = value.toInt();
                    if (i < 0 || i >= revenueByDay.length) {
                      return const SizedBox();
                    }

                    final date = revenueByDay[i]['date'].toString();

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        date.substring(5),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    );
                  },
                ),
              ),

              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),

            borderData: FlBorderData(show: false),

            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => Colors.black87,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      "${spot.y.toStringAsFixed(0)} DA",
                      const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),

            lineBarsData: [
              LineChartBarData(
                spots: List.generate(revenueByDay.length, (i) {
                  return FlSpot(
                    i.toDouble(),
                    revenueByDay[i]['value'].toDouble(),
                  );
                }),

                isCurved: true,
                color: Color.fromARGB(255, 0, 169, 191),
                barWidth: 3,

                dotData: FlDotData(show: false),

                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 0, 169, 191).withOpacity(0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bestProductsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...bestProducts.take(5).map((p) {
          return ListTile(
            leading: const Icon(Icons.star, color: Colors.orange),
            title: Text(p['title']),
            subtitle: Text("${p['revenue']} DA"),
            trailing: Text("${p['sold']} ventes"),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: loadStats,

      // 🔥 IMPORTANT: SingleChildScrollView remplace ListView
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            statCard("Produits", "$productsCount", Icons.shopping_bag),
            statCard("Commandes", "$ordersCount", Icons.receipt),
            statCard(
              "Revenus",
              "${totalRevenue.toStringAsFixed(0)} DA",
              Icons.monetization_on,
            ),
            statCard("Promotions", "$promosCount", Icons.local_offer),

            const SizedBox(height: 30),

            Row(
              children: const [
                Icon(
                  Icons.monetization_on,
                  color: Color.fromARGB(255, 0, 2, 105),
                ),
                SizedBox(width: 8),
                Text(
                  "Revenus",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 2, 105),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            revenueChart(),

            const SizedBox(height: 30),

            Row(
              children: const [
                Icon(Icons.whatshot, color: Color.fromARGB(255, 0, 2, 105)),
                SizedBox(width: 8),
                Text(
                  "Meilleurs produits",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 2, 105),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            bestProductsWidget(),
          ],
        ),
      ),
    );
  }
}
