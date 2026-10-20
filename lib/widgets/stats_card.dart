import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'surface_card.dart';

/// Dato destacado: etiqueta pequeña en mayúsculas sobre una cifra grande.
class StatTile extends StatelessWidget {
  final String label;
  final String value;

  /// Color de la cifra (por defecto, el del texto).
  final Color? valueColor;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: AppText.eyebrow(context)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: valueColor == null
              ? AppText.metric(context)
              : AppText.metric(context).copyWith(color: valueColor),
        ),
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
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  indent: AppSpacing.xs,
                  endIndent: AppSpacing.xs,
                  color: context.colors.borderStrong,
                ),
              Expanded(child: stats[i]),
            ],
          ],
        ),
      ),
    );
  }
}
