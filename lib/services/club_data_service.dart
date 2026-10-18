import 'package:flutter/services.dart';

import '../models/club.dart';
import 'asset_json.dart';

class ClubDataService {
  static Future<List<Club>> loadClubs([AssetBundle? bundle]) {
    return loadJsonAsset(
      'assets/data/clubs.json',
      parseClubs,
      bundle: bundle,
    );
  }

  static List<Club> parseClubs(dynamic data) {
    return (data as List)
        .map((club) => Club.fromJson(club as Map<String, dynamic>))
        .toList();
  }

  static Club? findById(List<Club> clubs, String? id) {
    for (final club in clubs) {
      if (club.id == id) return club;
    }
    return null;
  }
}
