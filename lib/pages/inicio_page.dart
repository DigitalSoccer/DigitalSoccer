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
import '../widgets/club_header.dart';
import '../widgets/club_tile.dart';
import '../widgets/matchup_card.dart';
import 'matchup_detail_page.dart';

/// Pestaña de inicio. Sin club elegido, invita a elegir uno; con club,
/// muestra su posición y sus partidos de la fecha más reciente.
class InicioPage extends StatefulWidget {
  /// Abre la pestaña Fixture (la provee la navegación principal).
  final VoidCallback? onOpenFixture;

  const InicioPage({super.key, this.onOpenFixture});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioData {
  final List<Club> clubs;
  final Club? club;
  final FixtureRound round;
  final StandingPosition? position;

  _InicioData({
    required this.clubs,
    required this.club,
    required this.round,
    required this.position,
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

    return _InicioData(
      clubs: clubs,
      club: club,
      round: results[1] as FixtureRound,
      position: club == null
          ? null
          : StandingsService.positionOf(results[2] as List<Standing>, club.id),
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

/// Inicio con club elegido.
class _ClubHome extends StatelessWidget {
  final Club club;
  final _InicioData data;
  final VoidCallback onChangeClub;
  final VoidCallback? onOpenFixture;

  const _ClubHome({
    required this.club,
    required this.data,
    required this.onChangeClub,
    required this.onOpenFixture,
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
        ClubHeroHeader(
          club: club,
          position: data.position,
          eyebrow: 'MI CLUB',
          action: TextButton.icon(
            onPressed: onChangeClub,
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: const Text('Cambiar'),
          ),
        ),

        ContentWidth(
          child: SectionHeader(
            [
              'Fecha ${round.round}',
              range,
            ].where((s) => s.isNotEmpty).join(' · '),
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
          if (entry.matchups.isNotEmpty) ...[
            ContentWidth(child: GroupLabel(dayLabel(entry.day))),
            for (final matchup in entry.matchups)
              ContentWidth(
                child: MatchupCard(
                  matchup: matchup,
                  highlighted: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatchupDetailPage(
                        matchup: matchup,
                        subtitle:
                            'Fecha ${round.round} · ${dayLabel(entry.day)}',
                      ),
                    ),
                  ),
                ),
              ),
          ],

        if (onOpenFixture != null)
          ContentWidth(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
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
