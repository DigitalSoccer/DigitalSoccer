import 'package:flutter/services.dart';

import '../models/standing.dart';
import 'asset_json.dart';

class StandingsService {
  static const String generalPath = 'assets/data/standings.json';
  static const String seriesPath = 'assets/data/tablas_series.json';

  /// Tabla general (total acumulado) con su fuente y advertencia.
  static Future<StandingsTable> loadGeneralTable([AssetBundle? bundle]) {
    return loadJsonAsset(
      generalPath,
      (data) {
        // Formato anterior: una lista simple, sin fuente.
        if (data is List) {
          return StandingsTable(standings: parseStandings(data));
        }

        final map = data as Map<String, dynamic>;

        return StandingsTable(
          standings: parseStandings(map['standings']),
          source: map['source'] as String?,
          note: map['note'] as String?,
        );
      },
      bundle: bundle,
    );
  }

  static Future<List<Standing>> loadStandings([AssetBundle? bundle]) async {
    return (await loadGeneralTable(bundle)).standings;
  }

  /// Tablas por serie y subtotales:
  /// `{"series": {"Honor": [...]}, "acumulados": {"Adultos": [...]}}`.
  static Future<SeriesTables> loadSeriesStandings([AssetBundle? bundle]) {
    return loadJsonAsset(
      seriesPath,
      (data) {
        final map = data as Map<String, dynamic>;

        // Cada sección es opcional (p. ej. un archivo sin "acumulados").
        Map<String, List<Standing>> tables(Object? value) => {
              for (final entry in ((value as Map<String, dynamic>?) ??
                      const <String, dynamic>{})
                  .entries)
                entry.key: parseStandings(entry.value),
            };

        return SeriesTables(
          series: tables(map['series']),
          totals: tables(map['acumulados']),
        );
      },
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

  /// Posición en la tabla: los clubes con los mismos puntos comparten
  /// posición (1, 1, 3…), porque no hay reglas de desempate definidas.
  static int rankOf(List<Standing> standings, Standing standing) {
    return 1 + standings.where((s) => s.points > standing.points).length;
  }

  /// Posición del club en una tabla, o `null` si no figura.
  static StandingPosition? positionOf(
    List<Standing> standings,
    String clubId,
  ) {
    final index = standings.indexWhere((s) => s.clubId == clubId);

    if (index < 0) return null;

    return StandingPosition(
      position: rankOf(standings, standings[index]),
      standing: standings[index],
    );
  }
}
