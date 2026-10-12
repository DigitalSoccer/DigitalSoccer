import 'package:flutter/services.dart';

import '../models/standing.dart';
import 'asset_json.dart';

class StandingsService {
  static Future<List<Standing>> loadStandings([AssetBundle? bundle]) {
    return loadJsonAsset(
      'assets/data/standings.json',
      parseStandings,
      bundle: bundle,
    );
  }

  /// Ordena por puntos de mayor a menor. Con puntos iguales se conserva el
  /// orden de la fuente: no se aplica ningún desempate propio porque las
  /// reglas oficiales aún no están definidas.
  static List<Standing> parseStandings(dynamic data) {
    final standings = (data as List)
        .map((e) => Standing.fromJson(e as Map<String, dynamic>))
        .toList();

    final sourceOrder = {
      for (var i = 0; i < standings.length; i++) standings[i]: i,
    };

    standings.sort((a, b) {
      final byPoints = b.points.compareTo(a.points);
      return byPoints != 0
          ? byPoints
          : sourceOrder[a]!.compareTo(sourceOrder[b]!);
    });

    return standings;
  }

  /// Posición del club en una tabla ya ordenada, o `null` si no figura.
  static StandingPosition? positionOf(
    List<Standing> standings,
    String clubId,
  ) {
    final index = standings.indexWhere((s) => s.clubId == clubId);

    if (index < 0) return null;

    return StandingPosition(
      position: index + 1,
      standing: standings[index],
    );
  }
}
