import 'package:flutter/material.dart';
import '../models/club.dart';
import '../models/fixture_round.dart';
import '../models/series.dart';
import '../models/standing.dart';
import '../services/club_data_service.dart';
import '../services/club_service.dart';
import '../services/data_service.dart';
import '../services/standings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';

class StandingsPage extends StatefulWidget {
  const StandingsPage({super.key});

  @override
  State<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsData {
  final StandingsTable general;
  final SeriesTables tables;

  /// Series del fixture y de las tablas, de menor a mayor.
  final List<String> categories;

  /// Club favorito (Mi Club), para resaltar su fila.
  final String? favoriteClubId;

  _StandingsData(
    this.general,
    this.tables,
    this.categories,
    this.favoriteClubId,
  );
}

/// Opción del selector: la tabla general, un acumulado o una serie.
class _Choice {
  final String? total;
  final String? series;

  const _Choice.general() : total = null, series = null;
  const _Choice.total(String name) : total = name, series = null;
  const _Choice.series(String name) : total = null, series = name;

  String get label => total != null
      ? 'Acumulado ${total!.toLowerCase()}'
      : series != null
      ? 'Serie $series'
      : 'Tabla general';

  @override
  bool operator ==(Object other) =>
      other is _Choice && other.total == total && other.series == series;

  @override
  int get hashCode => Object.hash(total, series);
}

class _StandingsPageState extends State<StandingsPage> {
  Future<_StandingsData>? _future;

