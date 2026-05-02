import 'package:flutter/material.dart';
import '../../services/concours_service.dart';

class CreateConcoursPage extends StatefulWidget {
  const CreateConcoursPage({super.key});

  @override
  State<CreateConcoursPage> createState() => _CreateConcoursPageState();
}

class _CreateConcoursPageState extends State<CreateConcoursPage> {
  final service = ConcoursService();

  String type = "quiz";

  final reward = TextEditingController();
  final desc = TextEditingController();
  final endDate = TextEditingController();
  final maxParticipants = TextEditingController();

  String? imageUrl;

  bool loading = false;

  // =========================
  // QUIZ
  // =========================
  List<Map<String, TextEditingController>> questions = [];

  void addQuestion() {
    questions.add({
      "q": TextEditingController(),
      "a": TextEditingController(),
    });
    setState(() {});
  }

  // =========================
  // RAFFLE (6 gifts max)
  // =========================
  List<TextEditingController> raffleOptions = [];

  void addOption() {
    if (raffleOptions.length >= 6) return; // 🔥 max 6
    raffleOptions.add(TextEditingController());
    setState(() {});
  }

  // =========================
  // IMAGE (mock)
  // =========================
  void pickImage() {
    setState(() {
      imageUrl =
          "https://images.pexels.com/photos/11970084/pexels-photo-11970084.jpeg";
    });
  }

  // =========================
  // CREATE
  // =========================
  Future<void> create() async {
    setState(() => loading = true);

    try {
      DateTime parsedDate;

      try {
        parsedDate = DateTime.parse(endDate.text);
      } catch (_) {
        parsedDate = DateTime.now().add(const Duration(days: 7));
      }

      // =========================
      // CREATE MAIN CONCOURS
      // =========================
      final id = await service.createConcours({
        'shop_name': 'My Shop',
        'type': type,
        'reward': reward.text,
        'description': desc.text,
        'image_url': imageUrl,
        'date': parsedDate.toIso8601String(),
        'max_participants': maxParticipants.text.isEmpty
            ? null
            : int.parse(maxParticipants.text),
      });

      // =========================
      // QUIZ SAVE
      // =========================
      if (id != null && type == "quiz") {
        for (int i = 0; i < questions.length; i++) {
          await service.addQuestion(
            concoursId: id,
            question: questions[i]['q']!.text,
            correctAnswer: questions[i]['a']!.text,
            orderIndex: i,
          );
        }
      }

      // =========================
      // RAFFLE SAVE (6 gifts)
      // =========================
      if (id != null && type == "raffle") {
        final options = raffleOptions
            .map((e) => e.text)
            .where((e) => e.isNotEmpty)
            .toList();

        await service.addRaffleOptions(
          concoursId: id,
          options: options,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);

    } catch (e) {
      print("❌ create error: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer concours")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  // =========================
                  // TYPE
                  // =========================
                  DropdownButton(
                    value: type,
                    items: const [
                      DropdownMenuItem(value: "quiz", child: Text("🧠 Quiz")),
                      DropdownMenuItem(value: "raffle", child: Text("🎁 Raffle")),
                    ],
                    onChanged: (v) => setState(() => type = v!),
                  ),

                  const SizedBox(height: 10),

                  // =========================
                  // IMAGE
                  // =========================
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: imageUrl == null
                          ? const Center(child: Text("📷 Ajouter image"))
                          : Image.network(imageUrl!, fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // =========================
                  // INPUTS
                  // =========================
                  TextField(
                    controller: reward,
                    decoration: const InputDecoration(labelText: "🎁 Reward"),
                  ),

                  TextField(
                    controller: desc,
                    decoration: const InputDecoration(labelText: "📝 Description"),
                  ),

                  TextField(
                    controller: endDate,
                    decoration: const InputDecoration(labelText: "📅 Date"),
                  ),

                  TextField(
                    controller: maxParticipants,
                    decoration: const InputDecoration(labelText: "👥 Max participants"),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // QUIZ MODE
                  // =========================
                  if (type == "quiz") ...[
                    ElevatedButton(
                      onPressed: addQuestion,
                      child: const Text("➕ Ajouter question"),
                    ),

                    const SizedBox(height: 10),

                    ...questions.map((q) {
                      return Column(
                        children: [
                          TextField(
                            controller: q["q"],
                            decoration: const InputDecoration(labelText: "❓ Question"),
                          ),
                          TextField(
                            controller: q["a"],
                            decoration: const InputDecoration(labelText: "✅ Réponse"),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }),
                  ],

                  // =========================
                  // RAFFLE MODE
                  // =========================
                  if (type == "raffle") ...[
                    ElevatedButton(
                      onPressed: addOption,
                      child: const Text("➕ Ajouter cadeau (max 6)"),
                    ),

                    const SizedBox(height: 10),

                    ...raffleOptions.map((o) {
                      return TextField(
                        controller: o,
                        decoration: const InputDecoration(
                          labelText: "🎁 Cadeau possible",
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 20),

                  // =========================
                  // CREATE BUTTON
                  // =========================
                  ElevatedButton(
                    onPressed: create,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Text("🚀 Créer concours"),
                  ),
                ],
              ),
            ),
    );
  }
}