import 'package:flutter/material.dart';
import '../models/match.dart';
import '../pages/matchup_detail_page.dart';
import '../services/override_service.dart';
import '../theme/app_theme.dart';
import '../utils/fecha_format.dart';
import 'app_components.dart';
import 'async_views.dart';
import 'matchup_card.dart';

/// Orden de las series para el filtro (de menor a mayor). Las que no estén
/// aquí se agregan al final en el orden en que aparecen.
const List<String> seriesOrder = [
  '2° Infantil',
  '1° Infantil',
  'Juveniles',
  'H. Ortiz',
  'S. Senior',
  'Segunda',
  'Primera',
  'Senior',
  'Honor',
];

/// Fixture por cruce: una tarjeta por cada "local vs visita" del día. Al
/// tocarla se abre el detalle con la cancha y los horarios de cada serie.
class FixtureView extends StatefulWidget {
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

  @override
  State<FixtureView> createState() => _FixtureViewState();
}

class _FixtureViewState extends State<FixtureView> {
  /// Serie elegida por día (null = todas).
  final Map<int, String?> _serieByDay = {};

  bool matchesFilter(Match match, String? serie) {
    if (widget.clubId != null && !match.involves(widget.clubId!)) {
      return false;
    }

    if (serie != null && match.category != serie) {
      return false;
    }

    final query = widget.searchQuery?.trim().toLowerCase() ?? '';

    if (query.isEmpty) return true;

    return match.home.toLowerCase().contains(query) ||
        match.away.toLowerCase().contains(query);
  }

  List<String> seriesOf(MatchDay day) {
    final present = <String>{
      for (final field in day.fields)
        for (final match in field.matches)
          if (widget.clubId == null || match.involves(widget.clubId!))
            match.category,
    };

    return [
      ...seriesOrder.where(present.contains),
      ...present.where((s) => !seriesOrder.contains(s)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matchDays.isEmpty) {
      return const EmptyView(
        icon: Icons.event_busy,
        message: 'No hay partidos programados.',
      );
    }

    return DefaultTabController(
      length: widget.matchDays.length,
      child: Column(
        children: [
          ContentWidth(
            child: TabBar(
              isScrollable: true,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              tabs: widget.matchDays
                  .map(
                    (d) => Tab(
                  text: dayTabLabel(d),
                ),
              )
                  .toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (var i = 0; i < widget.matchDays.length; i++)
                  _buildDay(context, i, widget.matchDays[i]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDay(BuildContext context, int index, MatchDay day) {
    final serie = _serieByDay[index];
    final series = seriesOf(day);

    final matchups = Matchup.fromDay(
      day,
      map: OverrideService.apply,
      where: (m) => matchesFilter(m, serie),
    );

    // El detalle muestra todas las series del cruce, aunque la lista esté
    // filtrada por una serie: el filtro solo sirve para encontrarlo.
    final complete = {
      for (final m in Matchup.fromDay(
        day,
        map: OverrideService.apply,
        where: (m) => matchesFilter(m, null),
      ))
        '${m.homeId}|${m.awayId}': m,
    };

    // Con el filtro de club todos los cruces son suyos: no se resalta.
    final highlight =
    widget.clubId == null ? widget.highlightClubId : null;

    final subtitle = [
      if (widget.roundNumber != null) 'Fecha ${widget.roundNumber}',
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
              builder: (_) => MatchupDetailPage(
                matchup:
                complete['${matchup.homeId}|${matchup.awayId}'] ?? matchup,
                subtitle: subtitle,
              ),
            ),
          ),
        ),
    ];

    final byes = day.byeClubIds
        .map((id) => widget.clubNames[id] ?? id)
        .toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        if (series.length > 1)
          ContentWidth(
            child: _SerieFilter(
              series: series,
              selected: serie,
              onSelected: (value) {
                setState(() {
                  _serieByDay[index] = value;
                });
              },
            ),
          ),

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

        if (byes.isNotEmpty && widget.clubId == null)
          ContentWidth(
            child: _ByeBanner(names: byes),
          ),
      ],
    );
  }
}

class _SerieFilter extends StatelessWidget {
  final List<String> series;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _SerieFilter({
    required this.series,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, String? value) {
      final isSelected = selected == value;

      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          showCheckmark: false,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.onPrimary : AppColors.textMuted,
          ),
          onSelected: (_) => onSelected(value),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          chip('Todas', null),
          for (final s in series) chip(s, s),
        ],
      ),
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
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_available_outlined,
              size: 20,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Libre: ${names.join(', ')}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
