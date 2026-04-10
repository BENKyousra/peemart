import 'package:flutter/material.dart';

class EditableField extends StatefulWidget {
  final String label;
  final String initialValue;
  final Function(String) onSave;

  const EditableField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onSave,
  });

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  bool isEditing = false;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            enabled: isEditing, // activé seulement si on clique sur le crayon
            decoration: InputDecoration(
              labelText: widget.label,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit),
          color: isEditing ? Colors.green : Colors.grey,
          onPressed: () {
            if (isEditing) {
              // Sauvegarder la valeur
              widget.onSave(controller.text);
            }
            setState(() {
              isEditing = !isEditing; // bascule le mode édition
            });
          },
        ),
      ],
    );
  }
}
