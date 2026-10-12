import 'package:flutter/material.dart';
import '../models/standing.dart';
import '../services/standings_service.dart';
import '../widgets/async_views.dart';

class StandingsPage extends StatefulWidget {
  const StandingsPage({super.key});

  @override
  State<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  Future<List<Standing>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<Standing>> _load() {
    return StandingsService.loadStandings(DefaultAssetBundle.of(context));
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  String medal(int position) {
    switch (position) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<List<Standing>>(
      future: _future!,
      onRetry: _retry,
      builder: (context, standings) {
        if (standings.isEmpty) {
          return const EmptyView(
            icon: Icons.emoji_events_outlined,
            message: 'La tabla de posiciones aún no está disponible.',
          );
        }

        return ListView.builder(
          itemCount: standings.length,
          itemBuilder: (context, index) {
            final team = standings[index];
            final position = index + 1;

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              child: ListTile(
                leading: SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      medal(position).isEmpty
                          ? '$position'
                          : medal(position),
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  team.team,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  '${team.points} pts',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
