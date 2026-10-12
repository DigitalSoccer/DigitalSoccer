import 'dart:convert';
import 'package:flutter/services.dart';

class Standing {
  final String team;
  final int points;

  Standing({
    required this.team,
    required this.points,
  });

  factory Standing.fromJson(Map<String, dynamic> json) {
    return Standing(
      team: json['team'],
      points: json['points'],
    );
  }
}

class StandingsService {
  static Future<List<Standing>> loadStandings() async {
    final jsonString =
    await rootBundle.loadString('assets/data/standings.json');

    final List data = json.decode(jsonString);

    final standings =
    data.map((e) => Standing.fromJson(e)).toList();

    standings.sort(
          (a, b) => b.points.compareTo(a.points),
    );

    return standings;
  }
}