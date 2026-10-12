class Club {
  /// Identificador estable del club (p. ej. `arturo-prat`). Es la única
  /// clave que debe usarse para relacionar clubes con partidos y tablas;
  /// los nombres son solo para mostrar y pueden variar entre fuentes.
  final String id;
  final String name;
  final String shortName;
  final String field;

  Club({
    required this.id,
    required this.name,
    required this.shortName,
    required this.field,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      field: json['field'] as String,
    );
  }
}
