import 'package:flutter/material.dart';

/// Color base PROVISIONAL de la app.
///
/// No es un color oficial del Club Arturo Prat ni de ANFA Chiguayante: es el
/// verde que el proyecto ya usaba. Reemplazar cuando el club confirme su
/// identidad visual.
const Color provisionalSeedColor = Colors.green;

ThemeData buildAppTheme() {
  // Con Material 3 (activo por defecto) `primarySwatch` ya no define los
  // colores: el esquema se genera desde `colorScheme`. Por eso se usa
  // `ColorScheme.fromSeed`.
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: provisionalSeedColor),
  );
}
