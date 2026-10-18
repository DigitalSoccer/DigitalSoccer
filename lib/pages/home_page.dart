import 'package:flutter/material.dart';

import '../models/club.dart';
import '../models/fixture_round.dart';
import '../services/club_data_service.dart';
import '../services/club_service.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../utils/fecha_format.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';
import '../widgets/fixture_view.dart';

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
  String searchQuery = '';

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

  @override
  Widget build(BuildContext context) {
    return AsyncBody<_HomeData>(
      future: _future!,
      onRetry: _retry,
      builder: (context, data) {
        if (data.rounds.isEmpty) {
          return const EmptyView(
            icon: Icons.event_busy,
            message: 'Aún no hay fechas programadas.',
          );
        }

        final index = _roundIndex.clamp(0, data.rounds.length - 1);
        final round = data.rounds[index];

        return Column(
          children: [
            // Panel blanco superior: fecha y buscador. Las pestañas de día
            // (en FixtureView) continúan el mismo panel.
            ColoredBox(
              color: AppColors.surface,
              child: ContentWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xs,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      _RoundSelector(
                        round: round,
                        // La lista va de la más reciente a la más antigua.
                        onOlder: index < data.rounds.length - 1
                            ? () => setState(() => _roundIndex = index + 1)
                            : null,
                        onNewer: index > 0
                            ? () => setState(() => _roundIndex = index - 1)
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Buscar club...',
                          prefixIcon: Icon(Icons.search_rounded),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: FixtureView(
                // La clave reinicia pestañas y filtros al cambiar de fecha.
                key: ValueKey(round.round),
                matchDays: round.days,
                roundNumber: round.round,
                searchQuery: searchQuery,
                highlightClubId: data.favoriteClubId,
                clubNames: {for (final club in data.clubs) club.id: club.name},
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Selector de fecha: flechas a los lados y, al centro, el número de fecha,
/// el rango de días y el origen de los datos.
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
    final textTheme = Theme.of(context).textTheme;
    final range = roundDateRange(round);
    final verified = round.source != null;

    return Row(
      children: [
        CircleIconButton(
          icon: Icons.chevron_left_rounded,
          tooltip: 'Fecha anterior',
          onPressed: onOlder,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'FECHA ${round.round}',
                style: AppText.eyebrow.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              if (range.isNotEmpty)
                Text(
                  range,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: () => _showSource(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        verified
                            ? Icons.verified_outlined
                            : Icons.help_outline_rounded,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          verified
                              ? 'Fuente: planilla de la asociación'
                              : 'Fuente sin verificar',
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        CircleIconButton(
          icon: Icons.chevron_right_rounded,
          tooltip: 'Fecha siguiente',
          onPressed: onNewer,
        ),
      ],
    );
  }
}
