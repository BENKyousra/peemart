import 'package:flutter/material.dart';
import '../../models/concours_model.dart';
import '../../services/concours_service.dart';
import 'concours_card.dart';
import '../../widgets/footer.dart';

class ConcoursList extends StatefulWidget {
  final ScrollController scrollController;

  const ConcoursList({
    super.key,
    required this.scrollController,
  });

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
          controller: widget.scrollController, // 🔥 IMPORTANT

          physics: const AlwaysScrollableScrollPhysics(),

          itemCount: concours.length,
          itemBuilder: (context, index) {
            final c = concours[index];

            if (index == concours.length - 1) {
        return const Footer();
      }

            return Padding(
              padding: const  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ConcoursCard(
                id: c.id,
                type: c.type,
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