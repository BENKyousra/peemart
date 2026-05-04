import 'package:flutter/material.dart';
import 'feedback_item.dart';
import '../../services/feedback_service.dart';
import '../footer.dart';

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

  child: ListView.builder(
    controller: widget.scrollController,
    physics: const AlwaysScrollableScrollPhysics(),

    itemCount: feedbacks.length + 1, // 🔥 +1 pour footer

    itemBuilder: (context, i) {

      // 👇 FOOTER À LA FIN
      if (i == feedbacks.length) {
        return const Footer();
      }

      return FeedbackItem(
        feedback: feedbacks[i],
        onRefresh: load,
      );
    },
  ),
);
  }
}