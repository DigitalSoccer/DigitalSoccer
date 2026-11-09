import 'dart:convert';
import 'dart:io';

import 'package:anfa_chiguayante/data/league_repository.dart';
import 'package:anfa_chiguayante/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lee los assets desde el disco (en las pruebas no hay rootBundle real).
class DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(File(key).readAsBytesSync()));
}

/// Cuentas de prueba del archivo de muestra.
Map<String, dynamic> testAccount(String profile) {
  final json = jsonDecode(File('assets/data/sample_data.json').readAsStringSync())
      as Map<String, dynamic>;
  return (json['usuarios'] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((u) => u['perfil'] == profile);
}

/// Arranca la app con los datos de muestra y espera a que cargue.
Future<void> pumpApp(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(
      LigaSurApp(repository: SampleLeagueRepository(DiskBundle())),
    );
    // Carga del JSON y de la sesión guardada.
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();
    }
  });
  await tester.pumpAndSettle();
}

/// Pantalla de teléfono (390×844) o el tamaño indicado.
void phone(WidgetTester tester, [Size size = const Size(390, 844)]) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
