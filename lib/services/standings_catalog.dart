import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/standing.dart';
import 'standings_service.dart';

/// Una tabla elegible con los chips de serie: la general, una serie o un
/// acumulado.
class TableOption {
  /// Identificador estable para guardar la elección ("general",
  /// "serie:Honor", "total:Adultos").
  final String key;

  /// Texto del chip y de los títulos ("Honor", "Total adultos").
  final String label;

  final List<Standing> standings;

  const TableOption({
    required this.key,
    required this.label,
    required this.standings,
  });
}

/// Todas las tablas de posiciones en el orden de los chips, con la fuente
/// de la tabla general. Las pantallas leen las tablas desde aquí, no desde
/// los JSON (`docs/diseno.md` 9).
class StandingsCatalog {
  static const String generalKey = 'general';
  static const String prefsKey = 'selected_table';

  /// Orden de los chips: de la serie mayor a la menor (como el mockup).
  static const List<String> chipOrder = [
    'Honor',
    'Primera',
    'Segunda',
    'Senior',
    'S. Senior',
    'H. Ortiz',
    'Femenina',
    'Juveniles',
    '1° Infantil',
    '2° Infantil',
  ];

  final List<TableOption> options;
  final String? source;
  final String? note;

  const StandingsCatalog({required this.options, this.source, this.note});

  /// La opción con esa clave o, si no existe, la tabla general (va al
  /// final de los chips, pero es la elección por defecto).
  TableOption byKey(String? key) => options.firstWhere(
        (o) => o.key == key,
        orElse: () => options.firstWhere(
          (o) => o.key == generalKey,
          orElse: () => options.first,
        ),
      );

  /// Serie del fixture que corresponde a una opción, o `null` si la opción
  /// abarca todas las series (General y acumulados).
  static String? seriesOf(String key) =>
      key.startsWith('serie:') ? key.substring('serie:'.length) : null;

  /// Arma el catálogo. La tabla general es obligatoria; si las tablas por
  /// serie no cargan, se muestra igual la general.
  static Future<StandingsCatalog> load([AssetBundle? bundle]) async {
    final results = await Future.wait<Object>([
      StandingsService.loadGeneralTable(bundle),
      StandingsService.loadSeriesStandings(bundle).catchError((Object e) {
        debugPrint('Tablas por serie no disponibles: $e');
        return const SeriesTables();
      }),
    ]);

    final general = results[0] as StandingsTable;
    final tables = results[1] as SeriesTables;

    final seriesNames = [
      ...chipOrder.where(tables.series.containsKey),
      ...tables.series.keys.where((s) => !chipOrder.contains(s)),
    ];

    return StandingsCatalog(
      source: general.source,
      note: general.note,
      // Orden de los chips: series, acumulados y al final la general.
      options: [
        for (final name in seriesNames)
          if (tables.series[name]!.isNotEmpty)
            TableOption(
              key: 'serie:$name',
              label: name,
              standings: tables.series[name]!,
            ),
        for (final entry in tables.totals.entries)
          if (entry.value.isNotEmpty)
            TableOption(
              key: 'total:${entry.key}',
              label: 'Total ${entry.key.toLowerCase()}',
              standings: entry.value,
            ),
        TableOption(
          key: generalKey,
          label: 'General',
          standings: general.standings,
        ),
      ],
    );
  }

  /// Tabla elegida la última vez (Inicio y Tabla comparten la elección).
  static Future<String?> getSelectedKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(prefsKey);
  }

  static Future<void> setSelectedKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, key);
  }
}
