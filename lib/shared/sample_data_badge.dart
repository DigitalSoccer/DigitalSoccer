import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';

/// Etiqueta visible "Datos de ejemplo" sobre toda la app mientras se usen los
/// datos de muestra. Se apaga con [kUsingSampleData].
class SampleDataBadge extends StatelessWidget {
  final Widget child;

  /// Para pruebas: fuerza el estado de la bandera.
  final bool? enabled;

  const SampleDataBadge({super.key, required this.child, this.enabled});

  @override
  Widget build(BuildContext context) {
    if (!(enabled ?? kUsingSampleData)) return child;
    final c = context.colors;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        child,
        // Sobre la barra inferior (72) y sin bloquear toques.
        Positioned(
          left: 0,
          right: 0,
          bottom: bottom + 80,
          child: IgnorePointer(
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.inverse.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  'Datos de ejemplo',
                  style: TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: c.onInverse,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
