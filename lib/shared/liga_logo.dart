import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Logotipo "Liga SUR": "Liga" en blanco y "SUR" en caja amarilla.
class LigaLogo extends StatelessWidget {
  /// Tamaño de "Liga" (18 en la cabecera, 44 en el ingreso).
  final double size;

  const LigaLogo({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: 'Liga SUR',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Liga',
            style: TextStyle(
              fontFamily: AppFonts.family,
              fontSize: size,
              fontWeight: FontWeight.w800,
              color: c.onHeader,
            ),
          ),
          SizedBox(width: size / 3),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size * 0.45,
              vertical: size * 0.1,
            ),
            decoration: BoxDecoration(
              color: c.brand,
              borderRadius: BorderRadius.circular(size / 3),
            ),
            child: Text(
              'SUR',
              style: TextStyle(
                fontFamily: AppFonts.family,
                fontSize: size * 0.85,
                fontWeight: FontWeight.w800,
                color: c.onBrand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
