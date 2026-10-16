import 'package:flutter/material.dart';
import '../models/standing.dart';
import '../services/standings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';

class StandingsPage extends StatefulWidget {
  const StandingsPage({super.key});

  @override
  State<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  Future<List<Standing>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<Standing>> _load() {
    return StandingsService.loadStandings(DefaultAssetBundle.of(context));
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<List<Standing>>(
      future: _future!,
      onRetry: _retry,
      builder: (context, standings) {
        if (standings.isEmpty) {
          return const EmptyView(
            icon: Icons.emoji_events_outlined,
            message: 'La tabla de posiciones aún no está disponible.',
          );
        }

        return ListView(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.xl,
          ),
          children: [
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
