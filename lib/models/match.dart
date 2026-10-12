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

class FieldSchedule {
  final String fieldName;
  final List<Match> matches;

  FieldSchedule({
    required this.fieldName,
    required this.matches,
  });

  factory FieldSchedule.fromJson(Map<String, dynamic> json) {
    return FieldSchedule(
      fieldName: json['fieldName'],
      matches: (json['matches'] as List)
          .map((m) => Match.fromJson(m))
          .toList(),
    );
  }
}

class MatchDay {
  final String day;
  final List<FieldSchedule> fields;

  MatchDay({
    required this.day,
    required this.fields,
  });

  factory MatchDay.fromJson(Map<String, dynamic> json) {
    return MatchDay(
      day: json['day'],
      fields: (json['fields'] as List)
          .map((f) => FieldSchedule.fromJson(f))
          .toList(),
    );
  }
}