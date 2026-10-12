import 'package:flutter/material.dart';

import '../models/club.dart';
import '../models/fixture_round.dart';
import '../models/match.dart';
import '../models/standing.dart';
import '../services/club_service.dart';
import '../services/data_service.dart';
import '../services/standings_service.dart';
import '../widgets/async_views.dart';

class ClubDetailPage extends StatefulWidget {
  final Club club;

  const ClubDetailPage({
    super.key,
    required this.club,
  });

  @override
  State<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailData {
  final FixtureRound fixture;
  final StandingPosition? position;

  _ClubDetailData(this.fixture, this.position);
}

class _ClubDetailPageState extends State<ClubDetailPage> {
  String? favoriteClubId;
  Future<_ClubDetailData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_ClubDetailData> _load() async {
    final bundle = DefaultAssetBundle.of(context);

    final results = await Future.wait([
      DataService.loadData(bundle),
      StandingsService.loadStandings(bundle),
      ClubService.getFavoriteClubId([widget.club]),
    ]);

    favoriteClubId = results[2] as String?;

    return _ClubDetailData(
      results[0] as FixtureRound,
      StandingsService.positionOf(
        results[1] as List<Standing>,
        widget.club.id,
      ),
    );
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> setAsMyClub() async {
    await ClubService.setFavoriteClubId(widget.club.id);

    setState(() {
      favoriteClubId = widget.club.id;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.club.name} seleccionado como Mi Club',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club.name),
      ),
      body: AsyncBody<_ClubDetailData>(
        future: _future!,
        onRetry: _retry,
        builder: (context, data) {
          final matchDays = data.fixture.days;
          final standing = data.position;

          final clubDays = matchDays.where(
                (day) => day.fields.any(
                  (field) => field.matches.any(
                    (m) => m.involves(widget.club.id),
              ),
            ),
          );

          return ListView(
            children: [
              Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Ícono genérico: no representa el escudo del club.
                      const Icon(
                        Icons.shield,
                        size: 60,
                      ),
                      const SizedBox(height: 10),

                      Text(
                        widget.club.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton.icon(
                        onPressed: setAsMyClub,
                        icon: Icon(
                          favoriteClubId == widget.club.id
                              ? Icons.star
                              : Icons.star_border,
                        ),
                        label: const Text(
                          'Establecer como Mi Club',
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (standing != null) ...[
                        Text(
                          '🏆 Posición: ${standing.position}',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),

                        Text(
                          '📊 Puntos: ${standing.standing.points}',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ] else
                        const Text(
                          'Sin información en la tabla de posiciones.',
                        ),
                    ],
                  ),
                ),
              ),

              if (clubDays.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Este club no tiene partidos en la fecha cargada.',
                    textAlign: TextAlign.center,
                  ),
                ),

              ...clubDays.map((day) {
                final matches =
                <({Match match, String field})>[];

                for (final field in day.fields) {
                  for (final match in field.matches) {
                    if (match.involves(widget.club.id)) {
                      matches.add(
                        (match: match, field: field.fieldName),
                      );
                    }
                  }
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
                      final match = item.match;

                      return ListTile(
                        title: Text(
                          '${match.home} vs ${match.away}',
                        ),
                        subtitle: Text(
                          '${match.time} • ${match.category} • ${item.field}',
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
