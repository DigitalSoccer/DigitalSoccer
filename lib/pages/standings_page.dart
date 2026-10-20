import 'package:flutter/material.dart';

import '../models/club.dart';
import '../models/standing.dart';
import '../services/club_data_service.dart';
import '../services/club_service.dart';
import '../services/standings_catalog.dart';
import '../services/standings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';
import '../widgets/serie_chips.dart';
import 'club_detail_page.dart';

/// Tabla de posiciones (`docs/diseno.md` 6.4): chips de serie y columnas
/// #, Club y Pts, que es lo que entrega la planilla actual.
class StandingsPage extends StatefulWidget {
  const StandingsPage({super.key});

  @override
  State<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsData {
  final StandingsCatalog catalog;

  /// Club favorito (mi equipo), para resaltar su fila.
  final String? favoriteClubId;

  _StandingsData(this.catalog, this.favoriteClubId);
}

class _StandingsPageState extends State<StandingsPage> {
  Future<_StandingsData>? _future;

  /// Tabla elegida con los chips (compartida con Inicio).
  String? _tableKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_StandingsData> _load() async {
    final bundle = DefaultAssetBundle.of(context);

    // Los clubes solo sirven para resaltar mi equipo: si fallan, se muestra
    // igual la tabla. Se esperan juntos para no dejar errores sin capturar.
    final results = await Future.wait<Object>([
      StandingsCatalog.load(bundle),
      ClubDataService.loadClubs(bundle).catchError((Object e) {
        debugPrint('Clubes no disponibles para la tabla: $e');
        return const <Club>[];
      }),
    ]);

    _tableKey = await StandingsCatalog.getSelectedKey();

    return _StandingsData(
      results[0] as StandingsCatalog,
      await ClubService.getFavoriteClubId(results[1] as List<Club>),
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

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SafeArea(
      bottom: false,
      child: AsyncBody<_StandingsData>(
        future: _future!,
        onRetry: _retry,
        builder: (context, data) {
          final catalog = data.catalog;
          final option = catalog.byKey(_tableKey);
          final standings = option.standings;

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              ContentWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.lg,
                    AppSpacing.screen,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Tabla de posiciones',
                          style: AppText.display(context, size: 36),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Campeonato 2026 · puntos acumulados',
                        style: TextStyle(fontSize: 14, color: c.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              ContentWidth(
                child: PillChips(
                  options: [for (final o in catalog.options) o.label],
                  selected: option.label,
                  onSelected: (label) => _select(
                    catalog.options.firstWhere((o) => o.label == label).key,
                  ),
                ),
              ),
              if (standings.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xl),
                  child: EmptyView(
                    icon: Icons.leaderboard_outlined,
                    message: 'La tabla de posiciones aún no está disponible.',
                  ),
                )
              else
                ContentWidth(
                  child: SurfaceCard(
                    margin: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      14,
                      AppSpacing.screen,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _StandingsHeader(),
                        for (final standing in standings)
                          _StandingRow(
                            position: StandingsService.rankOf(
                              standings,
                              standing,
                            ),
                            standing: standing,
                            isMine: standing.clubId == data.favoriteClubId,
                          ),
                      ],
                    ),
                  ),
                ),
              ContentWidth(
                child: _Legend(
                  hasTeam: data.favoriteClubId != null,
                  source: [
                    if (catalog.source != null) 'Fuente: ${catalog.source}.',
                    if (catalog.note != null) catalog.note!,
                  ].join(' '),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Ancho de las columnas, igual en encabezado y filas.
const double _positionWidth = 24;
const double _pointsWidth = 48;
const double _sidePadding = 10;

class _StandingsHeader extends StatelessWidget {
  const _StandingsHeader();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: c.textMuted,
    );

    return Container(
      height: 32,
      color: c.surfaceMuted,
      padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
      child: Row(
        children: [
          SizedBox(
            width: _positionWidth,
            child: Tooltip(
              message: 'Posición',
              child: Text('#', style: style),
            ),
          ),
          Expanded(child: Text('CLUB', style: style)),
          SizedBox(
            width: _pointsWidth,
            child: Tooltip(
              message: 'Puntos',
              child: Text('PTS', textAlign: TextAlign.right, style: style),
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  final int position;
  final Standing standing;
  final bool isMine;

  const _StandingRow({
    required this.position,
    required this.standing,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final club = ClubsScope.clubOf(context, standing.clubId);

    return Material(
      color: isMine ? c.ownTeam : Colors.transparent,
      child: InkWell(
        onTap: club == null
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClubDetailPage(club: club),
                  ),
                ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.surfaceMuted)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: _positionWidth,
                child: Text(
                  '$position',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                    fontFeatures: AppText.tabular,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    ClubCrest(size: 24, clubId: standing.clubId),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        club?.name ?? standing.team,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.15,
                          fontWeight:
                              isMine ? FontWeight.w700 : FontWeight.w500,
                          color: c.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: _pointsWidth,
                child: Text(
                  '${standing.points}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                    fontFeatures: AppText.tabular,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Leyenda bajo la tabla y la fuente de los datos.
class _Legend extends StatelessWidget {
  final bool hasTeam;
  final String source;

  const _Legend({required this.hasTeam, required this.source});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = TextStyle(fontSize: 13, height: 1.4, color: c.textMuted);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (hasTeam) ...[
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: c.ownTeam,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: c.ownTeamBorder),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  hasTeam
                      ? 'Tu equipo. Toca un club para ver su ficha.'
                      : 'Toca un club para ver su ficha.',
                  style: style,
                ),
              ),
            ],
          ),
          if (source.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(source, style: style),
          ],
        ],
      ),
    );
  }
}
