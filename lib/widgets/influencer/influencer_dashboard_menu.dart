// widgets/influencer/dashboard/influencer_dashboard_menu.dart

import 'package:flutter/material.dart';

class InfluencerDashboardMenu extends StatelessWidget {
  final int currentIndex;
  final Function(int) onChanged;

  const InfluencerDashboardMenu({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      {'icon': Icons.grid_on, 'label': 'Posts'},
      {'icon': Icons.bar_chart, 'label': 'Stats'},
      {'icon': Icons.monetization_on_outlined, 'label': 'Ventes'},
    ];

    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(items.length, (i) {
          final isActive = i == currentIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive
                          ? const Color.fromARGB(255, 0, 169, 191)
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      items[i]['icon'] as IconData,
                      color: isActive
                          ? const Color.fromARGB(255, 0, 169, 191)
                          : Colors.grey,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i]['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive
                            ? const Color.fromARGB(255, 0, 169, 191)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}