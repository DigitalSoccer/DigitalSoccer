import 'package:flutter/material.dart';
import '../models/match.dart';
import '../services/override_service.dart';
import 'match_row.dart';

class FixtureView extends StatelessWidget {
  final List<MatchDay> matchDays;
  final String? selectedClub;

  const FixtureView({
    super.key,
    required this.matchDays,
    this.selectedClub,
  });

  bool isMyMatch(Match match, String club) {
    final c = club.toLowerCase();

    return match.home.toLowerCase().contains(c) ||
        match.away.toLowerCase().contains(c);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: matchDays.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: matchDays
                .map(
                  (d) => Tab(
                text: d.day,
              ),
            )
                .toList(),
          ),
          Expanded(
            child: TabBarView(
              children: matchDays.map((day) {
                return ListView(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 16,
                  ),
                  children: day.fields.map((field) {
                    final matches = field.matches
                        .map(
                          (m) => OverrideService.apply(m),
                    )
                        .where(
                          (m) => selectedClub == null
                          ? true
                          : isMyMatch(
                        m,
                        selectedClub!,
                      ),
                    )
                        .toList();

                    if (matches.isEmpty) {
                      return const SizedBox();
                    }

                    return Card(
                      elevation: 3,
                      margin:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: ExpansionTile(
                        leading: const Icon(
                          Icons.stadium,
                        ),
                        title: Text(
                          field.fieldName,
                          style: const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '${matches.length} partidos programados',
                        ),
                        children: matches.map((match) {
                          return MatchRow(
                            matchId: match.id,
                            time: match.time,
                            home: match.home,
                            away: match.away,
                            category: match.category,
                            fieldName:
                            field.fieldName,
                            status: match.status,
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}