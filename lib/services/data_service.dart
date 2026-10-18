import 'package:flutter/services.dart';

import '../models/fixture_round.dart';
import 'asset_json.dart';

class DataService {
  static const String indexPath = 'assets/data/fechas.json';

  /// Todas las fechas listadas en `fechas.json`, de la más reciente a la
  /// más antigua (por número de fecha).
  static Future<List<FixtureRound>> loadRounds([AssetBundle? bundle]) async {
    final paths = await loadJsonAsset(
      indexPath,
      (data) => ((data as Map<String, dynamic>)['fechas'] as List)
          .map((p) => p as String)
          .toList(),
      bundle: bundle,
    );

    final rounds = await Future.wait(
      paths.map((path) => loadRound(path, bundle)),
    );

    rounds.sort((a, b) => b.round.compareTo(a.round));

    return rounds;
  }

  static Future<FixtureRound> loadRound(String path, [AssetBundle? bundle]) {
    return loadJsonAsset(
      path,
      (data) => FixtureRound.fromJson(data as Map<String, dynamic>),
      bundle: bundle,
    );
  }

  /// La fecha más reciente disponible.
  static Future<FixtureRound> loadData([AssetBundle? bundle]) async {
    final rounds = await loadRounds(bundle);

    if (rounds.isEmpty) {
      throw DataLoadException(indexPath, 'No hay fechas cargadas');
    }

    return rounds.first;
  }
}
