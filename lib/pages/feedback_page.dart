import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/feedback/feedback_list.dart';
import '../widgets/feedback/create_feedback_fab.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          NavBar(),
          Expanded(child: FeedbackList()),
        ],
      ),

      floatingActionButton: const CreateFeedbackFab(),
    );
  }
}