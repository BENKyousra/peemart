import 'package:flutter/material.dart';
import '../../models/concours_model.dart';
import '../../services/concours_service.dart';
import 'concours_card.dart';

class ConcoursList extends StatefulWidget {
  const ConcoursList({super.key});

  @override
  State<ConcoursList> createState() => _ConcoursListState();
}

class _ConcoursListState extends State<ConcoursList> {
  final ConcoursService _service = ConcoursService();
  late Future<List<ConcoursModel>> _futureConcours;

  @override
  void initState() {
    super.initState();
    _futureConcours = _service.getConcours();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConcoursModel>>(
      future: _futureConcours,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Erreur de chargement"));
        }

        final concours = snapshot.data ?? [];

        if (concours.isEmpty) {
          return const Center(child: Text("Aucun concours disponible"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: concours.length,
          itemBuilder: (context, index) {
            final c = concours[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ConcoursCard(
                id: c.id, // 🔥 IMPORTANT
                type: c.type, // 🔥 IMPORTANT
                shopName: c.shopName,
                avatarUrl: c.avatarUrl ?? "",
                imageUrl: c.imageUrl ?? "",
                description: c.description ?? "",
              ),
            );
          },
        );
      },
    );
  }
}