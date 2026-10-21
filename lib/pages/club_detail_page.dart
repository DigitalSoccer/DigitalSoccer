import 'package:flutter/material.dart';

import '../models/club.dart';
import '../models/fixture_round.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../models/series.dart';
import '../services/asset_json.dart';
import '../services/club_service.dart';
import '../services/data_service.dart';
import '../services/override_service.dart';
import '../services/squad_service.dart';
import '../services/standings_catalog.dart';
import '../services/standings_service.dart';
import '../theme/app_theme.dart';
import '../utils/fecha_format.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';
import '../widgets/club_tile.dart';
import '../widgets/serie_chips.dart';
import '../widgets/squad_table.dart';
import 'matchup_detail_page.dart';

/// Ficha del club (`docs/diseno.md` 6.7): escudo grande, chips de serie,
/// posición, puntos y distancia al líder, próximos partidos y plantel.
class ClubDetailPage extends StatefulWidget {
  final Club club;

  /// Fecha de referencia para decidir qué fechas son próximas (en pruebas
  /// se fija; en la app es hoy).
  final DateTime? today;

  const ClubDetailPage({super.key, required this.club, this.today});

  @override
  State<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailData {
  final List<FixtureRound> rounds;
  final StandingsCatalog catalog;

  /// Series en que juega el club según todas las fechas cargadas.
  final List<String> categories;

  final List<Squad> squads;

  _ClubDetailData({
    required this.rounds,
    required this.catalog,
    required this.categories,
    required this.squads,
  });
}

class _ClubDetailPageState extends State<ClubDetailPage> {
  String? _favoriteClubId;
  Future<_ClubDetailData>? _future;

