import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/concours_service.dart';
import '../../widgets/concours/spin_wheel.dart';
import '../../widgets/concours/quiz_view.dart';

class ParticipatePage extends StatefulWidget {
  final String concoursId;
  final String type;

  const ParticipatePage({
    super.key,
    required this.concoursId,
    required this.type,
  });

  @override
  State<ParticipatePage> createState() => _ParticipatePageState();
}

class _ParticipatePageState extends State<ParticipatePage> {
  final service = ConcoursService();

  List<String> raffleOptions = [];
  List<Map<String, dynamic>> questions = [];
  List<Map<String, dynamic>> answers = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (widget.type == "raffle") {
      raffleOptions = await service.getRaffleOptions(widget.concoursId);
    } else {
      questions = await service.getQuestions(widget.concoursId);
    }

    setState(() {
      loading = false;

      print("TYPE => ${widget.type}");
print("QUESTIONS => ${questions.length}");
    });
  }

  Future<void> submit() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    await service.participate(
      concoursId: widget.concoursId,
      userId: user.id,
      answers: answers,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("✅ Participation envoyée")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 226, 169, 0), Colors.amber],
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Concours',
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),

      body: Stack(
        children: [
          // 🖼️ BACKGROUND
          Positioned.fill(
            child: Image.asset("assets/images/bg.jpg", fit: BoxFit.cover),
          ),

          // 🔥 OVERLAY
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          // =========================
          // 🎡 RAFFLE
          // =========================
          if (widget.type == "raffle")
            Center(
              child:
                  raffleOptions.isEmpty
                      ? const Text(
                        "❌ Aucune option",
                        style: TextStyle(color: Colors.white),
                      )
                      : raffleOptions.length < 2
                      ? Text(
                        "🎁 Ajoute au moins 2 cadeaux (${raffleOptions.length}/2)",
                        style: const TextStyle(color: Colors.white),
                      )
                      : SpinWheel(options: raffleOptions),
            ),

          // =========================
          // 🧠 QUIZ
          // =========================
          if (widget.type == "quiz")
          Center(
            child: QuizView(
              questions: questions,
              onSubmit: (a) async {
                final user = Supabase.instance.client.auth.currentUser;
                if (user == null) return;

                await service.participate(
                  concoursId: widget.concoursId,
                  userId: user.id,
                  answers: a,
                );

                if (!mounted) return;

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("✅ Participation envoyée")));
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
