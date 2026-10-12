class Match {
  final String time;
  final String home;
  final String homeId;
  final String away;
  final String awayId;
  final String category;
  final String status;

  Match({
    required this.time,
    required this.home,
    required this.homeId,
    required this.away,
    required this.awayId,
    required this.category,
    this.status = 'normal',
  });

  // Se mantiene basado en nombres para no perder los partidos favoritos
  // ya guardados en los teléfonos (ver docs/ESTADO_PROYECTO.md).
  String get id => '$home-$away-$time-$category';

  /// Indica si el club con [clubId] juega este partido (local o visita).
  bool involves(String clubId) => homeId == clubId || awayId == clubId;

  Match copyWith({
    String? time,
    String? status,
  }) {
    return Match(
      time: time ?? this.time,
      home: home,
      homeId: homeId,
      away: away,
      awayId: awayId,
      category: category,
      status: status ?? this.status,
    );
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      time: json['time'] as String,
      home: json['home'] as String,
      homeId: json['homeId'] as String,
      away: json['away'] as String,
      awayId: json['awayId'] as String,
      category: json['category'] as String,
      status: json['status'] as String? ?? 'normal',
    );
  }
}


/// Bloque de partidos de una cancha. En la planilla de la asociación cada
/// bloque termina con una línea "TURNO:" (club a cargo de la mesa).
class FieldBlock {
  final List<Match> matches;

  /// Nombre del turno si la planilla lo indica; hoy suele venir vacío.
  final String? turno;

  FieldBlock({
    required this.matches,
    this.turno,
  });

  factory FieldBlock.fromJson(Map<String, dynamic> json) {
    final turno = json['turno'] as String?;

    return FieldBlock(
      matches: (json['matches'] as List)
          .map((m) => Match.fromJson(m as Map<String, dynamic>))
          .toList(),
      turno: (turno == null || turno.trim().isEmpty) ? null : turno.trim(),
    );
  }
}

class FieldSchedule {
  final String fieldName;
  final List<FieldBlock> blocks;

  /// `true` si la fuente organiza los partidos en turnos (formato de la
  /// planilla), aunque la cancha tenga un solo bloque.
  final bool hasTurnos;

  /// Cancha con un solo bloque (formato antiguo, sin turnos).
  FieldSchedule({
    required this.fieldName,
    required List<Match> matches,
  })  : blocks = [FieldBlock(matches: matches)],
        hasTurnos = false;

  FieldSchedule.withBlocks({
    required this.fieldName,
    required this.blocks,
  }) : hasTurnos = true;

  /// Todos los partidos de la cancha, en el orden de la planilla.
  List<Match> get matches => [
        for (final block in blocks) ...block.matches,
      ];

  factory FieldSchedule.fromJson(Map<String, dynamic> json) {
    final fieldName = json['fieldName'] as String;

    if (json['blocks'] != null) {
      return FieldSchedule.withBlocks(
        fieldName: fieldName,
        blocks: (json['blocks'] as List)
            .map((b) => FieldBlock.fromJson(b as Map<String, dynamic>))
            .toList(),
      );
    }

    return FieldSchedule(
      fieldName: fieldName,
      matches: (json['matches'] as List)
          .map((m) => Match.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MatchDay {
  /// Nombre del día tal como viene ("Sábado", "Domingo").
  final String day;

  /// Fecha calendario, si la fuente la indica.
  final DateTime? date;

  final List<FieldSchedule> fields;

  /// Ids de los clubes que quedan libres ese día ("LIBRE:" en la planilla).
  final List<String> byeClubIds;

  MatchDay({
    required this.day,
    required this.fields,
    this.date,
    this.byeClubIds = const [],
  });

  factory MatchDay.fromJson(Map<String, dynamic> json) {
    final date = json['date'] as String?;

    return MatchDay(
      day: json['day'] as String,
      date: date == null ? null : DateTime.parse(date),
      fields: (json['fields'] as List)
          .map((f) => FieldSchedule.fromJson(f as Map<String, dynamic>))
          .toList(),
      byeClubIds: (json['libre'] as List? ?? const [])
          .map((id) => id as String)
          .toList(),
    );
  }
}

/// Partidos consecutivos del mismo cruce, como la planilla los escribe:
/// el primero con los equipos y los siguientes con la fila en blanco.
class MatchupGroup {
  final List<Match> matches;

  MatchupGroup(this.matches);

  Match get first => matches.first;

  static List<MatchupGroup> consecutive(List<Match> matches) {
    final groups = <MatchupGroup>[];

    for (final match in matches) {
      final last = groups.isEmpty ? null : groups.last.first;

      if (last != null &&
          last.homeId == match.homeId &&
          last.awayId == match.awayId) {
        groups.last.matches.add(match);
      } else {
        groups.add(MatchupGroup([match]));
      }
    }

    return groups;
  }
}
