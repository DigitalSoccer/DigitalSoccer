import 'package:flutter/material.dart';

import '../models/club.dart';
import '../theme/app_theme.dart';
import 'clubs_scope.dart';

export 'app_bottom_sheet.dart';
export 'clubs_scope.dart';
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

  /// Club a mostrar: con iniciales y color conocidos se dibuja su escudo
  /// provisorio; si no, el ícono genérico.
  final String? clubId;

  const ClubAvatar({
    super.key,
    this.size = 40,
    this.emphasis = false,
    this.clubId,
  });

  @override
  Widget build(BuildContext context) {
    final club = ClubsScope.clubOf(context, clubId);
    if (club != null) {
      final initials = InitialsShield.forClub(context, club, size: size);
      if (initials != null) return initials;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: emphasis ? context.colors.primarySoft : context.colors.surfaceMuted,
        shape: BoxShape.circle,
        border: Border.all(
          color: emphasis ? context.colors.primaryContainer : context.colors.border,
        ),
      ),
      child: Icon(
        Icons.shield_outlined,
        size: size * 0.5,
        color: emphasis ? context.colors.primary : context.colors.textMuted,
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

  static (Color, Color)? podiumColors(BuildContext context, int position) {
    switch (position) {
      case 1:
        return (context.colors.goldBg, context.colors.goldFg);
      case 2:
        return (context.colors.silverBg, context.colors.silverFg);
      case 3:
        return (context.colors.bronzeBg, context.colors.bronzeFg);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final podium = podiumColors(context, position);

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
          color: podium?.$2 ?? context.colors.textMuted,
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

  static Color colorFor(BuildContext context, String status) {
    switch (status) {
      case 'suspendido':
        return context.colors.statusSuspended;
      case 'reprogramado':
        return context.colors.statusRescheduled;
      default:
        return context.colors.statusNormal;
    }
  }

  static bool isNotable(String status) =>
      status == 'suspendido' || status == 'reprogramado';

  @override
  Widget build(BuildContext context) {
    if (!isNotable(status)) return const SizedBox.shrink();

    final color = colorFor(context, status);

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

  /// Colores; sin valor se usan los neutros del tema (o los de Mi Club).
  final Color? foreground;
  final Color? background;
  final bool uppercase;
  final bool _myClub;

  const TagChip({
    super.key,
    required this.label,
    this.foreground,
    this.background,
    this.uppercase = false,
  }) : _myClub = false;

  /// Insignia roja de Mi Club.
  const TagChip.myClub({super.key})
    : label = 'MI CLUB',
      foreground = null,
      background = null,
      uppercase = true,
      _myClub = true;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final background =
        this.background ?? (_myClub ? c.primaryContainer : c.surfaceMuted);
    final foreground =
        this.foreground ?? (_myClub ? c.primaryText : c.textSecondary);

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
      child: Text(title.toUpperCase(), style: AppText.eyebrow(context)),
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
        backgroundColor: context.colors.surfaceMuted,
        foregroundColor: context.colors.text,
        disabledBackgroundColor: context.colors.background,
        disabledForegroundColor: context.colors.handle,
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

  /// Club a mostrar: con iniciales y color conocidos se dibuja su escudo
  /// provisorio (círculo con iniciales); si no, el escudo genérico.
  final String? clubId;

  const ClubCrest({
    super.key,
    this.size = 32,
    this.onRed = false,
    this.clubId,
  });

  @override
  Widget build(BuildContext context) {
    final club = ClubsScope.clubOf(context, clubId);
    if (club != null) {
      final initials = InitialsShield.forClub(
        context,
        club,
        size: size,
        ring: onRed,
      );
      if (initials != null) return initials;
    }

    final shield = Icon(
      Icons.shield_rounded,
      size: onRed ? size * 0.58 : size,
      color: context.colors.primary,
      semanticLabel: 'Escudo genérico (sin escudo oficial)',
    );

    if (!onRed) return shield;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.colors.surface,
        shape: BoxShape.circle,
      ),
      child: shield,
    );
  }
}

/// Escudo provisorio de un club: círculo de color con sus iniciales en
/// Barlow Condensed (`ClubShield` en `docs/diseno.md`). Los colores no son
/// los reales de cada club; se reemplaza por el logo cuando exista.
class InitialsShield extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;

  /// Borde blanco, para usarlo sobre fondo rojo.
  final bool ring;

  const InitialsShield({
    super.key,
    required this.initials,
    required this.color,
    this.size = 32,
    this.ring = false,
  });

  /// Escudo del club con el color del tema activo, o `null` si el club no
  /// tiene iniciales y color.
  static Widget? forClub(
    BuildContext context,
    Club club, {
    double size = 32,
    bool ring = false,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = (dark ? club.colorDark : null) ?? club.color;
    final initials = club.initials;

    if (color == null || initials == null) return null;

    return InitialsShield(
      initials: initials,
      color: color,
      size: size,
      ring: ring,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Escudo provisorio $initials',
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: ring
              ? Border.all(color: context.colors.onPrimary, width: 2)
              : null,
        ),
        child: Text(
          initials,
          maxLines: 1,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: size * 0.42,
            height: 1,
            fontWeight: FontWeight.w700,
            color: context.colors.onPrimary,
          ),
        ),
      ),
    );
  }
}
