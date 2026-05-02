import 'package:flutter/material.dart';

class QuizView extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final Function(List<Map<String, dynamic>>) onSubmit;

  const QuizView({super.key, required this.questions, required this.onSubmit});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  List<Map<String, dynamic>> answers = [];

  void setAnswer(String question, String value) {
    answers.removeWhere((e) => e["q"] == question);

    answers.add({"q": question, "a": value});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...widget.questions.map((q) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q['question'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    onChanged: (v) {
                      setAnswer(q['question'], v);
                    },
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 5),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              widget.onSubmit(answers);
              
            },
            child: const Text(
              "Valider",
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
