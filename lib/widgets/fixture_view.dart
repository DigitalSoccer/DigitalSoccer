import 'package:flutter/material.dart';
import '../models/match.dart';
import '../services/override_service.dart';
import 'async_views.dart';
import 'match_row.dart';

class FixtureView extends StatelessWidget {
  final List<MatchDay> matchDays;

  /// Si se indica, solo muestra los partidos de ese club.
  final String? clubId;

  /// Texto libre del buscador; filtra por nombre de equipo.
  final String? searchQuery;

  const FixtureView({
    super.key,
    required this.matchDays,
    this.clubId,
    this.searchQuery,
  });

  bool matchesFilter(Match match) {
    if (clubId != null && !match.involves(clubId!)) {
      return false;
    }

    final query = searchQuery?.trim().toLowerCase() ?? '';

    if (query.isEmpty) return true;

    return match.home.toLowerCase().contains(query) ||
        match.away.toLowerCase().contains(query);
  }

  @override
  Widget build(BuildContext context) {
    if (matchDays.isEmpty) {
      return const EmptyView(
        icon: Icons.event_busy,
        message: 'No hay partidos programados.',
      );
    }

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
                final fieldCards = <Widget>[];

                for (final field in day.fields) {
                  final matches = field.matches
                      .map(
                        (m) => OverrideService.apply(m),
                  )
                      .where(matchesFilter)
                      .toList();

                  if (matches.isEmpty) continue;

                  fieldCards.add(
                    Card(
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
                    ),
                  );
                }

                if (fieldCards.isEmpty) {
                  return EmptyView(
                    icon: Icons.event_busy,
                    message: 'No hay partidos para mostrar el ${day.day}.',
                  );
                }

                return ListView(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 16,
                  ),
                  children: fieldCards,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
