import 'package:flutter/material.dart';
import 'create_feedback_sheet.dart';

class CreateFeedbackFab extends StatelessWidget {
  const CreateFeedbackFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const CreateFeedbackSheet(),
        );
      },
      backgroundColor: const Color.fromARGB(255, 0, 2, 105),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}