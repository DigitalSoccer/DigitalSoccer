import 'package:flutter/material.dart';

import '../models/fixture_round.dart';
import '../models/match.dart';
import '../services/club_service.dart';
import '../services/data_service.dart';
import '../services/standings_service.dart';

class ClubDetailPage extends StatefulWidget {
  final String club;

  const ClubDetailPage({
    super.key,
    required this.club,
  });

  @override
  State<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends State<ClubDetailPage> {
  String? favoriteClub;

  @override
  void initState() {
    super.initState();
    loadFavoriteClub();
  }

  Future<void> loadFavoriteClub() async {
    final club = await ClubService.getFavoriteClub();

    setState(() {
      favoriteClub = club;
    });
  }

  Future<void> setAsMyClub() async {
    await ClubService.setFavoriteClub(widget.club);

    setState(() {
      favoriteClub = widget.club;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.club} seleccionado como Mi Club',
        ),
      ),
    );
  }

  bool isClubMatch(Match match) {
    return match.home == widget.club ||
        match.away == widget.club;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club),
      ),
      body: FutureBuilder(
        future: Future.wait([
          DataService.loadData(),
          StandingsService.loadStandings(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data as List;

          final fixture =
          data[0] as FixtureRound;

          final standings =
          data[1] as List<Standing>;

          final matchDays = fixture.days;

          final standingIndex = standings.indexWhere(
                (s) =>
            s.team.toLowerCase() ==
                widget.club.toLowerCase(),
          );

          final standing = standingIndex >= 0
              ? standings[standingIndex]
              : null;

          return ListView(
            children: [
              Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.shield,
                        size: 60,
                      ),
                      const SizedBox(height: 10),

                      Text(
                        widget.club,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton.icon(
                        onPressed: setAsMyClub,
                        icon: Icon(
                          favoriteClub == widget.club
                              ? Icons.star
                              : Icons.star_border,
                        ),
                        label: const Text(
                          'Establecer como Mi Club',
                        ),
                      ),

                      if (standing != null) ...[
                        const SizedBox(height: 20),

                        Text(
                          '🏆 Posición: ${standingIndex + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),

                        Text(
                          '📊 Puntos: ${standing.points}',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              ...matchDays.map((day) {
                final matches =
                <Map<String, dynamic>>[];

                for (final field in day.fields) {
                  for (final match in field.matches) {
                    if (isClubMatch(match)) {
                      matches.add({
                        'match': match,
                        'field': field.fieldName,
                      });
                    }
                  }
                }

                if (matches.isEmpty) {
                  return const SizedBox();
                }

                return Card(
                  margin:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      day.day,
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    children: matches.map((item) {
                      final match =
                      item['match'] as Match;

                      final field =
                      item['field'] as String;

                      return ListTile(
                        title: Text(
                          '${match.home} vs ${match.away}',
                        ),
                        subtitle: Text(
                          '${match.time} • ${match.category} • $field',
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}