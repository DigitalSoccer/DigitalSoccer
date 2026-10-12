import 'package:flutter/material.dart';

import '../models/club.dart';
import '../services/club_data_service.dart';
import '../services/club_service.dart';
import 'club_detail_page.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({super.key});

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  String? favoriteClub;

  @override
  void initState() {
    super.initState();
    loadFavoriteClub();
  }

  Future<void> loadFavoriteClub() async {
    final club =
    await ClubService.getFavoriteClub();

    setState(() {
      favoriteClub = club;
    });
  }

  Future<void> selectClub(String club) async {
    await ClubService.setFavoriteClub(club);

    setState(() {
      favoriteClub = club;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$club seleccionado como Mi Club',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Club>>(
      future: ClubDataService.loadClubs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final clubs = snapshot.data!;

        return ListView.builder(
          itemCount: clubs.length,
          itemBuilder: (context, index) {
            final club = clubs[index];

            final isFavorite =
                club.name == favoriteClub;

            return Card(
              margin:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.shield,
                ),

                title: Text(
                  club.name,
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                subtitle: Text(
                  club.field.isEmpty
                      ? 'Cancha por definir'
                      : club.field,
                ),

                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ClubDetailPage(
                            club: club.name,
                          ),
                    ),
                  );

                  loadFavoriteClub();
                },

                trailing: IconButton(
                  icon: Icon(
                    isFavorite
                        ? Icons.star
                        : Icons.star_border,
                  ),
                  color: isFavorite
                      ? Colors.amber
                      : Colors.grey,
                  onPressed: () {
                    selectClub(club.name);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}