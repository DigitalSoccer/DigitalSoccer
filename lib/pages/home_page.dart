import 'package:flutter/material.dart';

import '../models/club.dart';
import '../models/fixture_round.dart';
import '../models/match.dart';
import '../services/club_data_service.dart';
import '../services/club_service.dart';
import '../services/data_service.dart';
import '../services/override_service.dart';
import '../theme/app_theme.dart';
import '../utils/fecha_format.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';
import '../widgets/matchup_card.dart';
import '../widgets/search_field.dart';
import 'matchup_detail_page.dart';

/// Pestaña Fixture (`docs/diseno.md` 6.3): buscador, selector de fecha,
/// "Solo mis partidos", el club libre y los cruces agrupados por día y
/// ordenados por hora.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomeData {
  final List<FixtureRound> rounds;
  final List<Club> clubs;
  final String? favoriteClubId;

  _HomeData(this.rounds, this.clubs, this.favoriteClubId);
}

class _HomePageState extends State<HomePage> {
  String _query = '';
  bool _onlyMine = false;

  /// Posición en la lista de fechas (0 = la más reciente).
  int _roundIndex = 0;

  // Se guarda para no recargar los JSON en cada tecla del buscador.
  Future<_HomeData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_HomeData> _load() async {
    final bundle = DefaultAssetBundle.of(context);

    final results = await Future.wait([
      DataService.loadRounds(bundle),
      ClubDataService.loadClubs(bundle),
    ]);

    final clubs = results[1] as List<Club>;

    return _HomeData(
      results[0] as List<FixtureRound>,
      clubs,
      await ClubService.getFavoriteClubId(clubs),
    );
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  // Los filtros aplican a todas las series de un cruce por igual, así que
  // cada tarjeta conserva el cruce completo.
  bool _matchesFilter(Match match, String? myClubId) {
    if (_onlyMine && myClubId != null && !match.involves(myClubId)) {
      return false;
    }

    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;

    return match.home.toLowerCase().contains(query) ||
        match.away.toLowerCase().contains(query);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AsyncBody<_HomeData>(
        future: _future!,
        onRetry: _retry,
        builder: (context, data) {
          final myClubId = data.favoriteClubId;
          final names = {for (final club in data.clubs) club.id: club.name};

          final children = <Widget>[
            ContentWidth(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.lg,
                  AppSpacing.screen,
                  AppSpacing.md,
                ),
                child: Semantics(
                  header: true,
                  child: Text(
                    'Fixture',
                    style: AppText.display(context, size: 36),
                  ),
                ),
              ),
            ),
            ContentWidth(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                ),
                child: SearchField(
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            ),
          ];

          if (data.rounds.isEmpty) {
            children.add(
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.xl),
                child: EmptyView(
                  icon: Icons.event_busy,
                  message: 'Aún no hay fechas programadas.',
                ),
              ),
            );
            return ListView(children: children);
          }

          final index = _roundIndex.clamp(0, data.rounds.length - 1);
          final round = data.rounds[index];

          children.add(
            ContentWidth(
              child: _RoundSelector(
                round: round,
                // La lista va de la más reciente a la más antigua.
                onOlder: index < data.rounds.length - 1
                    ? () => setState(() => _roundIndex = index + 1)
                    : null,
                onNewer: index > 0
                    ? () => setState(() => _roundIndex = index - 1)
                    : null,
              ),
            ),
          );

          if (myClubId != null) {
            children.add(
              ContentWidth(
                child: _OnlyMineSwitch(
                  value: _onlyMine,
                  onChanged: (value) => setState(() => _onlyMine = value),
                ),
              ),
            );
          }

          final byes = {
            for (final day in round.days)
              for (final id in day.byeClubIds) names[id] ?? id,
          }.toList();

          if (byes.isNotEmpty) {
            children.add(ContentWidth(child: _ByeCard(names: byes)));
          }

          var shown = 0;

