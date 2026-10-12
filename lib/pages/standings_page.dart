import 'package:flutter/material.dart';
import '../services/standings_service.dart';

class StandingsPage extends StatelessWidget {
  const StandingsPage({super.key});

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
    return FutureBuilder<List<Standing>>(
      future: StandingsService.loadStandings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final standings = snapshot.data!;

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