import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/club.dart';

class ClubDataService {
  static Future<List<Club>> loadClubs() async {
    final jsonString =
    await rootBundle.loadString(
      'assets/data/clubs.json',
    );

    final List data = json.decode(jsonString);

    return data
        .map((club) => Club.fromJson(club))
        .toList();
  }
}