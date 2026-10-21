import 'package:flutter/material.dart';

import '../models/club.dart';
import '../models/fixture_round.dart';
import '../models/match.dart';
import '../models/standing.dart';
import '../services/club_data_service.dart';
import '../services/club_service.dart';
import '../services/data_service.dart';
import '../services/override_service.dart';
import '../services/standings_catalog.dart';
import '../services/standings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';
import '../widgets/serie_chips.dart';
import 'choose_team_page.dart';

/// Pestaña de inicio (`docs/diseno.md` 6.2). Sin club elegido, muestra
/// "Elegir equipo" (club y serie); con club, muestra su posición en la serie elegida, su
/// partido de la fecha, una mini tabla y las últimas noticias.
class InicioPage extends StatefulWidget {
  /// Abren otras pestañas y Ajustes (los provee la navegación principal).
  final VoidCallback? onOpenFixture;
  final VoidCallback? onOpenStandings;
  final VoidCallback? onOpenNews;
  final VoidCallback? onOpenSettings;

  const InicioPage({
    super.key,
    this.onOpenFixture,
    this.onOpenStandings,
    this.onOpenNews,
    this.onOpenSettings,
  });

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioData {
  final List<Club> clubs;
  final Club? club;
  final FixtureRound round;
  final StandingsCatalog catalog;

  _InicioData({
    required this.clubs,
    required this.club,
    required this.round,
    required this.catalog,
  });
}

class _InicioPageState extends State<InicioPage> {
  Future<_InicioData>? _future;

  /// Tabla elegida con los chips (compartida con la pestaña Tabla).
  String? _tableKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_InicioData> _load() async {
    final bundle = DefaultAssetBundle.of(context);

    final results = await Future.wait<Object>([
      ClubDataService.loadClubs(bundle),
      DataService.loadData(bundle),
      StandingsCatalog.load(bundle),
    ]);

    final clubs = results[0] as List<Club>;
    final club = ClubDataService.findById(
      clubs,
      await ClubService.getFavoriteClubId(clubs),
    );
    _tableKey = await StandingsCatalog.getSelectedKey();

    return _InicioData(
      clubs: clubs,
      club: club,
      round: results[1] as FixtureRound,
      catalog: results[2] as StandingsCatalog,
    );
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  void _selectTable(String key) {
    setState(() {
      _tableKey = key;
    });
    StandingsCatalog.setSelectedKey(key);
  }

  Future<void> _changeTeam() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ChooseTeamPage()),
    );
    if (saved == true && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AsyncBody<_InicioData>(
        future: _future!,
        onRetry: _reload,
        builder: (context, data) {
          final club = data.club;

          if (club == null) {
            return ChooseTeamPage(
              embedded: true,
              onSaved: _reload,
              onJustLook: widget.onOpenFixture,
            );
          }

          final option = data.catalog.byKey(_tableKey);

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              ContentWidth(
                child: _Header(
                  club: club,
                  onOpenSettings: widget.onOpenSettings,
                  onChangeClub: _changeTeam,
                ),
              ),
              ContentWidth(
                child: PillChips(
                  options: [for (final o in data.catalog.options) o.label],
                  selected: option.label,
                  onSelected: (label) => _selectTable(
                    data.catalog.options.firstWhere((o) => o.label == label).key,
                  ),
                ),
              ),
              ContentWidth(
                child: _PositionCard(option: option, clubId: club.id),
              ),
              ContentWidth(
                child: _RoundMatchCard(
                  round: data.round,
                  club: club,
                  series: StandingsCatalog.seriesOf(option.key),
                  onTap: widget.onOpenFixture,
                ),
              ),
              ContentWidth(
                child: _MiniTable(
                  option: option,
                  clubId: club.id,
                  onOpenStandings: widget.onOpenStandings,
                ),
              ),
              ContentWidth(child: _LatestNews(onOpenNews: widget.onOpenNews)),
            ],
          );
        },
      ),
    );
  }
}

