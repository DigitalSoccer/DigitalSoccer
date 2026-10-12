class Standing {
  final String clubId;

  /// Nombre tal como viene en la fuente de la tabla (puede diferir del
  /// nombre del club, p. ej. `A. Prat`). Para mostrar se prefiere
  /// el nombre del catálogo de clubes.
  final String team;
  final int points;

  Standing({
    required this.clubId,
    required this.team,
    required this.points,
  });

  factory Standing.fromJson(Map<String, dynamic> json) {
    return Standing(
      clubId: json['clubId'] as String,
      team: json['team'] as String,
      points: json['points'] as int,
    );
  }
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
