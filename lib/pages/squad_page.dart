import 'package:flutter/material.dart';

import '../models/club.dart';
import '../models/player.dart';
import '../services/squad_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';

/// Plantel de un club: una pestaña por serie con la tabla de jugadores
/// (partidos jugados, goles y tarjetas).
class SquadPage extends StatefulWidget {
  final Club club;

  /// Series en que juega el club, ya ordenadas.
  final List<String> categories;

  final String initialCategory;

  const SquadPage({
    super.key,
    required this.club,
    required this.categories,
    required this.initialCategory,
  });

  @override
  State<SquadPage> createState() => _SquadPageState();
}

class _SquadPageState extends State<SquadPage> {
  Future<List<Squad>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<Squad>> _load() {
    return SquadService.loadSquads(DefaultAssetBundle.of(context));
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.categories.indexOf(widget.initialCategory);

    return DefaultTabController(
      length: widget.categories.length,
      initialIndex: initial < 0 ? 0 : initial,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Plantel · ${widget.club.name}'),
        ),
        body: Column(
          children: [
            ContentWidth(
              child: TabBar(
                isScrollable: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                tabs: [
                  for (final category in widget.categories)
                    Tab(text: category),
                ],
              ),
            ),
            Expanded(
              child: AsyncBody<List<Squad>>(
                future: _future!,
                onRetry: _retry,
                builder: (context, squads) => TabBarView(
                  children: [
                    for (final category in widget.categories)
                      _SquadTab(
                        category: category,
                        players: SquadService.playersOf(
                          squads,
                          widget.club.id,
                          category,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquadTab extends StatelessWidget {
  final String category;
  final List<Player> players;

  const _SquadTab({
    required this.category,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return EmptyView(
        icon: Icons.groups_outlined,
        message: 'El plantel de $category aún no está disponible.',
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
                const _Header(),
                for (final player in players) _PlayerRow(player: player),
              ],
            ),
          ),
        ),
        const ContentWidth(child: _Legend()),
      ],
    );
  }
}

const double _numberWidth = 32;
const double _statWidth = 36;

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
        );

    Widget stat(Widget child) => SizedBox(
          width: _statWidth,
          child: Center(child: child),
        );

    return Container(
      color: AppColors.surfaceLow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(width: _numberWidth, child: Text('N°', style: style)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text('JUGADOR', style: style)),
          stat(Text('PJ', style: style)),
          stat(Text('G', style: style)),
          stat(const DisciplineCard(color: AppColors.cardYellow)),
          stat(const DisciplineCard(color: AppColors.cardRed)),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final Player player;

  const _PlayerRow({required this.player});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stats = player.stats;

    Widget stat(int value, {bool strong = false}) => SizedBox(
          width: _statWidth,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              color: strong ? AppColors.primary : AppColors.text,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            SizedBox(
              width: _numberWidth,
              child: Text(
                player.number == null ? '–' : '${player.number}',
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                player.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall,
              ),
            ),
            stat(stats.played),
            stat(stats.goals, strong: true),
            stat(stats.yellowCards),
            stat(stats.redCards),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textMuted,
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('PJ: partidos jugados', style: style),
          Text('G: goles', style: style),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DisciplineCard(color: AppColors.cardYellow),
              Text(' amarillas', style: style),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DisciplineCard(color: AppColors.cardRed),
              Text(' rojas', style: style),
            ],
          ),
        ],
      ),
    );
  }
}
