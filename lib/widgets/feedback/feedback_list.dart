import 'package:flutter/material.dart';
import 'feedback_item.dart';
import '../../services/feedback_service.dart';

class FeedbackList extends StatefulWidget {
  final ScrollController scrollController;

  const FeedbackList({
    super.key,
    required this.scrollController,
  });

  @override
  State<FeedbackList> createState() => _FeedbackListState();
}

class _FeedbackListState extends State<FeedbackList> {
  final service = FeedbackService();

  List feedbacks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await service.getFeedbacks();

    setState(() {
      feedbacks = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: load,

      // 🔥 IMPORTANT : scroll contrôlé par la page parent
      child: ListView.builder(
        controller: widget.scrollController, // 🔥 IMPORTANT
        physics: const AlwaysScrollableScrollPhysics(),

        itemCount: feedbacks.length,
        itemBuilder: (context, i) {
          return FeedbackItem(
            feedback: feedbacks[i],
            onRefresh: load,
          );
        },
      ),
    );
  }
}