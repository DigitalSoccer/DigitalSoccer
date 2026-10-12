import 'package:flutter/material.dart';

import '../models/fixture_round.dart';
import '../services/data_service.dart';
import '../widgets/fixture_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar club...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),

            Expanded(
              child: FixtureView(
                matchDays: fixture.days,
                selectedClub:
                searchQuery.isEmpty ? null : searchQuery,
              ),
            ),
          ],
        );
      },
    );
  }
}