import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditTextSheet extends StatefulWidget {
  final String feedbackId;
  final String initialText;
  final VoidCallback onUpdated;

  const EditTextSheet({
    super.key,
    required this.feedbackId,
    required this.initialText,
    required this.onUpdated,
  });

  @override
  State<EditTextSheet> createState() => _EditTextSheetState();
}

class _EditTextSheetState extends State<EditTextSheet> {
  final supabase = Supabase.instance.client;
  late TextEditingController controller;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  Future<void> update() async {
  final user = supabase.auth.currentUser;
  if (user == null) return;

  if (controller.text.trim().isEmpty) return;

  setState(() => loading = true);

  try {
    final res = await supabase
        .from('feedbacks')
        .update({
          'content': controller.text.trim(),
        })
        .eq('id', widget.feedbackId)
        .eq('user_id', user.id) // 🔥 VERY IMPORTANT
        .select(); // 🔥 pour debug

    print("UPDATE RESULT: $res");

    widget.onUpdated();
    Navigator.pop(context);
  } catch (e) {
    print("UPDATE ERROR: $e");
  }

  setState(() => loading = false);
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Modifier le texte",
              style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Modifier...",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: loading ? null : update,
            child: loading
                ? const CircularProgressIndicator()
                : const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }
}