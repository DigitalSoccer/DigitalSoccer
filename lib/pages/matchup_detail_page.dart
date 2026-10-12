import 'package:flutter/material.dart';

import '../models/match.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/match_row.dart';

/// Detalle de un cruce: los dos equipos y, por cancha, los horarios de cada
/// serie hacia abajo.
class MatchupDetailPage extends StatelessWidget {
  final Matchup matchup;

  /// Contexto mostrado arriba, p. ej. "Fecha 21 · Sábado 10 oct".
  final String subtitle;

  const MatchupDetailPage({
    super.key,
    required this.matchup,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final allNormal = matchup.entries.every(
      (e) => e.match.status == 'normal',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partido'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          ContentWidth(
            child: Card(
              margin: const EdgeInsets.all(AppSpacing.lg),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                        if (allNormal)
                          Text(
                            'Programado',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    MatchupScoreline(
                      matchup: matchup,
                      avatarSize: 64,
                      center: Text(
                        'vs',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          for (final field in matchup.fieldNames)
            ContentWidth(
              child: _FieldMatches(
                fieldName: field,
                entries: matchup.entries
                    .where((e) => e.fieldName == field)
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

/// Fila clásica de marcador: local a la izquierda, visita a la derecha y
/// [center] al medio (hora, "vs" o, a futuro, el resultado).
class MatchupScoreline extends StatelessWidget {
  final Matchup matchup;
  final Widget center;
  final double avatarSize;

  const MatchupScoreline({
    super.key,
    required this.matchup,
    required this.center,
    this.avatarSize = 44,
  });

  @override
  Widget build(BuildContext context) {
    Widget team(String name) {
      return Expanded(
        child: Column(
          children: [
            ClubAvatar(size: avatarSize),
            const SizedBox(height: AppSpacing.sm),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        team(matchup.home),
        Padding(
          padding: EdgeInsets.only(
            top: avatarSize * 0.15,
            left: AppSpacing.sm,
            right: AppSpacing.sm,
          ),
          child: center,
        ),
        team(matchup.away),
      ],
    );
  }
}

class _FieldMatches extends StatelessWidget {
  final String fieldName;
  final List<MatchupEntry> entries;

  const _FieldMatches({
    required this.fieldName,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.surfaceLow,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.stadium_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    fieldName,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  entries.length == 1
                      ? '1 partido'
                      : '${entries.length} partidos',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          for (final entry in entries)
            DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xs,
                ),
                child: MatchRow(
                  matchId: entry.match.id,
                  time: entry.match.time,
                  category: entry.match.category,
                  status: entry.match.status,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
