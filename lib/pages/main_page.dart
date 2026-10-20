import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'clubs_page.dart';
import 'home_page.dart';
import 'inicio_page.dart';
import 'news_page.dart';
import 'settings_page.dart';
import 'standings_page.dart';

/// Navegación principal: barra inferior de 5 pestañas (`docs/diseno.md` 2).
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const int inicioIndex = 0;
  static const int fixtureIndex = 1;
  static const int standingsIndex = 2;

  int _selectedIndex = inicioIndex;

  /// Cambia al volver de Ajustes con otro equipo, para recargar Inicio.
  int _inicioVersion = 0;

  final List<String> _titles = [
    'ANFA Chiguayante',
    'Fixture',
    'Tabla de posiciones',
    'Noticias',
    'Clubes',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _openSettings() async {
    final teamChanged = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );

    if (teamChanged == true && mounted) {
      setState(() => _inicioVersion++);
    }
  }

  Widget _page(int index) {
    switch (index) {
      case inicioIndex:
        return InicioPage(
          key: ValueKey(_inicioVersion),
          onOpenFixture: () => _onItemTapped(fixtureIndex),
          onOpenStandings: () => _onItemTapped(standingsIndex),
        );
      case fixtureIndex:
        return const HomePage();
      case standingsIndex:
        return const StandingsPage();
      case 3:
        return const NewsPage();
      default:
        return const ClubsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          if (_selectedIndex == inicioIndex)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                tooltip: 'Ajustes y apariencia',
                icon: const Icon(Icons.tune_rounded),
                onPressed: _openSettings,
              ),
            ),
        ],
      ),
      body: _page(_selectedIndex),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedIndex,
        onSelected: _onItemTapped,
        items: const [
          AppNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Inicio',
          ),
          AppNavItem(
            icon: Icons.calendar_month_outlined,
            selectedIcon: Icons.calendar_month_rounded,
            label: 'Fixture',
          ),
          AppNavItem(
            icon: Icons.format_list_numbered_rounded,
            selectedIcon: Icons.format_list_numbered_rounded,
            label: 'Tabla',
          ),
          AppNavItem(
            icon: Icons.newspaper_outlined,
            selectedIcon: Icons.newspaper_rounded,
            label: 'Noticias',
          ),
          AppNavItem(
            icon: Icons.shield_outlined,
            selectedIcon: Icons.shield_rounded,
            label: 'Clubes',
          ),
        ],
      ),
    );
  }
}
