import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/comment_service.dart';
import 'comment.dart';
import '../../models/comment_model.dart';

class CommentSection extends StatefulWidget {
  final String productId;

  CommentSection({super.key, required this.productId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final currentUser = Supabase.instance.client.auth.currentUser;
  final CommentService commentService = CommentService();
  Key _streamKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CommentModel>>(
      key: _streamKey,
      stream: commentService.commentStream(widget.productId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final comments = snapshot.data!;

        if (comments.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Text(
                  "Pas de commentaires encore",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children:
              comments.map((c) {
                return CommentWidget(
                  id: c.id,
                  name: c.name,
                  avatar: c.avatarUrl,
                  rating: c.rating,
                  comment: c.content,
                  date: "${c.createdAt.toLocal()}".split(' ')[0],
                  productId: widget.productId,
                  isOwner: currentUser?.id == c.userId,
                  onDelete: () async {
                    await commentService.deleteComment(c.id, widget.productId);

                    setState(() {
                      _streamKey = UniqueKey();
                    });
                  },
                  onEdit: () {
                    showCommentDialog(
                      context,
                      onSend: (text, rating) async {
                        await commentService.updateComment(
                          commentId: c.id,
                          text: text,
                          rating: rating,
                          productId: widget.productId,
                        );
                      },
                    );
                  },
                );
              }).toList(),
        );
      },
    );
  }
}
