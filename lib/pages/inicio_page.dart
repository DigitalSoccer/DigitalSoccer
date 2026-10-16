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
          : StandingsService.positionOf(
              results[2] as List<Standing>,
              club.id,
            ),
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
    final chosen = await showModalBottomSheet<Club>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                'Cambiar mi club',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: _ClubList(
                clubs: data.clubs,
                selectedId: data.club?.id,
                onSelected: (club) => Navigator.pop(context, club),
              ),
            ),
          ],
        ),
      ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Hero(
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.sports_soccer,
                  size: 36,
                  color: AppColors.onPrimary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '¡Bienvenido!',
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Elige tu club para ver sus partidos de la fecha y su '
                  'posición en la tabla.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _ClubList(clubs: clubs, onSelected: onSelected),
        ),
      ],
    );
  }
}

class _ClubList extends StatelessWidget {
  final List<Club> clubs;
  final String? selectedId;
  final ValueChanged<Club> onSelected;

  const _ClubList({
    required this.clubs,
    required this.onSelected,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    if (clubs.isEmpty) {
      return const EmptyView(
        icon: Icons.shield_outlined,
        message: 'No hay clubes registrados.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        final club = clubs[index];
        final selected = club.id == selectedId;

        return ContentWidth(
          child: Card(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: ListTile(
              leading: const ClubAvatar(),
              title: Text(
                club.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                club.field.isEmpty ? 'Cancha por definir' : club.field,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              trailing: Icon(
                selected ? Icons.check_circle : Icons.chevron_right,
                color: selected ? AppColors.primary : AppColors.outline,
              ),
              onTap: () => onSelected(club),
            ),
          ),
        );
      },
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
    final textTheme = Theme.of(context).textTheme;
    final round = data.round;
    final position = data.position;

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
        _Hero(
          child: ContentWidth(
            child: Row(
              children: [
                const ClubAvatar(size: 56),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MI CLUB',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        club.name,
                        style: textTheme.headlineSmall?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (club.field.isNotEmpty)
                        Text(
                          club.field,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryContainer,
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onChangeClub,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.onPrimary,
                  ),
                  child: const Text('Cambiar'),
                ),
              ],
            ),
          ),
        ),

        ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              0,
            ),
            child: position == null
                ? Text(
                    'Sin información en la tabla de posiciones.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          label: 'Posición',
                          value: '${position.position}',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: StatTile(
                          label: 'Puntos',
                          value: '${position.standing.points}',
                        ),
                      ),
                    ],
                  ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Text(
                isBye
                    ? 'Libre en la fecha ${round.round}.'
                    : 'Sin partidos en la fecha ${round.round}.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),

        for (final entry in days)
          if (entry.matchups.isNotEmpty) ...[
            ContentWidth(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: Text(
                  dayLabel(entry.day),
                  style: textTheme.titleSmall,
                ),
              ),
            ),
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
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: OutlinedButton.icon(
                onPressed: onOpenFixture,
                icon: const Icon(Icons.sports_soccer_outlined),
                label: const Text('Ver fixture completo'),
              ),
            ),
          ),
      ],
    );
  }
}

/// Bloque superior azul, continuación de la barra de la app.
class _Hero extends StatelessWidget {
  final Widget child;

  const _Hero({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: child,
    );
  }
}