  /// Chip elegido (compartido con Inicio, Fixture y Tabla).
  String? _tableKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_ClubDetailData> _load() async {
    final bundle = DefaultAssetBundle.of(context);

    final results = await Future.wait<Object?>([
      DataService.loadRounds(bundle),
      StandingsCatalog.load(bundle),
      ClubService.getFavoriteClubId([widget.club]),
      SquadService.loadSquads(bundle),
    ]);

    _favoriteClubId = results[2] as String?;
    _tableKey = await StandingsCatalog.getSelectedKey();

    final rounds = results[0] as List<FixtureRound>;

    if (rounds.isEmpty) {
      throw DataLoadException(DataService.indexPath, 'No hay fechas cargadas');
    }

    return _ClubDetailData(
      rounds: rounds,
      catalog: results[1] as StandingsCatalog,
      categories: sortSeries([
        for (final round in rounds)
          for (final day in round.days)
            for (final field in day.fields)
              for (final match in field.matches)
                if (match.involves(widget.club.id)) match.category,
      ]),
      squads: results[3] as List<Squad>,
    );
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  void _select(String key) {
    setState(() {
      _tableKey = key;
    });
    StandingsCatalog.setSelectedKey(key);
  }

  Future<void> _setAsMyClub() async {
    await ClubService.setFavoriteClubId(widget.club.id);

    setState(() {
      _favoriteClubId = widget.club.id;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.club.name} es ahora tu equipo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final club = widget.club;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncBody<_ClubDetailData>(
          future: _future!,
          onRetry: _retry,
          builder: (context, data) {
            final option = data.catalog.byKey(_tableKey);
            final series = StandingsCatalog.seriesOf(option.key);

            return ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              children: [
                ContentWidth(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Volver',
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: c.text,
                          onPressed: () => Navigator.maybePop(context),
                        ),
                        const Spacer(),
                        FavoriteStarButton(
                          isFavorite: _favoriteClubId == club.id,
                          onPressed: _setAsMyClub,
                        ),
                      ],
                    ),
                  ),
                ),
                ContentWidth(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screen,
                    ),
                    child: Column(
                      children: [
                        ClubAvatar(size: 92, emphasis: true, clubId: club.id),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          club.name,
                          textAlign: TextAlign.center,
                          style: AppText.display(context, size: 36),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'ANFA Caupolicán · Chiguayante',
                          style: TextStyle(fontSize: 14, color: c.textMuted),
                        ),
                        if (club.field.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 14,
                                color: c.textMuted,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  club.field,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: c.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ContentWidth(
                  child: PillChips(
                    options: [for (final o in data.catalog.options) o.label],
                    selected: option.label,
                    onSelected: (label) => _select(
                      data.catalog.options
                          .firstWhere((o) => o.label == label)
                          .key,
                    ),
                  ),
                ),
                ContentWidth(
                  child: _StatsRow(option: option, clubId: club.id),
                ),
                ContentWidth(
                  child: _UpcomingSection(
                    club: club,
                    rounds: data.rounds,
                    series: series,
                    today: widget.today ?? DateTime.now(),
                  ),
                ),
                ContentWidth(
                  child: _SquadSection(
                    club: club,
                    series: series,
                    categories: data.categories,
                    squads: data.squads,
                    onPickSeries: (name) {
                      final key = 'serie:$name';
                      if (data.catalog.options.any((o) => o.key == key)) {
                        _select(key);
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Título de sección en Barlow Condensed (24).
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.screen,
        AppSpacing.screen,
        AppSpacing.sm,
      ),
      child: Semantics(
        header: true,
        child: Text(text, style: AppText.display(context, size: 24)),
      ),
    );
  }
}

/// Tres tarjetas: Posición (roja, en amarillo), Puntos y Del líder.
class _StatsRow extends StatelessWidget {
  final TableOption option;
  final String clubId;

  const _StatsRow({required this.option, required this.clubId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final standings = option.standings;
    final position = StandingsService.positionOf(standings, clubId);

    const margin = EdgeInsets.fromLTRB(
      AppSpacing.screen,
      AppSpacing.lg,
      AppSpacing.screen,
      0,
    );

    if (position == null) {
      return Padding(
        padding: margin,
        child: InfoBanner(
          icon: Icons.leaderboard_outlined,
          message: 'Sin datos de este club en la tabla ${option.label}.',
        ),
      );
    }

    final gap = standings.first.points - position.standing.points;

    return Padding(
      padding: margin,
      child: Row(
        children: [
          Expanded(
            child: _StatBox(
              label: 'Posición',
              value: '${position.position}°',
              background: c.primary,
              labelColor: c.onPrimaryMuted,
              valueColor: c.accent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatBox(
              label: 'Puntos',
              value: '${position.standing.points}',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatBox(
              label: 'Del líder',
              // Signo menos tipográfico, como el mockup.
              value: gap == 0 ? 'Líder' : '−$gap',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? background;
  final Color? labelColor;
  final Color? valueColor;

  const _StatBox({
    required this.label,
    required this.value,
    this.background,
    this.labelColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: background ?? c.surface,
          borderRadius: BorderRadius.circular(14),
          border: background == null ? Border.all(color: c.border) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.7,
                color: labelColor ?? c.textMuted,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: AppText.display(
                  context,
                  size: 36,
                  color: valueColor ?? c.text,
                ).copyWith(height: 1.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Próximos partidos: cruces del club desde hoy en adelante (de la serie
/// elegida, si hay). Sin fechas futuras cargadas, muestra la última
/// programada y lo avisa.
class _UpcomingSection extends StatelessWidget {
  final Club club;
  final List<FixtureRound> rounds;
  final String? series;
  final DateTime today;

  const _UpcomingSection({
    required this.club,
    required this.rounds,
    required this.series,
    required this.today,
  });

  bool _isUpcoming(FixtureRound round) {
    final start = DateTime(today.year, today.month, today.day);
    return round.dates.any((d) => !d.isBefore(start));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // `rounds` viene de la más reciente a la más antigua.
    final upcoming = rounds.where(_isUpcoming).toList().reversed.toList();
    final shown = upcoming.isNotEmpty ? upcoming : [rounds.first];

    final rows = <Widget>[];

    for (final round in shown) {
      var plays = false;

      for (final day in round.days) {
        final matchups = Matchup.fromDay(
          day,
          map: OverrideService.apply,
          where: (m) =>
              m.involves(club.id) && (series == null || m.category == series),
        );

        for (final matchup in matchups) {
          plays = true;
          rows.add(
            _GameRow(
              club: club,
              round: round,
              day: day,
              matchup: matchup,
            ),
          );
        }
      }

      if (!plays) {
        final isBye = round.days.any((d) => d.byeClubIds.contains(club.id));
        rows.add(
          _MessageRow(
            text: isBye
                ? 'Libre en la fecha ${round.round}.'
                : series == null
                    ? 'Este club no tiene partidos en la fecha '
                        '${round.round}.'
                    : 'Sin partidos de $series en la fecha ${round.round}.',
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('Próximos partidos'),
        if (upcoming.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.sm,
            ),
            child: Text(
              'Aún no hay próximas fechas cargadas. Se muestra la última '
              'fecha programada.',
              style: TextStyle(fontSize: 13, color: c.textMuted),
            ),
          ),
        SurfaceCard(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) Divider(height: 1, color: c.surfaceMuted),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Fila de partido: día a la izquierda, rival y hora con cancha, y la
/// fecha del campeonato. Al tocarla se abre el detalle del cruce.
class _GameRow extends StatelessWidget {
  final Club club;
  final FixtureRound round;
  final MatchDay day;
  final Matchup matchup;

  const _GameRow({
    required this.club,
    required this.round,
    required this.day,
    required this.matchup,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rival = matchup.homeId == club.id ? matchup.away : matchup.home;
    final dow = (day.day.length > 3 ? day.day.substring(0, 3) : day.day)
        .toUpperCase();
    final count = matchup.entries.length;
    final detail = [
      matchup.firstTime,
      matchup.fieldNames.join(' · '),
      count == 1 ? matchup.categories.first : '$count partidos',
    ].join(' · ');

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MatchupDetailPage(
            matchup: matchup,
            subtitle: 'Fecha ${round.round} · ${dayLabel(day)}',
          ),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 54,
                child: Column(
                  children: [
                    Text(
                      dow,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: c.textMuted,
                      ),
                    ),
                    if (day.date != null)
                      Text(
                        '${day.date!.day}',
                        style: AppText.display(context, size: 26)
                            .copyWith(height: 1),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vs $rival',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: TextStyle(fontSize: 13, color: c.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TagChip(
                label: 'Fecha ${round.round}',
                foreground: c.tagNeutralText,
                background: c.tagNeutralBg,
                bold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  final String text;

  const _MessageRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: context.colors.textMuted),
      ),
    );
  }
}

/// Plantel de la serie elegida. Con General o un acumulado, lista las
/// series del club para elegir una.
class _SquadSection extends StatelessWidget {
  final Club club;
  final String? series;
  final List<String> categories;
  final List<Squad> squads;
  final ValueChanged<String> onPickSeries;

  const _SquadSection({
    required this.club,
    required this.series,
    required this.categories,
    required this.squads,
    required this.onPickSeries,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final series = this.series;

    if (series == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle('Plantel'),
          SurfaceCard(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: categories.isEmpty
                ? const _MessageRow(
                    text: 'Este club no tiene series en las fechas cargadas.',
                  )
                : Column(
                    children: [
                      for (var i = 0; i < categories.length; i++) ...[
                        if (i > 0) Divider(height: 1, color: c.surfaceMuted),
                        _SeriesRow(
                          name: categories[i],
                          players: SquadService.playersOf(
                            squads,
                            club.id,
                            categories[i],
                          ).length,
                          onTap: () => onPickSeries(categories[i]),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      );
    }

    final players = SquadService.playersOf(squads, club.id, series);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle('Plantel · $series'),
        SurfaceCard(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: players.isEmpty
              ? _MessageRow(
                  text: 'El plantel de $series aún no está disponible.',
                )
              : SquadTable(players: players),
        ),
        if (players.isNotEmpty) const SquadLegend(),
      ],
    );
  }
}

class _SeriesRow extends StatelessWidget {
  final String name;
  final int players;
  final VoidCallback onTap;

  const _SeriesRow({
    required this.name,
    required this.players,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.groups_outlined,
                  size: 18,
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: c.text,
                      ),
                    ),
                    Text(
                      players == 0
                          ? 'Plantel aún no disponible'
                          : '$players jugadores',
                      style: TextStyle(fontSize: 13, color: c.textMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.outline),
            ],
          ),
        ),
      ),
    );
  }
}
