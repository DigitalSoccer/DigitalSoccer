import 'package:flutter/material.dart';
import '../models/fixture_round.dart';
import '../models/series.dart';
import '../models/standing.dart';
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

  _StandingsData(this.general, this.tables, this.categories);
}

/// Opción del menú: la tabla general, un acumulado o una serie.
class _Choice {
  final String? total;
  final String? series;

  const _Choice.general()
      : total = null,
        series = null;
  const _Choice.total(String name)
      : total = name,
        series = null;
  const _Choice.series(String name)
      : total = null,
        series = name;

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

    // Las tablas por serie y el fixture (que da la lista de series) son
    // secundarios: si fallan, se muestra igual la tabla general.
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
      optional<List<FixtureRound>>(
        DataService.loadRounds(bundle),
        const [],
      ),
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
    );
  }

  void _retry() {
    setState(() {
      _future = _load();
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
            top: AppSpacing.md,
            bottom: AppSpacing.xl,
          ),
          children: [
            ContentWidth(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: DropdownButtonFormField<_Choice>(
                  initialValue: choice,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Tabla',
                    prefixIcon: Icon(Icons.emoji_events_outlined),
                  ),
                  items: [
                    for (final c in choices)
                      DropdownMenuItem<_Choice>(
                        value: c,
                        child: Text(c.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _choice = value;
                    });
                  },
                ),
              ),
            ),

            if (data.general.source != null || data.general.note != null)
              ContentWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.textMuted,
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
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.sm),

            if (standings.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: EmptyView(
                  icon: Icons.emoji_events_outlined,
                  message: choice.series != null
                      ? 'La tabla de ${choice.series} aún no está disponible.'
                      : 'La tabla de posiciones aún no está disponible.',
                ),
              )
            else
              ContentWidth(
                child: Card(
                  child: Column(
                    children: [
                      const _StandingsHeader(),
                      for (final standing in standings)
                        _StandingRow(
                          position:
                              StandingsService.rankOf(standings, standing),
                          standing: standing,
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

// Ancho de las columnas numéricas, igual en encabezado y filas.
const double _statWidth = 40;
const double _pointsWidth = 44;

class _StandingsHeader extends StatelessWidget {
  const _StandingsHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
        );

    Widget column(String label, double width, String tooltip) => SizedBox(
          width: width,
          child: Tooltip(
            message: tooltip,
            child: Text(label, textAlign: TextAlign.center, style: style),
          ),
        );

    return Container(
      color: AppColors.surfaceLow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text('#', style: style)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text('CLUB', style: style)),
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

  const _StandingRow({
    required this.position,
    required this.standing,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget stat(String value) => SizedBox(
          width: _statWidth,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            PositionBadge(position: position),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                standing.team,
                style: textTheme.titleSmall,
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
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
