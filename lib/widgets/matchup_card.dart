import 'package:flutter/material.dart';

import '../models/match.dart';
import '../theme/app_theme.dart';
import 'app_components.dart';

/// Tarjeta de un cruce (`MatchCard` en `docs/diseno.md` 5): hora a la
/// izquierda, separador, los dos equipos con escudo y, abajo, la cancha y
/// una etiqueta de estado. Un cruce agrupa todas las series de un mismo
/// local contra un mismo visitante; al tocarlo se abre el detalle.
class MatchupCard extends StatelessWidget {
  final Matchup matchup;

  /// Cruce de mi equipo: fondo amarillo y etiqueta "Tu equipo".
  final bool highlighted;

  final VoidCallback onTap;

  /// Encabezado opcional, p. ej. "Sábado 10 oct" y "FECHA 21" (se usa
  /// fuera del Fixture, donde la tarjeta no está bajo el título del día).
  final String? dayLabel;
  final String? roundLabel;

  /// Club propio, que va en negrita.
  final String? myClubId;

  const MatchupCard({
    super.key,
    required this.matchup,
    required this.highlighted,
    required this.onTap,
    this.dayLabel,
    this.roundLabel,
    this.myClubId,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final header = [dayLabel, roundLabel].whereType<String>().join(' · ');

    Widget team(String name, String clubId) => Row(
          children: [
            ClubCrest(size: 26, clubId: clubId),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      clubId == myClubId ? FontWeight.w700 : FontWeight.w600,
                  color: c.text,
                ),
              ),
            ),
          ],
        );

    return SurfaceCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        10,
      ),
      radius: 14,
      shadow: const [],
      color: highlighted ? c.ownTeam : null,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header.isNotEmpty) ...[
            Text(header.toUpperCase(), style: AppText.eyebrow(context)),
            const SizedBox(height: AppSpacing.sm),
          ],
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 58,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        matchup.firstTime,
                        style: AppText.display(context, size: 28),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                VerticalDivider(width: 1, thickness: 1, color: c.border),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      team(matchup.home, matchup.homeId),
                      const SizedBox(height: AppSpacing.sm),
                      team(matchup.away, matchup.awayId),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.border)),
            ),
            child: Row(
              children: [
                Icon(Icons.place_outlined, size: 16, color: c.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    matchup.fieldNames.join(' · '),
                    style: TextStyle(fontSize: 13, color: c.textMuted),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatusTag(matchup: matchup, highlighted: highlighted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Etiqueta del pie: Suspendido/Reprogramado si corresponde, "Tu equipo"
/// en el cruce propio y, si no, la serie o cuántos partidos tiene el cruce.
class _StatusTag extends StatelessWidget {
  final Matchup matchup;
  final bool highlighted;

  const _StatusTag({required this.matchup, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final notable = matchup.entries
        .map((e) => e.match.status)
        .where(MatchStatusBadge.isNotable)
        .firstOrNull;

    if (notable != null) {
      return TagChip(
        label: notable[0].toUpperCase() + notable.substring(1),
        foreground: c.noticeText,
        background: c.noticeBg,
        bold: true,
      );
    }

    if (highlighted) {
      return TagChip(
        label: 'Tu equipo',
        foreground: c.onPrimary,
        background: c.primary,
        bold: true,
      );
    }

    // Un solo partido (p. ej. al filtrar por serie): se nombra su serie.
    final count = matchup.entries.length;
    return TagChip(
      label: count == 1
          ? matchup.entries.first.match.category
          : '$count partidos',
      foreground: c.tagNeutralText,
      background: c.tagNeutralBg,
      bold: true,
    );
  }
}