  _Choice _choice = const _Choice.general();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_StandingsData> _load() async {
    final bundle = DefaultAssetBundle.of(context);

    // Las tablas por serie, el fixture (que da la lista de series) y los
    // clubes son secundarios: si fallan, se muestra igual la tabla general.
    Future<T> optional<T>(Future<T> future, T fallback) =>
        future.catchError((Object e) {
          debugPrint('Dato opcional de la tabla no disponible: $e');
          return fallback;
        });

    // Se esperan juntas: así un error de la tabla general nunca queda sin
    // capturar mientras se espera a las demás.
    final results = await Future.wait<Object>([
      StandingsService.loadGeneralTable(bundle),
      optional<SeriesTables>(
        StandingsService.loadSeriesStandings(bundle),
        const SeriesTables(),
      ),
      optional<List<FixtureRound>>(DataService.loadRounds(bundle), const []),
      optional<List<Club>>(ClubDataService.loadClubs(bundle), const []),
    ]);

    final seriesTables = results[1] as SeriesTables;

    return _StandingsData(
      results[0] as StandingsTable,
      seriesTables,
      sortSeries([
        for (final round in results[2] as List<FixtureRound>)
          for (final day in round.days)
            for (final field in day.fields)
              for (final match in field.matches) match.category,
        // Una serie con tabla cargada aparece aunque no esté en el fixture.
        ...seriesTables.series.keys,
      ]),
      await ClubService.getFavoriteClubId(results[3] as List<Club>),
    );
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _pickTable(_StandingsData data, _Choice current) async {
    final picked = await showSelectionSheet<_Choice>(
      context: context,
      title: 'Elegir tabla',
      selected: current,
      sections: [
        SheetSection(
          title: 'General',
          options: [
            const SheetOption(_Choice.general(), 'Tabla general'),
            for (final name in data.tables.totals.keys)
              SheetOption(_Choice.total(name), _Choice.total(name).label),
          ],
        ),
        if (data.categories.isNotEmpty)
          SheetSection(
            title: 'Por serie',
            options: [
              for (final c in data.categories)
                SheetOption(_Choice.series(c), _Choice.series(c).label),
            ],
          ),
      ],
    );

    if (picked == null || !mounted) return;
    setState(() {
      _choice = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<_StandingsData>(
      future: _future!,
      onRetry: _retry,
      builder: (context, data) {
        final choices = [
          const _Choice.general(),
          for (final name in data.tables.totals.keys) _Choice.total(name),
          for (final c in data.categories) _Choice.series(c),
        ];

        final choice = choices.contains(_choice) ? _choice : choices.first;

        final standings = choice.total != null
            ? data.tables.totals[choice.total] ?? const <Standing>[]
            : choice.series != null
            ? data.tables.series[choice.series] ?? const <Standing>[]
            : data.general.standings;

        final textTheme = Theme.of(context).textTheme;

        return ListView(
          padding: const EdgeInsets.only(
            top: AppSpacing.lg,
            bottom: AppSpacing.xl,
          ),
          children: [
            ContentWidth(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SelectorField(
                  label: 'Tabla',
                  value: choice.label,
                  icon: Icons.leaderboard_outlined,
                  onTap: () => _pickTable(data, choice),
                ),
              ),
            ),

            if (data.general.source != null || data.general.note != null)
              ContentWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg + AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.info_outline,
                          size: 14,
                          color: context.colors.textMuted,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          [
                            if (data.general.source != null)
                              'Fuente: ${data.general.source}',
                            if (data.general.note != null) data.general.note!,
                          ].join(' '),
                          style: textTheme.bodySmall?.copyWith(
                            color: context.colors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.md),

            if (standings.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: EmptyView(
                  icon: Icons.leaderboard_outlined,
                  message: choice.series != null
                      ? 'La tabla de ${choice.series} aún no está disponible.'
                      : 'La tabla de posiciones aún no está disponible.',
                ),
              )
            else
              ContentWidth(
                child: SurfaceCard(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      const _StandingsHeader(),
                      for (final standing in standings)
                        _StandingRow(
                          position: StandingsService.rankOf(
                            standings,
                            standing,
                          ),
                          standing: standing,
                          isFavorite: standing.clubId == data.favoriteClubId,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// Ancho de las columnas, igual en encabezado y filas.
const double _positionWidth = 30;
const double _statWidth = 40;
const double _pointsWidth = 44;

/// Franja izquierda de cada fila: roja en Mi Club, transparente en el resto
/// (así todas las filas quedan alineadas).
const double _stripeWidth = 3;

class _StandingsHeader extends StatelessWidget {
  const _StandingsHeader();

  @override
  Widget build(BuildContext context) {
    Widget column(String label, double width, String tooltip) => SizedBox(
      width: width,
      child: Tooltip(
        message: tooltip,
        child: Text(label, textAlign: TextAlign.center, style: AppText.eyebrow(context)),
      ),
    );

    return Container(
      color: context.colors.background,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md + _stripeWidth,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          column('POS', _positionWidth, 'Posición'),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text('CLUB', style: AppText.eyebrow(context))),
          column('PJ', _statWidth, 'Partidos jugados'),
          column('DIF', _statWidth, 'Diferencia de goles'),
          column('PTS', _pointsWidth, 'Puntos'),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  final int position;
  final Standing standing;
  final bool isFavorite;

  const _StandingRow({
    required this.position,
    required this.standing,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Sobre el fondo rojo suave de Mi Club, el gris secundario más oscuro
    // mantiene el contraste.
    final statColor = isFavorite
        ? context.colors.textSecondary
        : context.colors.textMuted;

    Widget stat(String value) => SizedBox(
      width: _statWidth,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(
          color: statColor,
          fontFeatures: AppText.tabular,
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isFavorite ? context.colors.primarySoft : null,
        border: Border(
          top: BorderSide(color: context.colors.border),
          left: BorderSide(
            color: isFavorite ? context.colors.primaryBright : Colors.transparent,
            width: _stripeWidth,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            SizedBox(
              width: _positionWidth,
              child: PositionBadge(position: position),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Row(
                children: [
                  // Escudo genérico por ahora; aquí irá el de cada club.
                  ClubCrest(size: 22, clubId: standing.clubId),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      standing.team,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: isFavorite
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isFavorite) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: context.colors.favorite,
                      semanticLabel: 'Mi Club',
                    ),
                  ],
                ],
              ),
            ),
            stat(standing.played?.toString() ?? '–'),
            stat(formatGoalDifference(standing.goalDifference)),
            SizedBox(
              width: _pointsWidth,
              child: Text(
                '${standing.points}',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.colors.text,
                  fontFeatures: AppText.tabular,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
