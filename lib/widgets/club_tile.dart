import 'package:flutter/material.dart';

import '../models/club.dart';
import '../theme/app_theme.dart';
import 'app_components.dart';

/// Tarjeta de club para listas: avatar circular, nombre en negrita, cancha
/// en gris y una acción a la derecha (estrella, check o flecha).
class ClubTile extends StatelessWidget {
  final Club club;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  const ClubTile({
    super.key,
    required this.club,
    this.trailing,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.xs + 2,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SurfaceCard(
      margin: margin,
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        trailing == null ? AppSpacing.md : AppSpacing.xs,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          const ClubAvatar(size: 44),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                FieldLabel(club.field),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Cancha del club con ícono de ubicación, o "Cancha por definir".
class FieldLabel extends StatelessWidget {
  final String field;

  const FieldLabel(this.field, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 14,
          color: AppColors.outline,
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            field.isEmpty ? 'Cancha por definir' : field,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

/// Estrella interactiva de Mi Club, con una pequeña animación al marcarla.
class FavoriteStarButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const FavoriteStarButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isFavorite ? 'Es Mi Club' : 'Establecer como Mi Club',
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          key: ValueKey(isFavorite),
          size: 26,
          color: isFavorite ? AppColors.favorite : AppColors.outline,
        ),
      ),
    );
  }
}
