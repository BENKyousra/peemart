import 'package:flutter/material.dart';

class CommentWidget extends StatelessWidget {
  final String id;
  final String name;
  final int rating;
  final String comment;
  final String date;
  final bool isOwner;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final String productId;
  final String avatar;
  

  CommentWidget({
    super.key,
    required this.id,
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
    required this.isOwner,
    required this.onDelete,
    required this.onEdit,
    required this.productId,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage:
                    avatar.isNotEmpty ? NetworkImage(avatar) : null,
                child:
                    avatar.isEmpty ? const Icon(Icons.person, size: 18) : null,
              ),

              const SizedBox(width: 8),

              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),

              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ),

              const Spacer(),

              // 🔥 ACTIONS
              if (isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: onDelete,
                  
                ),
              ],
            ],
          ),

          const SizedBox(height: 6),

          Text(
            date,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),

          const SizedBox(height: 6),

          Text(comment),
        ],
      ),
    );
  }
}

class CommentButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CommentButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.rate_review, color: Colors.white),
      label: const Text(
        "Commenter et noter",
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 0, 169, 191),
      ),
    );
  }
}

void showCommentDialog(
  BuildContext context, {
  required Function(String text, int rating) onSend,
}) {
  int rating = 0;
  TextEditingController commentController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          "Commenter et noter",
          style: TextStyle(color: Color.fromARGB(255, 0, 169, 191)),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () => setState(() => rating = index + 1),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Écrire votre commentaire...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              onSend(commentController.text, rating);
              Navigator.pop(context);
            },
            child: const Text("Envoyer"),
          ),
        ],
      );
    },
  );
}