/// Botón redondo de 44 con borde (ajustes, cambiar de equipo).
class _RoundButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        backgroundColor: c.surface,
        foregroundColor: c.text,
        side: BorderSide(color: c.border),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Club club;
  final VoidCallback? onOpenSettings;
  final VoidCallback onChangeClub;

  const _Header({
    required this.club,
    required this.onOpenSettings,
    required this.onChangeClub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.lg,
        AppSpacing.screen,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          ClubAvatar(size: 48, clubId: club.id),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.display(context, size: 28).copyWith(height: 1),
                ),
                const SizedBox(height: 3),
                Text(
                  'ANFA Caupolicán',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _RoundButton(
            icon: Icons.tune_rounded,
            tooltip: 'Ajustes y apariencia',
            onPressed: onOpenSettings,
          ),
          const SizedBox(width: AppSpacing.sm),
          _RoundButton(
            icon: Icons.swap_horiz_rounded,
            tooltip: 'Cambiar de equipo',
            onPressed: onChangeClub,
          ),
        ],
      ),
    );
  }
}

String _points(int n) => n == 1 ? '1 punto' : '$n puntos';

/// Tarjeta roja de posición: puesto en amarillo, puntos y distancia al
/// líder y al 3° (se calculan solo con los puntos).
class _PositionCard extends StatelessWidget {
  final TableOption option;
  final String clubId;

  const _PositionCard({required this.option, required this.clubId});

  /// Las dos líneas bajo la posición.
  static List<String> gaps(List<Standing> standings, Standing mine) {
    final rank = StandingsService.rankOf(standings, mine);
    final leader = standings.first.points;
    final lines = <String>[];

    if (rank == 1) {
      final tied = standings.where((s) => s.points == leader).length > 1;
      lines.add(tied ? 'Comparte el 1° lugar' : 'Lidera la tabla');
    } else {
      lines.add('A ${_points(leader - mine.points)} del líder');
    }

    if (rank > 3 && standings.length >= 3) {
      lines.add('A ${_points(standings[2].points - mine.points)} del 3°');
    } else {
      final below = standings.where((s) => s.points < mine.points);
      if (below.isNotEmpty) {
        final next = below.first;
        lines.add(
          '${_points(mine.points - next.points)} sobre el '
          '${StandingsService.rankOf(standings, next)}°',
        );
      }
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final standings = option.standings;
    final position = StandingsService.positionOf(standings, clubId);

    final labelStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: c.onPrimaryMuted,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.lg,
        AppSpacing.screen,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.screen),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: position == null
          ? Text(
              'Tu equipo no aparece en la tabla ${option.label}.',
              style: TextStyle(fontSize: 15, color: c.onPrimary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'POSICIÓN · ${option.label.toUpperCase()}',
                  style: labelStyle,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(
                            '${position.position}°',
                            style: AppText.display(
                              context,
                              size: 76,
                              color: c.accent,
                            ).copyWith(height: 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'de ${standings.length} equipos',
                              style: TextStyle(
                                fontSize: 15,
                                color: c.onPrimaryMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${position.standing.points}',
                          style: AppText.display(
                            context,
                            size: 48,
                            color: c.onPrimary,
                          ).copyWith(height: 1),
                        ),
                        Text(
                          'puntos',
                          style: TextStyle(
                            fontSize: 13,
                            color: c.onPrimaryMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: c.onPrimaryLine)),
                  ),
                  child: Wrap(
                    spacing: AppSpacing.screen,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final line in gaps(standings, position.standing))
                        Text(
                          line,
                          style: TextStyle(fontSize: 14, color: c.onPrimary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Una línea con el partido del club en la fecha cargada; lleva al Fixture.
class _RoundMatchCard extends StatelessWidget {
  final FixtureRound round;
  final Club club;

  /// Serie elegida en los chips, o `null` para todas.
  final String? series;
  final VoidCallback? onTap;

  const _RoundMatchCard({
    required this.round,
    required this.club,
    required this.series,
    required this.onTap,
  });

  String _summary() {
    for (final day in round.days) {
      final matchups = Matchup.fromDay(
        day,
        map: OverrideService.apply,
        where: (m) =>
            m.involves(club.id) && (series == null || m.category == series),
      );
      if (matchups.isEmpty) continue;

      final matchup = matchups.first;
      final rival = matchup.homeId == club.id ? matchup.away : matchup.home;
      final dayName = day.day.length > 3 ? day.day.substring(0, 3) : day.day;
      final when = day.date == null ? dayName : '$dayName ${day.date!.day}';

      return 'vs $rival · $when, ${matchup.firstTime}';
    }

    final isBye = round.days.any((d) => d.byeClubIds.contains(club.id));
    if (isBye) return 'Libre en esta fecha';
    return series == null
        ? 'Sin partidos en esta fecha'
        : 'Sin partido de $series en esta fecha';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SurfaceCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        0,
      ),
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month_outlined, color: c.primaryText),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TU PARTIDO · FECHA ${round.round}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: c.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _summary(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: c.text,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.outline),
        ],
      ),
    );
  }
}

/// Encabezado de sección con título en Barlow Condensed y un enlace.
class _SectionLink extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback? onTap;
  final double size;

  const _SectionLink({
    required this.title,
    required this.action,
    required this.onTap,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppText.display(context, size: size))),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: context.colors.primaryText,
              minimumSize: const Size(44, 44),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              textStyle: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(action),
          ),
      ],
    );
  }
}

