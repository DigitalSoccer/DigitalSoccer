import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bundle de assets en memoria para pruebas. Un asset ausente produce un
/// error de carga, igual que un archivo faltante en la app real.
class FakeAssetBundle extends CachingAssetBundle {
  final Map<String, String> files;

  /// Cantidad de lecturas realizadas (útil para probar reintentos).
  int loads = 0;

  FakeAssetBundle(this.files);

  @override
  Future<ByteData> load(String key) async {
    loads++;
    final text = files[key];

    if (text == null) {
      throw FlutterError('Asset no encontrado: $key');
    }

    return ByteData.sublistView(utf8.encode(text));
  }

  // Sin caché, para que un reintento vuelva a leer el archivo.
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final data = await load(key);
    return utf8.decode(data.buffer.asUint8List());
  }
}

const dataFiles = [
  'assets/data/clubs.json',
  'assets/data/fechas.json',
  'assets/data/fecha_21.json',
  'assets/data/fixture.json',
  'assets/data/standings.json',
];

/// Lee del disco los JSON reales del proyecto.
Map<String, String> realDataFiles() {
  return {
    for (final path in dataFiles) path: File(path).readAsStringSync(),
  };
}

FakeAssetBundle realDataBundle() => FakeAssetBundle(realDataFiles());
