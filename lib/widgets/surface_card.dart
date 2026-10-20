import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Superficie base: blanco puro, borde slate-100, esquinas `rounded-2xl` y
/// sombra difusa. Reemplaza a `Card`, que solo admite sombras de elevación.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  /// Borde destacado (p. ej. Mi Club). Sin valor, el borde es el suave.
  final Color? borderColor;

  /// Fondo; sin valor, el `surface` del tema.
  final Color? color;
  final List<BoxShadow> shadow;
  final double radius;

  const SurfaceCard({
    super.key,
    required this.child,
    this.margin = EdgeInsets.zero,
    this.padding,
    this.onTap,
    this.borderColor,
    this.color,
    this.shadow = AppShadows.sm,
    this.radius = AppRadius.lg,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    Widget content = padding == null
        ? child
        : Padding(padding: padding!, child: child);

    if (onTap != null) {
      content = InkWell(onTap: onTap, child: content);
    }

    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color ?? context.colors.surface,
          borderRadius: borderRadius,
          border: Border.all(
            color: borderColor ?? context.colors.border,
            width: borderColor == null ? 1 : 1.5,
          ),
          boxShadow: shadow,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          // Material transparente: da soporte a InkWell y ExpansionTile.
          child: Material(type: MaterialType.transparency, child: content),
        ),
      ),
    );
  }
}
