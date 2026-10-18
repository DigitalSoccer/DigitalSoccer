import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

/// Error al cargar o interpretar un archivo de datos de la app.
class DataLoadException implements Exception {
  final String asset;
  final Object cause;

  DataLoadException(this.asset, this.cause);

  @override
  String toString() => 'DataLoadException($asset): $cause';
}

/// Lee un JSON de [bundle] (por defecto los assets de la app), lo decodifica
/// y lo convierte con [parse].
///
/// Cualquier falla (archivo ausente, JSON mal formado, campos con tipo
/// incorrecto o demora mayor a [timeout]) se entrega como
/// [DataLoadException], para que la interfaz muestre un error en vez de
/// quedarse cargando.
Future<T> loadJsonAsset<T>(
  String path,
  T Function(dynamic data) parse, {
  AssetBundle? bundle,
  Duration timeout = const Duration(seconds: 10),
}) async {
  try {
    final text = await (bundle ?? rootBundle)
        .loadString(path)
        .timeout(timeout);

    return parse(json.decode(text));
  } catch (e) {
    throw DataLoadException(path, e);
  }
}
