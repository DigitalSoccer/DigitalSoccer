import 'package:flutter/material.dart';

import '../models/club.dart';
import '../services/club_data_service.dart';
import '../services/club_service.dart';
import '../widgets/async_views.dart';
import 'club_detail_page.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({super.key});

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  String? favoriteClubId;
  Future<List<Club>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<Club>> _load() async {
    final clubs =
    await ClubDataService.loadClubs(DefaultAssetBundle.of(context));

    favoriteClubId = await ClubService.getFavoriteClubId(clubs);

    return clubs;
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> selectClub(Club club) async {
    await ClubService.setFavoriteClubId(club.id);

    setState(() {
      favoriteClubId = club.id;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${club.name} seleccionado como Mi Club',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<List<Club>>(
      future: _future!,
      onRetry: _retry,
      builder: (context, clubs) {
        if (clubs.isEmpty) {
          return const EmptyView(
            icon: Icons.shield_outlined,
            message: 'No hay clubes registrados.',
          );
        }

        return ListView.builder(
          itemCount: clubs.length,
          itemBuilder: (context, index) {
            final club = clubs[index];

            final isFavorite =
                club.id == favoriteClubId;

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
                            club: club,
                          ),
                    ),
                  );

                  final id =
                  await ClubService.getFavoriteClubId(clubs);

                  if (!mounted) return;

                  setState(() {
                    favoriteClubId = id;
                  });
                },

                trailing: IconButton(
                  tooltip: isFavorite
                      ? 'Mi Club'
                      : 'Establecer como Mi Club',
                  icon: Icon(
                    isFavorite
                        ? Icons.star
                        : Icons.star_border,
                  ),
                  color: isFavorite
                      ? Colors.amber
                      : Colors.grey,
                  onPressed: () {
                    selectClub(club);
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
