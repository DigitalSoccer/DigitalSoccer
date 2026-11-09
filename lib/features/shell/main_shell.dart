import 'package:flutter/material.dart';

import '../../shared/app_bottom_nav.dart';
import '../../shared/coming_soon.dart';
import '../mas/mas_page.dart';

/// Navegación principal: Inicio · Partidos · Tabla · Equipos · Más.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static const items = [
    AppNavItem(Icons.home_outlined, Icons.home_rounded, 'Inicio'),
    AppNavItem(Icons.calendar_month_outlined, Icons.calendar_month_rounded,
        'Partidos'),
    AppNavItem(Icons.bar_chart_rounded, Icons.bar_chart_rounded, 'Tabla'),
    AppNavItem(Icons.shield_outlined, Icons.shield_rounded, 'Equipos'),
    AppNavItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Más'),
  ];

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cada pestaña conserva su estado al cambiar de una a otra.
      body: IndexedStack(
        index: _index,
        children: const [
          ComingSoon(title: 'Inicio', stage: 3),
          ComingSoon(title: 'Partidos', stage: 3),
          ComingSoon(title: 'Clasificación', stage: 3),
          ComingSoon(title: 'Equipos', stage: 3),
          MasPage(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        items: MainShell.items,
        selectedIndex: _index,
        onSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
