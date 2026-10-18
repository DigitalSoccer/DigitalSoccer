import 'package:flutter/material.dart';

import '../models/club.dart';
import '../models/fixture_round.dart';
import '../models/match.dart';
import '../models/standing.dart';
import '../services/club_data_service.dart';
import '../services/club_service.dart';
import '../services/data_service.dart';
import '../services/override_service.dart';
import '../services/standings_service.dart';
import '../theme/app_theme.dart';
import '../utils/fecha_format.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';
import '../widgets/club_tile.dart';
import '../widgets/matchup_card.dart';
import 'matchup_detail_page.dart';

/// Pestaña de inicio. Sin club elegido, invita a elegir uno; con club,
/// muestra su posición y sus partidos de la fecha más reciente.
class InicioPage extends StatefulWidget {
  /// Abren las pestañas Fixture y Tabla (las provee la navegación principal).
  final VoidCallback? onOpenFixture;
  final VoidCallback? onOpenStandings;

  const InicioPage({super.key, this.onOpenFixture, this.onOpenStandings});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioData {
  final List<Club> clubs;
  final Club? club;
  final FixtureRound round;
  final StandingPosition? position;
  final List<Standing> standings;

  _InicioData({
    required this.clubs,
    required this.club,
    required this.round,
    required this.position,
    required this.standings,
  });
}

class _InicioPageState extends State<InicioPage> {
  Future<_InicioData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_InicioData> _load() async {
    final bundle = DefaultAssetBundle.of(context);

    final results = await Future.wait([
      ClubDataService.loadClubs(bundle),
      DataService.loadData(bundle),
      StandingsService.loadStandings(bundle),
    ]);

    final clubs = results[0] as List<Club>;
    final club = ClubDataService.findById(
      clubs,
      await ClubService.getFavoriteClubId(clubs),
    );

    final standings = results[2] as List<Standing>;

    return _InicioData(
      clubs: clubs,
      club: club,
      round: results[1] as FixtureRound,
      position: club == null
          ? null
          : StandingsService.positionOf(standings, club.id),
      standings: standings,
    );
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _choose(Club club) async {
    await ClubService.setFavoriteClubId(club.id);
    if (!mounted) return;
    _reload();
  }

  Future<void> _changeClub(_InicioData data) async {
    final chosen = await showAppBottomSheet<Club>(
      context: context,
      title: 'Cambiar mi club',
      initialSize: 0.8,
      builder: (context) => [
        for (final club in data.clubs)
          ClubTile(
            club: club,
            trailing: club.id == data.club?.id
                ? const Padding(
                    padding: EdgeInsets.only(right: AppSpacing.sm),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                    ),
                  )
                : null,
            onTap: () => Navigator.pop(context, club),
          ),
      ],
    );

    if (chosen != null) await _choose(chosen);
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<_InicioData>(
      future: _future!,
      onRetry: _reload,
      builder: (context, data) {
        final club = data.club;

        if (club == null) {
          return _ChooseClub(clubs: data.clubs, onSelected: _choose);
        }

        return _ClubHome(
          club: club,
          data: data,
          onChangeClub: () => _changeClub(data),
          onOpenFixture: widget.onOpenFixture,
          onOpenStandings: widget.onOpenStandings,
        );
      },
    );
  }
}

/// Primera vez: bienvenida y lista de clubes para elegir.
class _ChooseClub extends StatelessWidget {
  final List<Club> clubs;
  final ValueChanged<Club> onSelected;

  const _ChooseClub({required this.clubs, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: ContentWidth(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports_soccer_rounded,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '¡Bienvenido!',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Elige tu club para ver sus partidos de la fecha y su '
                    'posición en la tabla.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (clubs.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xl),
            child: EmptyView(
              icon: Icons.shield_outlined,
              message: 'No hay clubes registrados.',
            ),
          )
        else ...[
          const ContentWidth(child: SectionHeader('Clubes')),
          for (final club in clubs)
            ContentWidth(
              child: ClubTile(
                club: club,
                trailing: const Padding(
                  padding: EdgeInsets.only(right: AppSpacing.sm),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.outline,
                  ),
                ),
                onTap: () => onSelected(club),
              ),
            ),
        ],
      ],
    );
  }
}

/// Inicio con club elegido, al estilo de la maqueta: encabezado rojo con el
/// panel "MI CLUB", tarjetas de posición y puntos montadas sobre el rojo, los
/// partidos del club en la fecha y un resumen de la tabla.
class _ClubHome extends StatelessWidget {
  final Club club;
  final _InicioData data;
  final VoidCallback onChangeClub;
  final VoidCallback? onOpenFixture;
  final VoidCallback? onOpenStandings;

  const _ClubHome({
    required this.club,
    required this.data,
    required this.onChangeClub,
    required this.onOpenFixture,
    required this.onOpenStandings,
  });

