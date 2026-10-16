class Standing {
  final String clubId;

  /// Nombre tal como viene en la fuente de la tabla (puede diferir del
  /// nombre del club, p. ej. `A. Prat`). Para mostrar se prefiere
  /// el nombre del catálogo de clubes.
  final String team;
  final int points;

  /// Partidos jugados y diferencia de goles. Opcionales: la fuente actual
  /// solo trae puntos, y la app muestra "–" mientras no haya dato.
  final int? played;
  final int? goalDifference;

  Standing({
    required this.clubId,
    required this.team,
    required this.points,
    this.played,
    this.goalDifference,
  });

  factory Standing.fromJson(Map<String, dynamic> json) {
    return Standing(
      clubId: json['clubId'] as String,
      team: json['team'] as String,
      points: json['points'] as int,
      played: json['played'] as int?,
      goalDifference: json['goalDifference'] as int?,
    );
  }
}

/// Diferencia de goles con signo ("+5", "-3", "0"), o "–" sin dato.
String formatGoalDifference(int? value) {
  if (value == null) return '–';
  return value > 0 ? '+$value' : '$value';
}

/// Posición de un club en la tabla (1 = primero).
class StandingPosition {
  final int position;
  final Standing standing;

  StandingPosition({
    required this.position,
    required this.standing,
  });
}
