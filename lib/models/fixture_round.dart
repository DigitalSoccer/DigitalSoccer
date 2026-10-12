import 'match.dart';

class FixtureRound {
  final int round;
  final List<MatchDay> days;

  FixtureRound({
    required this.round,
    required this.days,
  });

  factory FixtureRound.fromJson(
      Map<String, dynamic> json,
      ) {
    return FixtureRound(
      round: json['round'],
      days: (json['days'] as List)
          .map((d) => MatchDay.fromJson(d))
          .toList(),
    );
  }
}