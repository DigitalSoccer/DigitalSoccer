import 'package:flutter/material.dart';

import '../models/match.dart';
import '../theme/app_theme.dart';
import 'app_components.dart';

/// Tarjeta de un cruce (formato de la maqueta de Inicio, usado en toda la
/// app): día y número de fecha arriba, los dos equipos con escudo y la hora
/// al centro; abajo, cancha y series. Al tocarla se abre el detalle.
class MatchupCard extends StatelessWidget {
  final Matchup matchup;

  /// Cruce de Mi Club: borde rojo e insignia "MI CLUB".
  final bool highlighted;

  final VoidCallback onTap;

  /// Encabezado opcional, p. ej. "Sábado 10 oct" y "FECHA 21".
  final String? dayLabel;
  final String? roundLabel;

  const MatchupCard({
    super.key,
    required this.matchup,
    required this.highlighted,
    required this.onTap,
    this.dayLabel,
    this.roundLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final showHeader = dayLabel != null || roundLabel != null || highlighted;

    Widget team(String name, String clubId) => Expanded(
          child: Column(
            children: [
              // Escudo genérico: no representa el escudo oficial del club.
              ClubCrest(size: 36, clubId: clubId),
              SizedBox(height: AppSpacing.xs),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

    return SurfaceCard(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      shadow: AppShadows.md,
      borderColor: highlighted ? context.colors.primary : null,
      onTap: onTap,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          if (showHeader) ...[
            Row(
              children: [
                Expanded(
                  child: Text(dayLabel ?? '', style: textTheme.titleMedium),
                ),
                if (highlighted) ...[
                  const TagChip.myClub(),
                  if (roundLabel != null) const SizedBox(width: AppSpacing.sm),
                ],
                if (roundLabel != null)
                  Text(
                    roundLabel!,
                    style: AppText.eyebrow(context).copyWith(color: context.colors.primary),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              team(matchup.home, matchup.homeId),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                child: _Kickoff(matchup: matchup),
              ),
              team(matchup.away, matchup.awayId),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            matchup.fieldNames.join(' · '),
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: context.colors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            matchup.categories.join(' · '),
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: context.colors.text,
            fontFeatures: AppText.tabular,
          ),
        ),
        const SizedBox(height: 2),
        if (notable != null)
          MatchStatusBadge(status: notable)
        else
          Text(
            count == 1 ? '1 partido' : '$count partidos',
            style: AppText.eyebrow(context),
          ),
      ],
    );
  }
}
