import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/fixture_round.dart';

class DataService {
  static Future<FixtureRound> loadData() async {
    final jsonString =
    await rootBundle.loadString(
      'assets/data/fixture.json',
    );

    final data = json.decode(jsonString);

    return FixtureRound.fromJson(data);
  }
}