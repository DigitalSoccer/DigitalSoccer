import 'package:flutter/material.dart';

import '../models/match.dart';
import '../pages/matchup_detail_page.dart';
import '../theme/app_theme.dart';

/// Tarjeta clásica de un cruce: cancha arriba, equipos a los lados y la
/// hora del primer partido al centro. Al tocarla se abre el detalle.
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
    final count = matchup.entries.length;

    return Card(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      shape: highlighted
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: const BorderSide(color: AppColors.primary, width: 1.5),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.stadium_outlined,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      matchup.fieldNames.join(' · '),
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  if (highlighted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Text(
                        'MI CLUB',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              MatchupScoreline(
                matchup: matchup,
                center: Column(
                  children: [
                    Text(
                      matchup.firstTime,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      count == 1 ? '1 partido' : '$count partidos',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: AppSpacing.xl),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      matchup.categories.join(' · '),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

