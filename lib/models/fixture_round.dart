import 'match.dart';

class FixtureRound {
  final int round;
  final List<MatchDay> days;

  /// De dónde salen los datos (p. ej. la planilla de la asociación).
  /// `null` si el origen no está verificado.
  final String? source;

  FixtureRound({
    required this.round,
    required this.days,
    this.source,
  });

  /// Fechas calendario de la jornada (vacío si la fuente no las trae).
  List<DateTime> get dates => [
        for (final day in days)
          if (day.date != null) day.date!,
      ];

  factory FixtureRound.fromJson(
      Map<String, dynamic> json,
      ) {
    return FixtureRound(
      round: json['round'] as int,
      days: (json['days'] as List)
          .map((d) => MatchDay.fromJson(d as Map<String, dynamic>))
          .toList(),
      source: json['source'] as String?,
    );
  }
}