  @override
  Widget build(BuildContext context) {
    final round = data.round;

    final days = [
      for (final day in round.days)
        (
          day: day,
          matchups: Matchup.fromDay(
            day,
            map: OverrideService.apply,
            where: (m) => m.involves(club.id),
          ),
        ),
    ];
    final playsThisRound = days.any((d) => d.matchups.isNotEmpty);
    final isBye = round.days.any((d) => d.byeClubIds.contains(club.id));
    final range = roundDateRange(round);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        _RedHeader(
          club: club,
          position: data.position,
          onChangeClub: onChangeClub,
        ),

        ContentWidth(
          child: SectionHeader(
            ['Fecha ${round.round}', range]
                .where((s) => s.isNotEmpty)
                .join(' · '),
          ),
        ),

        if (!playsThisRound)
          ContentWidth(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: InfoBanner(
                icon: isBye
                    ? Icons.event_available_outlined
                    : Icons.event_busy_outlined,
                message: isBye
                    ? 'Libre en la fecha ${round.round}.'
                    : 'Sin partidos en la fecha ${round.round}.',
              ),
            ),
          ),

        for (final entry in days)
          for (final matchup in entry.matchups)
            ContentWidth(
              child: MatchupCard(
                matchup: matchup,
                highlighted: false,
                dayLabel: dayLabel(entry.day),
                roundLabel: 'FECHA ${round.round}',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MatchupDetailPage(
                      matchup: matchup,
                      subtitle: 'Fecha ${round.round} · ${dayLabel(entry.day)}',
                    ),
                  ),
                ),
              ),
            ),

        if (data.standings.isNotEmpty)
          ContentWidth(
            child: _StandingsPreview(
              standings: data.standings,
              clubId: club.id,
              onOpenStandings: onOpenStandings,
            ),
          ),

        if (onOpenFixture != null)
          ContentWidth(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: OutlinedButton.icon(
                onPressed: onOpenFixture,
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Ver fixture completo'),
              ),
            ),
          ),
      ],
    );
  }
}

/// Encabezado rojo con el panel "MI CLUB" y, montadas sobre su borde
/// inferior, las tarjetas de POSICIÓN y PUNTOS.
class _RedHeader extends StatelessWidget {
  final Club club;
  final StandingPosition? position;
  final VoidCallback onChangeClub;

  const _RedHeader({
    required this.club,
    required this.position,
    required this.onChangeClub,
  });

  /// Cuánto sobresalen las tarjetas por debajo del rojo.
  static const double _overlap = 44;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final standing = position;

    return Stack(
      children: [
        Positioned.fill(
          bottom: _overlap,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.xl),
              ),
            ),
          ),
        ),
        ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Panel "MI CLUB".
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDeep,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      const ClubCrest(size: 52, onRed: true),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MI CLUB',
                              style: AppText.eyebrow.copyWith(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              club.name,
                              style: textTheme.titleLarge?.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (club.field.isNotEmpty)
                              Text(
                                club.field,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.primaryContainer,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilledButton.icon(
                        onPressed: onChangeClub,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.primary,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        label: const Text('Cambiar'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (standing != null)
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: 'Posición',
                          value: '${standing.position}',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _MetricCard(
                          label: 'Puntos',
                          value: '${standing.standing.points}',
                        ),
                      ),
                    ],
                  )
                else
                  const SurfaceCard(
                    shadow: AppShadows.md,
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'Sin información en la tabla de posiciones.',
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      shadow: AppShadows.md,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: StatTile(
        label: label,
        value: value,
        valueColor: AppColors.primary,
      ),
    );
  }
}

/// Resumen de la tabla general: los tres primeros y, si está más abajo, la
/// fila del club elegido. "Ver tabla" abre la pestaña Tabla.
class _StandingsPreview extends StatelessWidget {
  final List<Standing> standings;
  final String clubId;
  final VoidCallback? onOpenStandings;

  const _StandingsPreview({
    required this.standings,
    required this.clubId,
    required this.onOpenStandings,
  });

  static const int _top = 3;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final clubIndex = standings.indexWhere((s) => s.clubId == clubId);

    final rows = <Widget>[
      for (var i = 0; i < standings.length && i < _top; i++)
        _PreviewRow(
          rank: StandingsService.rankOf(standings, standings[i]),
          standing: standings[i],
          isMyClub: standings[i].clubId == clubId,
        ),
      if (clubIndex >= _top) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            '···',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: AppColors.outline),
          ),
        ),
        _PreviewRow(
          rank: StandingsService.rankOf(standings, standings[clubIndex]),
          standing: standings[clubIndex],
          isMyClub: true,
        ),
      ],
    ];

    return SurfaceCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      shadow: AppShadows.md,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Tabla', style: textTheme.titleMedium)),
              if (onOpenStandings != null)
                TextButton(
                  onPressed: onOpenStandings,
                  child: const Text('Ver tabla'),
                ),
            ],
          ),
          ...rows,
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final int rank;
  final Standing standing;
  final bool isMyClub;

  const _PreviewRow({
    required this.rank,
    required this.standing,
    required this.isMyClub,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm, top: 2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isMyClub ? AppColors.primarySoft : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isMyClub ? AppColors.primary : AppColors.text,
              ),
            ),
          ),
          const ClubCrest(size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              standing.team,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: isMyClub ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${standing.points} pts',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontFeatures: AppText.tabular,
            ),
          ),
        ],
      ),
    );
  }
}
