import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class SpinWheel extends StatefulWidget {
  final List<String> options;

  const SpinWheel({super.key, required this.options});

  @override
  State<SpinWheel> createState() => _SpinWheelState();
}

class _SpinWheelState extends State<SpinWheel> {
  final StreamController<int> controller = StreamController<int>();

  String? result;
  bool spinning = false;
  bool alreadyPlayed = false;

  void spin() {
    if (widget.options.length < 2 || alreadyPlayed) return;

    setState(() {
      spinning = true;
      result = null;
    });

    final index = Random().nextInt(widget.options.length);
    controller.add(index);

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        result = widget.options[index];
        spinning = false;
        alreadyPlayed = true;
      });
    });
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradients = [
      [const Color.fromARGB(255, 248, 154, 61), const Color.fromARGB(255, 209, 98, 0)],
      [const Color.fromARGB(255, 59, 163, 255), const Color.fromARGB(255, 89, 8, 240)],
      [const Color.fromARGB(255, 84, 221, 178), const Color.fromARGB(255, 22, 149, 136)],
      [const Color.fromARGB(255, 233, 30, 99), const Color.fromARGB(255, 201, 0, 67)],
      [const Color.fromARGB(255, 103, 58, 183), const Color.fromARGB(255, 54, 0, 148)],
      [const Color.fromARGB(255, 255, 193, 7), const Color.fromARGB(255, 216, 162, 0)],
    ];

    return Column(
      children: [
        const SizedBox(height: 70),

        // 🎡 BACKGROUND
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color.fromARGB(0, 0, 0, 0), const Color.fromARGB(0, 33, 33, 33)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),

          child: SizedBox(
            height: 300,
            width: 300,
            child: FortuneWheel(
              selected: controller.stream,

              // 🔻 INDICATOR
              indicators: const [
                FortuneIndicator(
                  alignment: Alignment.topCenter,
                  child: TriangleIndicator(
                    color: Colors.amber,
                  ),
                ),
              ],

              items: [
                for (int i = 0; i < widget.options.length; i++)
                  FortuneItem(
                    style: FortuneItemStyle(
                      color: gradients[i % gradients.length][0],
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),

                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradients[i % gradients.length],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),

                      child: Text(
                        widget.options[i],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 🎲 BUTTON
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: (spinning || alreadyPlayed) ? null : spin,
          child: Text(
            alreadyPlayed
                ? "✅ Déjà joué"
                : spinning
                    ? "🎲 Tirage..."
                    : "Lancer",
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 🏆 RESULT
        if (result != null)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.green, Colors.teal],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              "🎉 Gagnant : $result",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}