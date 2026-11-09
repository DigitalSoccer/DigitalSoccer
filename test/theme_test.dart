import 'package:anfa_chiguayante/core/business_rules.dart';
import 'package:anfa_chiguayante/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('los colores de marca del mockup', () {
    expect(AppColors.light.brand, const Color(0xFFFFC700));
    expect(AppColors.light.inverse, const Color(0xFF111111));
    expect(AppColors.light.background, const Color(0xFFF5F4F0));
  });

  test('los pares de texto cumplen contraste WCAG AA en claro y oscuro', () {
    for (final (name, c) in [('claro', AppColors.light), ('oscuro', AppColors.dark)]) {
      final pairs = {
        'texto / fondo': (c.text, c.background),
        'texto / tarjeta': (c.text, c.surface),
        'secundario / fondo': (c.textMuted, c.background),
        'secundario / tarjeta': (c.textMuted, c.surface),
        'sobre amarillo': (c.onBrand, c.brand),
        'invertido': (c.onInverse, c.inverse),
        'texto / fila de mi equipo': (c.text, c.ownTeam),
        'cabecera': (c.onHeader, c.header),
        'cabecera secundario': (c.onHeaderMuted, c.header),
        'amarillo sobre cabecera': (c.brand, c.header),
        'texto / amarillo suave': (c.text, c.brandSoft),
      };
      pairs.forEach((label, p) {
        expect(contrast(p.$1, p.$2), greaterThanOrEqualTo(4.5),
            reason: '$name: $label');
      });
    }
  });

  test('montos en pesos chilenos', () {
    expect(formatClp(BusinessRules.clubInscription), r'$50.000');
    expect(formatClp(BusinessRules.playerSubscription), r'$1.000');
  });
}
