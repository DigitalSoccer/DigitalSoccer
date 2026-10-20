import 'package:flutter/material.dart';

import '../models/player.dart';
import '../theme/app_theme.dart';
import 'app_components.dart';

/// Tabla de jugadores de un plantel: N° · Jugador · PJ · G · tarjetas.
class SquadTable extends StatelessWidget {
  final List<Player> players;

  const SquadTable({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Header(),
        for (final player in players) _PlayerRow(player: player),
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
      color: context.colors.background,
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
          stat(DisciplineCard(color: context.colors.cardYellow)),
          stat(DisciplineCard(color: context.colors.cardRed)),
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
              color: strong ? context.colors.primary : context.colors.text,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.border)),
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
                  color: context.colors.textMuted,
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

class SquadLegend extends StatelessWidget {
  const SquadLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: context.colors.textMuted,
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
              DisciplineCard(color: context.colors.cardYellow),
              Text(' amarillas', style: style),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DisciplineCard(color: context.colors.cardRed),
              Text(' rojas', style: style),
            ],
          ),
        ],
      ),
    );
  }
}