/// Tres filas de la tabla: el equipo del usuario al medio, con el de
/// arriba y el de abajo. Con empates, comparten número de posición.
class _MiniTable extends StatelessWidget {
  final TableOption option;
  final String clubId;
  final VoidCallback? onOpenStandings;

  const _MiniTable({
    required this.option,
    required this.clubId,
    required this.onOpenStandings,
  });

  static const int rows = 3;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final standings = option.standings;
    final index = standings.indexWhere((s) => s.clubId == clubId);

    var start = index < 0 ? 0 : index - 1;
    start = start.clamp(0, (standings.length - rows).clamp(0, standings.length));
    final visible = standings.skip(start).take(rows);

    final headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: c.textMuted,
    );

    return SurfaceCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.lg,
        AppSpacing.screen,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 6),
            child: _SectionLink(
              title: 'Tabla · ${option.label}',
              action: 'Ver completa',
              onTap: onOpenStandings,
              size: 22,
            ),
          ),
          Container(
            height: 28,
            color: c.background,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                SizedBox(width: 26, child: Text('#', style: headerStyle)),
                Expanded(child: Text('CLUB', style: headerStyle)),
                SizedBox(
                  width: 44,
                  child: Text(
                    'PTS',
                    textAlign: TextAlign.right,
                    style: headerStyle,
                  ),
                ),
              ],
            ),
          ),
          for (final standing in visible)
            _MiniRow(
              rank: StandingsService.rankOf(standings, standing),
              standing: standing,
              isMine: standing.clubId == clubId,
            ),
        ],
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  final int rank;
  final Standing standing;
  final bool isMine;

  const _MiniRow({
    required this.rank,
    required this.standing,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final name = ClubsScope.clubOf(context, standing.clubId)?.name ??
        standing.team;

    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isMine ? c.ownTeam : null,
        border: Border(top: BorderSide(color: c.surfaceMuted)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: c.text,
                fontFeatures: AppText.tabular,
              ),
            ),
          ),
          ClubCrest(size: 28, clubId: standing.clubId),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isMine ? FontWeight.w700 : FontWeight.w500,
                color: c.text,
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '${standing.points}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.text,
                fontFeatures: AppText.tabular,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Últimas noticias: aún no hay fuente de noticias, así que se muestra el
/// estado vacío con el enlace a la pestaña Noticias.
class _LatestNews extends StatelessWidget {
  final VoidCallback? onOpenNews;

  const _LatestNews({required this.onOpenNews});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.lg,
        AppSpacing.screen,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLink(
            title: 'Últimas noticias',
            action: 'Ver todas',
            onTap: onOpenNews,
          ),
          SurfaceCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.newspaper_outlined, color: c.textMuted),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Aún no hay noticias publicadas.',
                    style: TextStyle(fontSize: 14, color: c.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