          for (final day in round.days) {
            final matchups = Matchup.fromDay(
              day,
              map: OverrideService.apply,
              where: (m) => _matchesFilter(m, myClubId),
            );
            if (matchups.isEmpty) continue;
            shown += matchups.length;

            final subtitle = 'Fecha ${round.round} · ${dayLabel(day)}';

            children.add(
              ContentWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.md,
                    AppSpacing.screen,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    dayLabel(day).toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: context.colors.textMuted,
                    ),
                  ),
                ),
              ),
            );

            for (final matchup in matchups) {
              children.add(
                ContentWidth(
                  child: MatchupCard(
                    matchup: matchup,
                    myClubId: myClubId,
                    highlighted:
                        myClubId != null && matchup.involves(myClubId),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchupDetailPage(
                          matchup: matchup,
                          subtitle: subtitle,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }

          if (shown == 0) {
            children.add(
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: EmptyView(
                  icon: Icons.event_busy,
                  message: _query.trim().isNotEmpty
                      ? 'Ningún partido coincide con "${_query.trim()}".'
                      : _onlyMine
                          ? 'Tu equipo no juega en la fecha ${round.round}.'
                          : 'No hay partidos programados.',
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: children,
          );
        },
      ),
    );
  }
}

/// Selector de fecha: flechas a los lados y, al centro, el número de fecha,
/// el rango de días y el origen de los datos (al tocarlo se explica).
class _RoundSelector extends StatelessWidget {
  final FixtureRound round;
  final VoidCallback? onOlder;
  final VoidCallback? onNewer;

  const _RoundSelector({
    required this.round,
    required this.onOlder,
    required this.onNewer,
  });

  void _showSource(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Origen de los datos'),
        content: Text(
          round.source ??
              'El origen de esta fecha no está verificado. '
                  'Puede no coincidir con la programación oficial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final range = roundDateRange(round);
    final verified = round.source != null;

    Widget arrow(IconData icon, String tooltip, VoidCallback? onPressed) =>
        IconButton(
          icon: Icon(icon),
          tooltip: tooltip,
          onPressed: onPressed,
          color: c.text,
          disabledColor: c.handle,
          style: IconButton.styleFrom(fixedSize: const Size(48, 48)),
        );

    return SurfaceCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        0,
      ),
      radius: 14,
      shadow: const [],
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          arrow(Icons.chevron_left_rounded, 'Fecha anterior', onOlder),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => _showSource(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  children: [
                    Text(
                      'Fecha ${round.round}',
                      style: AppText.display(context, size: 26),
                    ),
                    if (range.isNotEmpty)
                      Text(
                        range,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: c.textMuted),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          verified
                              ? Icons.verified_outlined
                              : Icons.help_outline_rounded,
                          size: 12,
                          color: c.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            verified
                                ? 'Fuente: planilla de la asociación'
                                : 'Fuente sin verificar',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: c.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          arrow(Icons.chevron_right_rounded, 'Fecha siguiente', onNewer),
        ],
      ),
    );
  }
}

class _OnlyMineSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _OnlyMineSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.xs,
        AppSpacing.screen,
        0,
      ),
      child: MergeSemantics(
        child: InkWell(
          onTap: () => onChanged(!value),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Solo mis partidos',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.colors.text,
                    ),
                  ),
                ),
                Switch(value: value, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Club(es) libres de la fecha: con 17 clubes, uno no juega cada fecha.
class _ByeCard extends StatelessWidget {
  final List<String> names;

  const _ByeCard({required this.names});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.xs,
        AppSpacing.screen,
        AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available_outlined, color: c.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Libre: ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: names.join(', ')),
                    ],
                  ),
                  style: TextStyle(fontSize: 14, height: 1.35, color: c.text),
                ),
                Text(
                  names.length == 1
                      ? 'No juega en esta fecha'
                      : 'No juegan en esta fecha',
                  style: TextStyle(fontSize: 13, color: c.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
