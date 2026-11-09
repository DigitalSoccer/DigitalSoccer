import 'dart:ui';

/// Club de la asociación. Nombre, iniciales y color son datos REALES (mockup
/// aprobado); los escudos son iniciales de color hasta tener los oficiales.
/// TODO(asociación): escudos oficiales.
class Club {
  final String id;

  /// Nombre corto que usa la app ("Bdo. O'Higgins").
  final String name;

  /// Nombre completo para la ficha ("Bernardo O'Higgins").
  final String fullName;
  final String initials;
  final Color color;

  /// Cancha habitual (por confirmar).
  final String field;

  /// Redes sociales (opcionales por club, DUMMY).
  /// TODO(decisión): ¿se muestran las redes en el detalle del equipo?
  final String? facebook;
  final String? instagram;

  /// Inscripción inicial al día (DUMMY).
  final bool inscriptionPending;

  /// Series en que el club tiene equipo.
  final List<String> seriesIds;

  const Club({
    required this.id,
    required this.name,
    required this.fullName,
    required this.initials,
    required this.color,
    required this.field,
    this.facebook,
    this.instagram,
    this.inscriptionPending = false,
    this.seriesIds = const [],
  });

  bool get hasSocial => facebook != null || instagram != null;

  factory Club.fromJson(Map<String, dynamic> json) {
    final social = json['redes'] as Map<String, dynamic>?;
    return Club(
      id: json['id'] as String,
      name: json['nombre'] as String,
      fullName: json['nombreCompleto'] as String? ?? json['nombre'] as String,
      initials: json['iniciales'] as String,
      color: parseHexColor(json['color'] as String),
      field: json['cancha'] as String? ?? '',
      facebook: social?['facebook'] as String?,
      instagram: social?['instagram'] as String?,
      inscriptionPending: json['inscripcion'] == 'pendiente',
      seriesIds: [for (final s in json['series'] as List? ?? []) s as String],
    );
  }
}

/// "#RRGGBB" -> Color.
Color parseHexColor(String hex) =>
    Color(int.parse(hex.replaceFirst('#', ''), radix: 16) | 0xFF000000);
