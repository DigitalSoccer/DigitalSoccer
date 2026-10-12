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
            ContentWidth(
              child: _RoundHeader(
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

            ContentWidth(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar club...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
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
                clubNames: {
                  for (final club in data.clubs) club.id: club.name,
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RoundHeader extends StatelessWidget {
  final FixtureRound round;
  final VoidCallback? onOlder;
  final VoidCallback? onNewer;

  const _RoundHeader({
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Fecha anterior',
            onPressed: onOlder,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'FECHA ${round.round}',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppColors.primary,
                  ),
                ),
                if (range.isNotEmpty)
                  Text(
                    range,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
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
                              ? Icons.description_outlined
                              : Icons.help_outline,
                          size: 14,
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
          IconButton(
            tooltip: 'Fecha siguiente',
            onPressed: onNewer,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
