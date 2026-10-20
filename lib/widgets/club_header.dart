import 'package:flutter/material.dart';

import '../models/club.dart';
import '../models/standing.dart';
import '../theme/app_theme.dart';
import 'app_components.dart';
import 'club_tile.dart';

/// Encabezado compacto de un club: escudo, nombre y cancha local sobre una
/// banda blanca, y una tarjeta flotante con POSICIÓN y PUNTOS que queda
/// montada entre la banda y el fondo de la pantalla.
class ClubHeroHeader extends StatelessWidget {
  final Club club;
  final StandingPosition? position;

  /// Etiqueta sobre el nombre (p. ej. "MI CLUB").
  final String? eyebrow;

  /// Acción a la derecha del nombre (estrella o "Cambiar").
  final Widget? action;

  const ClubHeroHeader({
    super.key,
    required this.club,
    required this.position,
    this.eyebrow,
    this.action,
  });

  /// Distancia entre el borde inferior del encabezado y el de la banda
  /// blanca: la tarjeta de métricas sobresale unos 40 px.
  static const double _overlap = 48;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final standing = position;

    return Stack(
      children: [
        Positioned.fill(
          bottom: standing == null ? 0 : _overlap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(bottom: BorderSide(color: context.colors.border)),
            ),
          ),
        ),
        ContentWidth(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              standing == null ? AppSpacing.lg : AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    // Ícono genérico: no representa el escudo del club.
                    ClubAvatar(size: 60, emphasis: true, clubId: club.id),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (eyebrow != null)
                            Text(
                              eyebrow!,
                              style: AppText.eyebrow(context).copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          Text(club.name, style: textTheme.titleLarge),
                          const SizedBox(height: 2),
                          FieldLabel(club.field),
                        ],
                      ),
                    ),
                    ?action,
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (standing != null)
                  StatsCard(
                    stats: [
                      StatTile(
                        label: 'Posición',
                        value: '${standing.position}',
                      ),
                      StatTile(
                        label: 'Puntos',
                        value: '${standing.standing.points}',
                      ),
                    ],
                  )
                else
                  Text(
                    'Sin información en la tabla de posiciones.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
