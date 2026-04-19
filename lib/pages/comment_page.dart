import 'package:flutter/material.dart';
import '../widgets/product/comment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/comment_service.dart';
import '../models/comment_model.dart';


class CommentsPage extends StatefulWidget {
  final String productId;

  const CommentsPage({super.key, required this.productId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  List<CommentModel> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    final data = await CommentService.fetchComments(widget.productId);

    setState(() {
      comments = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Commentaires")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  /// 🔹 زر إضافة تعليق
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: CommentButton(
                      onPressed: () {
                        showCommentDialog(
                          context,
                          onSend: (text, rating) async {
                            await CommentService().addComment(
                              productId: widget.productId,
                              text: text,
                              rating: rating,
                            );

                            loadComments(); // 🔥 تحديث
                          },
                        );
                      },
                    ),
                  ),

                  /// 🔹 قائمة التعليقات
                  Expanded(
                    child: ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final c = comments[index];

                        return CommentWidget(
                          id: c.id,
                          name: c.name,
                          rating: c.rating,
                          comment: c.content,
                          date: c.createdAt.toString(),
                          isOwner: currentUser?.id == c.userId,

                          /// 🔥 DELETE
                          onDelete: () async {
                            await CommentService().deleteComment(
                              c.id,
                              widget.productId,
                            );
                            loadComments();
                          },

                          /// 🔥 EDIT
                          onEdit: () {
                            showCommentDialog(
                              context,
                              onSend: (text, rating) async {
                                await CommentService().updateComment(
                                  commentId: c.id,
                                  text: text,
                                  rating: rating,
                                  productId: widget.productId,
                                );
                                loadComments();
                              },
                            );
                          },
                          
                          productId: '',
                          avatar: ''
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}