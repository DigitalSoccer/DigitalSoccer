import 'dart:ui' show Color;

class Club {
  /// Identificador estable del club (p. ej. `arturo-prat`). Es la única
  /// clave que debe usarse para relacionar clubes con partidos y tablas;
  /// los nombres son solo para mostrar y pueden variar entre fuentes.
  final String id;
  final String name;
  final String shortName;
  final String field;

  /// Escudo provisorio: iniciales sobre un círculo de color. Los colores NO
  /// son los reales de cada club; se reemplazan por el logo cuando exista.
  final String? initials;
  final Color? color;

  /// Color más claro para el tema oscuro (solo en escudos muy oscuros).
  final Color? colorDark;

  Club({
    required this.id,
    required this.name,
    required this.shortName,
    required this.field,
    this.initials,
    this.color,
    this.colorDark,
  });

  static Color? _parseColor(Object? value) {
    if (value is! String || !value.startsWith('#') || value.length != 7) {
      return null;
    }
    final rgb = int.tryParse(value.substring(1), radix: 16);
    return rgb == null ? null : Color(0xFF000000 | rgb);
  }

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      field: json['field'] as String,
      initials: json['initials'] as String?,
      color: _parseColor(json['color']),
      colorDark: _parseColor(json['colorDark']),
    );
  }
}
