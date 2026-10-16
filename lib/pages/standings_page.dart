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
  final List<Standing> general;
  final Map<String, List<Standing>> bySeries;

  /// Series que aparecen en el fixture, de menor a mayor.
  final List<String> categories;

  _StandingsData(this.general, this.bySeries, this.categories);
}

class _StandingsPageState extends State<StandingsPage> {
  Future<_StandingsData>? _future;

  /// Serie elegida en el menú; `null` = tabla general.
  String? _category;

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

    final results = await Future.wait([
      StandingsService.loadStandings(bundle),
      optional(
        StandingsService.loadSeriesStandings(bundle),
        <String, List<Standing>>{},
      ),
      optional(DataService.loadRounds(bundle), <FixtureRound>[]),
    ]);

    final bySeries = results[1] as Map<String, List<Standing>>;
    final rounds = results[2] as List<FixtureRound>;

    return _StandingsData(
      results[0] as List<Standing>,
      bySeries,
      sortSeries([
        for (final round in rounds)
          for (final day in round.days)
            for (final field in day.fields)
              for (final match in field.matches) match.category,
        // Una serie con tabla cargada aparece aunque no esté en el fixture.
        ...bySeries.keys,
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
        final category = _category;
        final standings = category == null
            ? data.general
            : data.bySeries[category] ?? const <Standing>[];

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
                child: DropdownButtonFormField<String?>(
                  initialValue: category,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Tabla',
                    prefixIcon: Icon(Icons.emoji_events_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tabla general'),
                    ),
                    for (final c in data.categories)
                      DropdownMenuItem<String?>(
                        value: c,
                        child: Text('Serie $c'),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _category = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            if (standings.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: EmptyView(
                  icon: Icons.emoji_events_outlined,
                  message: category == null
                      ? 'La tabla de posiciones aún no está disponible.'
                      : 'La tabla de $category aún no está disponible.',
                ),
              )
            else
              ContentWidth(
                child: Card(
                  child: Column(
                    children: [
                      const _StandingsHeader(),
                      for (var i = 0; i < standings.length; i++)
                        _StandingRow(
                          position: i + 1,
                          standing: standings[i],
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
