import 'package:flutter/services.dart';

import '../models/player.dart';
import 'asset_json.dart';

/// Planteles por club y serie. Hoy se leen de `assets/data/planteles.json`
/// (vacío hasta que el club entregue los datos); más adelante vendrán de la
/// API.
class SquadService {
  static const String path = 'assets/data/planteles.json';

  static Future<List<Squad>> loadSquads([AssetBundle? bundle]) {
    return loadJsonAsset(
      path,
      (data) => ((data as Map<String, dynamic>)['planteles'] as List)
          .map((s) => Squad.fromJson(s as Map<String, dynamic>))
          .toList(),
      bundle: bundle,
    );
  }

  /// Jugadores del club en la serie; vacío si aún no hay plantel cargado.
  static List<Player> playersOf(
    List<Squad> squads,
    String clubId,
    String category,
  ) {
    for (final squad in squads) {
      if (squad.clubId == clubId && squad.category == category) {
        return squad.players;
      }
    }
    return const [];
  }
}
