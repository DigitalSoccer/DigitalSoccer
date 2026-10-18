import 'package:flutter/material.dart';
import '../models/match.dart';
import '../pages/matchup_detail_page.dart';
import '../services/override_service.dart';
import '../theme/app_theme.dart';
import '../utils/fecha_format.dart';
import 'app_components.dart';
import 'async_views.dart';
import 'matchup_card.dart';

/// Fixture por cruce: una tarjeta por cada "local vs visita" del día. Al
/// tocarla se abre el detalle con la cancha y los horarios de cada serie.
class FixtureView extends StatelessWidget {
  final List<MatchDay> matchDays;

  /// Si se indica, solo muestra los partidos de ese club.
  final String? clubId;

  /// Texto libre del buscador; filtra por nombre de equipo.
  final String? searchQuery;

  /// Club a destacar (Mi Club) sin filtrar al resto.
  final String? highlightClubId;

  /// Nombres de clubes por id, para el aviso de "Libre".
  final Map<String, String> clubNames;

  /// Número de fecha, para el encabezado del detalle.
  final int? roundNumber;

  const FixtureView({
    super.key,
    required this.matchDays,
    this.clubId,
    this.searchQuery,
    this.highlightClubId,
    this.clubNames = const {},
    this.roundNumber,
  });

  // Los filtros (club y nombre de equipo) aplican a todas las series de un
  // cruce por igual, así que cada tarjeta conserva el cruce completo.
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
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: ContentWidth(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: SegmentedTabBar(
                  scrollable: matchDays.length > 3,
                  labels: [for (final day in matchDays) dayTabLabel(day)],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [for (final day in matchDays) _buildDay(context, day)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDay(BuildContext context, MatchDay day) {
    final matchups = Matchup.fromDay(
      day,
      map: OverrideService.apply,
      where: matchesFilter,
    );

    // Con el filtro de club todos los cruces son suyos: no se resalta.
    final highlight = clubId == null ? highlightClubId : null;

    final subtitle = [
      if (roundNumber != null) 'Fecha $roundNumber',
      dayLabel(day),
    ].join(' · ');

    final cards = [
      for (final matchup in matchups)
        MatchupCard(
          matchup: matchup,
          highlighted: highlight != null && matchup.involves(highlight),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MatchupDetailPage(matchup: matchup, subtitle: subtitle),
            ),
          ),
        ),
    ];

    final byes = day.byeClubIds.map((id) => clubNames[id] ?? id).toList();

    return ListView(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.xl),
      children: [
        if (cards.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: EmptyView(
              icon: Icons.event_busy,
              message: 'No hay partidos para mostrar el ${day.day}.',
            ),
          )
        else
          ...cards.map((card) => ContentWidth(child: card)),

        if (byes.isNotEmpty && clubId == null)
          ContentWidth(child: _ByeBanner(names: byes)),
      ],
    );
  }
}

class _ByeBanner extends StatelessWidget {
  final List<String> names;

  const _ByeBanner({required this.names});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: InfoBanner(
        icon: Icons.event_available_outlined,
        message: 'Libre: ${names.join(', ')}',
        strong: true,
      ),
    );
  }
}
