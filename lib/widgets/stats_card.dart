import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'surface_card.dart';

/// Dato destacado: etiqueta pequeña en mayúsculas sobre una cifra grande.
class StatTile extends StatelessWidget {
  final String label;
  final String value;

  const StatTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: AppText.eyebrow),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppText.metric),
      ],
    );
  }
}

/// Tarjeta flotante con varias métricas separadas por divisores verticales
/// (p. ej. POSICIÓN · PUNTOS).
class StatsCard extends StatelessWidget {
  final List<StatTile> stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      shadow: AppShadows.md,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0)
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  indent: AppSpacing.xs,
                  endIndent: AppSpacing.xs,
                  color: AppColors.borderStrong,
                ),
              Expanded(child: stats[i]),
            ],
          ],
        ),
      ),
    );
  }
}
