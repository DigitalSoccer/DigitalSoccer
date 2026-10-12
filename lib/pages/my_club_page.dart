import 'package:flutter/material.dart';

import '../models/fixture_round.dart';
import '../services/club_service.dart';
import '../services/data_service.dart';
import '../widgets/fixture_view.dart';

class MyClubPage extends StatefulWidget {
  const MyClubPage({super.key});

  @override
  State<MyClubPage> createState() => _MyClubPageState();
}

class _MyClubPageState extends State<MyClubPage> {
  String? selectedClub;

  @override
  void initState() {
    super.initState();
    loadClub();
  }

  Future<void> loadClub() async {
    final club = await ClubService.getFavoriteClub();

    setState(() {
      selectedClub = club;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedClub == null) {
      return const Center(
        child: Text(
          'Selecciona un club en la pestaña Clubes',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return FutureBuilder<FixtureRound>(
      future: DataService.loadData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final fixture = snapshot.data!;

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.green,
              child: Text(
                'Mi Club: $selectedClub',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(
              child: FixtureView(
                matchDays: fixture.days,
                selectedClub: selectedClub,
              ),
            ),
          ],
        );
      },
    );
  }
}