/// Estadísticas de un jugador en una serie (temporada en curso).
/// Son los datos que registra el acta de cada partido.
class PlayerStats {
  final int played;
  final int goals;
  final int yellowCards;
  final int redCards;

  const PlayerStats({
    this.played = 0,
    this.goals = 0,
    this.yellowCards = 0,
    this.redCards = 0,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      played: json['played'] as int? ?? 0,
      goals: json['goals'] as int? ?? 0,
      yellowCards: json['yellow'] as int? ?? 0,
      redCards: json['red'] as int? ?? 0,
    );
  }
}

class Player {
  final String id;
  final String name;

  /// Número de camiseta, si el club lo informa.
  final int? number;

  final PlayerStats stats;

  Player({
    required this.id,
    required this.name,
    this.number,
    this.stats = const PlayerStats(),
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>?;

    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as int?,
      stats: stats == null ? const PlayerStats() : PlayerStats.fromJson(stats),
    );
  }
}

/// Plantel de un club en una serie.
class Squad {
  final String clubId;
  final String category;
  final List<Player> players;

  Squad({
    required this.clubId,
    required this.category,
    required this.players,
  });

  factory Squad.fromJson(Map<String, dynamic> json) {
    return Squad(
      clubId: json['clubId'] as String,
      category: json['category'] as String,
      players: (json['players'] as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
