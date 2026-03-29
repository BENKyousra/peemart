import 'package:flutter/material.dart';

class SeeMoreCard extends StatelessWidget {
  final int remaining;
  final VoidCallback onTap;

  const SeeMoreCard({
    super.key,
    required this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(         
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 0, 1, 59),
                Color.fromARGB(255, 0, 2, 105),
              ],
            ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_forward_ios,
                size: 32,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              const SizedBox(height: 8),
              Text(
                '+$remaining produits',
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
