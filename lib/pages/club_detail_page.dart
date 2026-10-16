import 'package:flutter/material.dart';

import '../models/club.dart';
import '../models/fixture_round.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../models/series.dart';
import '../models/standing.dart';
import '../services/asset_json.dart';
import '../services/club_service.dart';
import '../services/data_service.dart';
import '../services/override_service.dart';
import '../services/squad_service.dart';
import '../services/standings_service.dart';
import '../theme/app_theme.dart';
import '../utils/fecha_format.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';
import '../widgets/matchup_card.dart';
import '../widgets/squad_table.dart';
import 'matchup_detail_page.dart';

/// Ficha de un club: encabezado con posición y puntos, y dos pestañas:
/// "Plantel" (series desplegables) y "Próximas fechas".
class ClubDetailPage extends StatefulWidget {
  final Club club;

  /// Fecha de referencia para decidir qué fechas son próximas (en pruebas
  /// se fija; en la app es hoy).
  final DateTime? today;

  const ClubDetailPage({
    super.key,
    required this.club,
    this.today,
  });

  @override
  State<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailData {
  final List<FixtureRound> rounds;
  final StandingPosition? position;

  /// Series en que juega el club según todas las fechas cargadas.
  final List<String> categories;

  final List<Squad> squads;

  _ClubDetailData({
    required this.rounds,
    required this.position,
    required this.categories,
    required this.squads,
  });
}

class _ClubDetailPageState extends State<ClubDetailPage> {
  String? favoriteClubId;
  Future<_ClubDetailData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_ClubDetailData> _load() async {
    final bundle = DefaultAssetBundle.of(context);

    final results = await Future.wait([
      DataService.loadRounds(bundle),
      StandingsService.loadStandings(bundle),
      ClubService.getFavoriteClubId([widget.club]),
      SquadService.loadSquads(bundle),
    ]);

    favoriteClubId = results[2] as String?;

    final rounds = results[0] as List<FixtureRound>;

    if (rounds.isEmpty) {
      throw DataLoadException(DataService.indexPath, 'No hay fechas cargadas');
    }

    return _ClubDetailData(
      rounds: rounds,
      position: StandingsService.positionOf(
        results[1] as List<Standing>,
        widget.club.id,
      ),
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

  Future<void> setAsMyClub() async {
    await ClubService.setFavoriteClubId(widget.club.id);

    setState(() {
      favoriteClubId = widget.club.id;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.club.name} seleccionado como Mi Club',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club.name),
      ),
      body: AsyncBody<_ClubDetailData>(
        future: _future!,
        onRetry: _retry,
        builder: (context, data) {
          return DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(
                  child: ContentWidth(
                    child: _ClubHeader(
                      club: widget.club,
                      position: data.position,
                      isFavorite: favoriteClubId == widget.club.id,
                      onSetFavorite: setAsMyClub,
                    ),
                  ),
                ),
                const SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabsHeader(),
                ),
              ],
              body: TabBarView(
                children: [
                  _SquadTab(
                    club: widget.club,
                    categories: data.categories,
                    squads: data.squads,
                  ),
                  _UpcomingTab(
                    club: widget.club,
                    rounds: data.rounds,
                    today: widget.today ?? DateTime.now(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClubHeader extends StatelessWidget {
  final Club club;
  final StandingPosition? position;
  final bool isFavorite;
  final VoidCallback onSetFavorite;

  const _ClubHeader({
    required this.club,
    required this.position,
    required this.isFavorite,
    required this.onSetFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final standing = position;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Ícono genérico: no representa el escudo del club.
              const ClubAvatar(size: 56),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (club.field.isNotEmpty)
                      Text(
                        club.field,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavorite ? 'Es Mi Club' : 'Establecer como Mi Club',
                onPressed: onSetFavorite,
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? AppColors.favorite : AppColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (standing != null)
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Posición',
                    value: '${standing.position}',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatTile(
                    label: 'Puntos',
                    value: '${standing.standing.points}',
                  ),
                ),
              ],
            )
          else
            Text(
              'Sin información en la tabla de posiciones.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

/// Pestañas fijas bajo el encabezado al desplazar.
class _TabsHeader extends SliverPersistentHeaderDelegate {
  const _TabsHeader();

  static const double _height = 48;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      child: const ContentWidth(
        child: TabBar(
          // El tema alinea las pestañas al inicio (válido solo para barras
          // desplazables); estas dos ocupan el ancho completo.
          tabAlignment: TabAlignment.fill,
          tabs: [
            Tab(text: 'Plantel'),
            Tab(text: 'Próximas fechas'),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabsHeader oldDelegate) => false;
}

/// Pestaña Plantel: una fila desplegable por serie.
class _SquadTab extends StatelessWidget {
  final Club club;
  final List<String> categories;
  final List<Squad> squads;

  const _SquadTab({
    required this.club,
    required this.categories,
    required this.squads,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const EmptyView(
        icon: Icons.groups_outlined,
        message: 'Este club no tiene series en las fechas cargadas.',
      );
    }

    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xl,
      ),
      children: [
        for (final category in categories)
          ContentWidth(
            child: Builder(
              builder: (context) {
                final players =
                    SquadService.playersOf(squads, club.id, category);

                return Card(
                  margin: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    0,
                  ),
                  child: ExpansionTile(
                    leading: const Icon(
                      Icons.groups_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      category,
                      style: textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      players.isEmpty
                          ? 'Plantel aún no disponible'
                          : '${players.length} jugadores',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    children: [
                      if (players.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.lg,
                          ),
                          child: Text(
                            'El plantel de $category aún no está disponible.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        )
                      else
                        SquadTable(players: players),
                    ],
                  ),
                );
              },
            ),
          ),
        const ContentWidth(child: SquadLegend()),
      ],
    );
  }
}

/// Pestaña Próximas fechas: cruces del club desde hoy en adelante. Si no
/// hay fechas futuras cargadas, muestra la última programada y lo avisa.
class _UpcomingTab extends StatelessWidget {
  final Club club;
  final List<FixtureRound> rounds;
  final DateTime today;

  const _UpcomingTab({
    required this.club,
    required this.rounds,
    required this.today,
  });

  bool _isUpcoming(FixtureRound round) {
    final start = DateTime(today.year, today.month, today.day);
    return round.dates.any((d) => !d.isBefore(start));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // `rounds` viene de la más reciente a la más antigua.
    final upcoming = rounds.where(_isUpcoming).toList().reversed.toList();
    final shown = upcoming.isNotEmpty ? upcoming : [rounds.first];

    final children = <Widget>[
      if (upcoming.isEmpty)
        ContentWidth(
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Aún no hay próximas fechas cargadas. '
                    'Se muestra la última fecha programada.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ];

    for (final round in shown) {
      final range = roundDateRange(round);

      children.add(
        ContentWidth(
          child: SectionHeader(
            ['Fecha ${round.round}', range]
                .where((s) => s.isNotEmpty)
                .join(' · '),
          ),
        ),
      );

      var plays = false;

      for (final day in round.days) {
        final matchups = Matchup.fromDay(
          day,
          map: OverrideService.apply,
          where: (m) => m.involves(club.id),
        );

        if (matchups.isEmpty) continue;
        plays = true;

        children.add(
          ContentWidth(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                0,
              ),
              child: Text(dayLabel(day), style: textTheme.titleSmall),
            ),
          ),
        );

        for (final matchup in matchups) {
          children.add(
            ContentWidth(
              child: MatchupCard(
                matchup: matchup,
                highlighted: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MatchupDetailPage(
                      matchup: matchup,
                      subtitle: 'Fecha ${round.round} · ${dayLabel(day)}',
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }

      if (!plays) {
        final isBye = round.days.any(
          (d) => d.byeClubIds.contains(club.id),
        );

        children.add(
          ContentWidth(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                isBye
                    ? 'Libre en la fecha ${round.round}.'
                    : 'Este club no tiene partidos en la fecha cargada.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: children,
    );
  }
}
