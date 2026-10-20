import 'package:flutter/material.dart';

import 'pages/main_page.dart';
import 'services/appearance_service.dart';
import 'theme/app_theme.dart';
import 'widgets/clubs_scope.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Por defecto, automático (sigue el modo del teléfono).
  final _appearance = AppearanceController();

  @override
  void initState() {
    super.initState();
    _appearance.load();
  }

  @override
  void dispose() {
    _appearance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _appearance,
      builder: (context, mode, _) => MaterialApp(
        title: 'ANFA Chiguayante',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(Brightness.light),
        darkTheme: buildAppTheme(Brightness.dark),
        themeMode: mode,
        // Sobre el Navigator: disponible también en pantallas abiertas
        // con Navigator.push (detalle, ficha, Ajustes).
        builder: (context, child) => AppearanceScope(
          controller: _appearance,
          child: ClubsLoader(child: child ?? const SizedBox.shrink()),
        ),
        home: const MainPage(),
      ),
    );
  }
}
