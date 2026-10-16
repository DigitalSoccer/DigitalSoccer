import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Ícono genérico de club. NO es un escudo: los escudos oficiales aún no
/// están disponibles ni autorizados.
class ClubAvatar extends StatelessWidget {
  final double size;

  const ClubAvatar({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.shield_outlined,
        size: size * 0.55,
        color: AppColors.primary,
        semanticLabel: 'Club (sin escudo)',
      ),
    );
  }
}

/// Dato destacado: etiqueta pequeña sobre un valor grande.
class StatTile extends StatelessWidget {
  final String label;
  final String value;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Posición en la tabla. Los tres primeros se destacan con el color de
/// identidad (reemplaza los emojis de medalla, que no se ven en la web).
class PositionBadge extends StatelessWidget {
  final int position;

  const PositionBadge({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    final top = position <= 3;

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: top ? AppColors.primary : AppColors.surfaceMid,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '$position',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: top ? AppColors.onPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}

/// Etiqueta de estado del partido. Para "normal" no se muestra nada.
class MatchStatusBadge extends StatelessWidget {
  final String status;

  const MatchStatusBadge({super.key, required this.status});

  static Color colorFor(String status) {
    switch (status) {
      case 'suspendido':
        return AppColors.statusSuspended;
      case 'reprogramado':
        return AppColors.statusRescheduled;
      default:
        return AppColors.statusNormal;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status != 'suspendido' && status != 'reprogramado') {
      return const SizedBox.shrink();
    }

    final color = colorFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Título de sección en mayúsculas pequeñas.
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

/// Limita el ancho del contenido en pantallas anchas (escritorio/web).
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = 720,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Tarjeta disciplinaria (amarilla o roja) dibujada como un rectángulo.
class DisciplineCard extends StatelessWidget {
  final Color color;

  const DisciplineCard({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
