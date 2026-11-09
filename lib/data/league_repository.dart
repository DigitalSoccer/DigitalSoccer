import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/config.dart';
import 'league_data.dart';

/// Acceso a los datos de la liga. Las pantallas solo conocen esta interfaz:
/// hoy la implementa el archivo de muestra; mañana, una API HTTPS con los
/// datos oficiales (la app nunca se conecta directo a la base de datos).
abstract interface class LeagueRepository {
  Future<LeagueData> load();
}

/// Datos de MUESTRA (DUMMY) desde `assets/data/sample_data.json`.
class SampleLeagueRepository implements LeagueRepository {
  final AssetBundle bundle;

  SampleLeagueRepository([AssetBundle? bundle]) : bundle = bundle ?? rootBundle;

  @override
  Future<LeagueData> load() async {
    final text = await bundle.loadString(kSampleDataAsset);
    return LeagueData.fromJson(jsonDecode(text) as Map<String, dynamic>);
  }
}
