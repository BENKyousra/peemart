import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/feedback/feedback_list.dart';
import '../widgets/feedback/create_feedback_fab.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final ScrollController _scrollController = ScrollController();
  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {
        scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔥 NAVBAR CONNECTÉ AU SCROLL
          NavBar(scrollOffset: scrollOffset),

          // 📦 LISTE
          Expanded(
            child: FeedbackList(
              scrollController: _scrollController, // 🔥 IMPORTANT
            ),
          ),
        ],
      ),

      floatingActionButton: const CreateFeedbackFab(),
    );
  }
}