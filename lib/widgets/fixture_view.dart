import 'package:flutter/material.dart';
import '../models/match.dart';
import '../services/override_service.dart';
import '../theme/app_theme.dart';
import '../utils/fecha_format.dart';
import 'app_components.dart';
import 'async_views.dart';
import 'match_row.dart';

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

/// Fixture con la misma estructura que la planilla de la asociación:
/// día → cancha → bloques (turnos) → cruces con sus horarios y series.
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

  const FixtureView({
    super.key,
    required this.matchDays,
    this.clubId,
    this.searchQuery,
    this.highlightClubId,
    this.clubNames = const {},
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

    final fieldCards = <Widget>[];

    for (final field in day.fields) {
      final blocks = <List<Match>>[];
      final turnos = <String?>[];

      for (final block in field.blocks) {
        final matches = block.matches
            .map(OverrideService.apply)
            .where((m) => matchesFilter(m, serie))
            .toList();

        if (matches.isEmpty) continue;

        blocks.add(matches);
        turnos.add(block.turno);
      }

      if (blocks.isEmpty) continue;

      fieldCards.add(
        _FieldCard(
          fieldName: field.fieldName,
          blocks: blocks,
          turnos: turnos,
          showTurnos: field.hasTurnos,
          // Con el filtro de club todos los cruces son suyos: no se resalta.
          highlightClubId:
          widget.clubId == null ? widget.highlightClubId : null,
        ),
      );
    }

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

        if (fieldCards.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: EmptyView(
              icon: Icons.event_busy,
              message: 'No hay partidos para mostrar el ${day.day}.',
            ),
          )
        else
          ...fieldCards.map((card) => ContentWidth(child: card)),

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

class _FieldCard extends StatelessWidget {
  final String fieldName;
  final List<List<Match>> blocks;
  final List<String?> turnos;
  final bool showTurnos;
  final String? highlightClubId;

  const _FieldCard({
    required this.fieldName,
    required this.blocks,
    required this.turnos,
    required this.showTurnos,
    required this.highlightClubId,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final count = blocks.fold<int>(0, (sum, b) => sum + b.length);

    final children = <Widget>[];

    for (var i = 0; i < blocks.length; i++) {
      for (final group in MatchupGroup.consecutive(blocks[i])) {
        children.add(
          _MatchupTile(
            group: group,
            highlighted: highlightClubId != null &&
                group.first.involves(highlightClubId!),
          ),
        );
      }

      if (showTurnos) {
        children.add(_TurnoDivider(turno: turnos[i]));
      }
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.surfaceLow,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.stadium_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fieldName.toUpperCase(),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      Text(
                        '$count partidos programados',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// Un cruce con todas sus series, como lo agrupa la planilla.
class _MatchupTile extends StatelessWidget {
  final MatchupGroup group;
  final bool highlighted;

  const _MatchupTile({
    required this.group,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final first = group.first;

    return Container(
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primaryContainer : null,
        border: Border(
          top: const BorderSide(color: AppColors.border),
          left: BorderSide(
            color: highlighted ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: first.home),
                        TextSpan(
                          text: '  vs  ',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: first.away),
                      ],
                    ),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (highlighted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Text(
                      'MI CLUB',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          for (final match in group.matches)
            MatchRow(
              matchId: match.id,
              time: match.time,
              category: match.category,
              status: match.status,
            ),
        ],
      ),
    );
  }
}

class _TurnoDivider extends StatelessWidget {
  final String? turno;

  const _TurnoDivider({required this.turno});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceLow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs + 2,
      ),
      child: Text(
        turno == null ? 'TURNO' : 'TURNO: ${turno!.toUpperCase()}',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
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
