class Match {
  final String time;
  final String home;
  final String away;
  final String category;
  final String status;

  Match({
    required this.time,
    required this.home,
    required this.away,
    required this.category,
    this.status = 'normal',
  });

  String get id => '$home-$away-$time-$category';

  Match copyWith({
    String? time,
    String? status,
  }) {
    return Match(
      time: time ?? this.time,
      home: home,
      away: away,
      category: category,
      status: status ?? this.status,
    );
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      time: json['time'],
      home: json['home'],
      away: json['away'],
      category: json['category'],
      status: json['status'] ?? 'normal',
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