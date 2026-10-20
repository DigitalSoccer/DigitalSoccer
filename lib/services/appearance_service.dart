import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Apariencia elegida por el usuario: automático (sigue al teléfono), claro
/// u oscuro. Se guarda en el teléfono; por defecto, automático.
class AppearanceController extends ValueNotifier<ThemeMode> {
  static const String prefsKey = 'appearance';

  AppearanceController([super.value = ThemeMode.system]);

  static ThemeMode _parse(String? value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _name(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

  /// Lee la elección guardada (si no hay, queda en automático).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    value = _parse(prefs.getString(prefsKey));
  }

  Future<void> select(ThemeMode mode) async {
    value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, _name(mode));
  }
}

/// Da acceso al [AppearanceController] desde cualquier pantalla.
class AppearanceScope extends InheritedNotifier<AppearanceController> {
  const AppearanceScope({
    super.key,
    required AppearanceController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppearanceController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AppearanceScope>()
      ?.notifier;
}
