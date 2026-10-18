import 'package:flutter/material.dart';

import '../models/match.dart';
import '../pages/matchup_detail_page.dart';
import '../theme/app_theme.dart';
import 'app_components.dart';

/// Tarjeta de un cruce en tres columnas: local, hora/estado y visita. Arriba
/// la cancha y abajo un chip con las series en juego. Al tocarla se abre el
/// detalle.
class MatchupCard extends StatelessWidget {
  final Matchup matchup;
  final bool highlighted;
  final VoidCallback onTap;

  const MatchupCard({
    super.key,
    required this.matchup,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SurfaceCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      borderColor: highlighted ? AppColors.primary : null,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.outline,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  matchup.fieldNames.join(' · '),
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (highlighted) const TagChip.myClub(),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          MatchupScoreline(
            matchup: matchup,
            center: _Kickoff(matchup: matchup),
          ),

          const SizedBox(height: AppSpacing.md),

          TagChip(label: matchup.categories.join(' · ')),
        ],
      ),
    );
  }
}

/// Columna central: hora del primer partido y estado (cantidad de partidos,
/// o "Suspendido"/"Reprogramado" si corresponde).
class _Kickoff extends StatelessWidget {
  final Matchup matchup;

  const _Kickoff({required this.matchup});

  @override
  Widget build(BuildContext context) {
    final count = matchup.entries.length;
    final notable = matchup.entries
        .map((e) => e.match.status)
        .where(MatchStatusBadge.isNotable)
        .firstOrNull;

    return Column(
      children: [
        Text(
          matchup.firstTime,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            fontFeatures: AppText.tabular,
          ),
        ),
        const SizedBox(height: 2),
        if (notable != null)
          MatchStatusBadge(status: notable)
        else
          Text(
            count == 1 ? '1 partido' : '$count partidos',
            style: AppText.eyebrow,
          ),
      ],
    );
  }
}
