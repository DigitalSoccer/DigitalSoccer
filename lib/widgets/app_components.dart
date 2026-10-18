import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

export 'app_bottom_sheet.dart';
export 'info_banner.dart';
export 'segmented_tab_bar.dart';
export 'stats_card.dart';
export 'surface_card.dart';

/// Avatar circular de club. NO es un escudo: los escudos oficiales aún no
/// están disponibles ni autorizados, así que se usa un ícono genérico.
class ClubAvatar extends StatelessWidget {
  final double size;

  /// Versión destacada (fondo rojo suave) para el encabezado del club.
  final bool emphasis;

  const ClubAvatar({super.key, this.size = 40, this.emphasis = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: emphasis ? AppColors.primarySoft : AppColors.surfaceMuted,
        shape: BoxShape.circle,
        border: Border.all(
          color: emphasis ? AppColors.primaryContainer : AppColors.border,
        ),
      ),
      child: Icon(
        Icons.shield_outlined,
        size: size * 0.5,
        color: emphasis ? AppColors.primary : AppColors.textMuted,
        semanticLabel: 'Club (sin escudo)',
      ),
    );
  }
}

/// Posición en la tabla. El podio (1° a 3°) va en una píldora oro, plata o
/// bronce; el resto es solo el número.
class PositionBadge extends StatelessWidget {
  final int position;

  const PositionBadge({super.key, required this.position});

  static (Color, Color)? podiumColors(int position) {
    switch (position) {
      case 1:
        return (AppColors.goldBg, AppColors.goldFg);
      case 2:
        return (AppColors.silverBg, AppColors.silverFg);
      case 3:
        return (AppColors.bronzeBg, AppColors.bronzeFg);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final podium = podiumColors(position);

    return Container(
      width: 30,
      height: 26,
      alignment: Alignment.center,
      decoration: podium == null
          ? null
          : BoxDecoration(
              color: podium.$1,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
      child: Text(
        '$position',
        style: TextStyle(
          fontSize: 13,
          fontWeight: podium == null ? FontWeight.w600 : FontWeight.w800,
          color: podium?.$2 ?? AppColors.textMuted,
          fontFeatures: AppText.tabular,
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

  static bool isNotable(String status) =>
      status == 'suspendido' || status == 'reprogramado';

  @override
  Widget build(BuildContext context) {
    if (!isNotable(status)) return const SizedBox.shrink();

    final color = colorFor(status);

    return TagChip(
      label: status[0].toUpperCase() + status.substring(1),
      foreground: color,
      background: color.withValues(alpha: 0.1),
    );
  }
}

/// Chip pequeño en píldora: series en juego, estados, "MI CLUB".
class TagChip extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;
  final bool uppercase;

  const TagChip({
    super.key,
    required this.label,
    this.foreground = AppColors.textSecondary,
    this.background = AppColors.surfaceMuted,
    this.uppercase = false,
  });

  /// Insignia roja de Mi Club.
  const TagChip.myClub({super.key})
    : label = 'MI CLUB',
      foreground = AppColors.primary,
      background = AppColors.primaryContainer,
      uppercase = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: uppercase ? 10.5 : 12,
          fontWeight: uppercase ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: uppercase ? 0.6 : 0,
          color: foreground,
        ),
      ),
    );
  }
}

/// Título de sección: etiqueta en mayúsculas pequeñas, gris y espaciada.
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg + AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(title.toUpperCase(), style: AppText.eyebrow),
    );
  }
}

/// Subtítulo de grupo dentro de una lista (p. ej. el día de un cruce).
class GroupLabel extends StatelessWidget {
  final String text;

  const GroupLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg + AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Botón circular de ícono sobre fondo slate-100 (flechas del selector).
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surfaceMuted,
        foregroundColor: AppColors.text,
        disabledBackgroundColor: AppColors.background,
        disabledForegroundColor: AppColors.handle,
        fixedSize: const Size(40, 40),
      ),
    );
  }
}

/// Limita el ancho del contenido en pantallas anchas (escritorio/web).
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ContentWidth({super.key, required this.child, this.maxWidth = 720});

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

/// Escudo de club GENÉRICO: un escudo rojo relleno, como en la maqueta.
/// No es el escudo oficial de ningún club (no hay escudos autorizados);
/// cuando existan, este es el lugar para mostrar la imagen de cada club.
class ClubCrest extends StatelessWidget {
  final double size;

  /// Con fondo circular blanco (para usar sobre el encabezado rojo).
  final bool onRed;

  const ClubCrest({super.key, this.size = 32, this.onRed = false});

  @override
  Widget build(BuildContext context) {
    final shield = Icon(
      Icons.shield_rounded,
      size: onRed ? size * 0.58 : size,
      color: AppColors.primary,
      semanticLabel: 'Escudo genérico (sin escudo oficial)',
    );

    if (!onRed) return shield;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: shield,
    );
  }
}
