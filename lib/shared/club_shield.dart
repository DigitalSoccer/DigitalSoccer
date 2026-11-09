import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models/club.dart';

/// Escudo provisorio: círculo del color del club con sus iniciales.
/// TODO(asociación): reemplazar por los escudos oficiales cuando lleguen.
class ClubShield extends StatelessWidget {
  final Club club;
  final double size;

  /// Anillo alrededor (blanco sobre la cabecera negra, amarillo en fichas).
  final Color? ringColor;
  final double ringWidth;

  const ClubShield({
    super.key,
    required this.club,
    this.size = 26,
    this.ringColor,
    this.ringWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Escudo de ${club.name}',
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: club.color,
          shape: BoxShape.circle,
          border: ringColor == null
              ? null
              : Border.all(color: ringColor!, width: ringWidth),
        ),
        child: Text(
          club.initials,
          maxLines: 1,
          style: TextStyle(
            fontFamily: AppFonts.family,
            fontSize: size * 0.34,
            fontWeight: FontWeight.w800,
            height: 1,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
