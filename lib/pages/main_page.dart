import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'clubs_page.dart';
import 'home_page.dart';
import 'inicio_page.dart';
import 'standings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const int fixtureIndex = 1;

  int _selectedIndex = 0;

  final List<String> _titles = [
    'ANFA Chiguayante',
    'Fixture',
    'Tabla de posiciones',
    'Clubes',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const int standingsIndex = 2;

  Widget _page(int index) {
    switch (index) {
      case 0:
        return InicioPage(
          onOpenFixture: () => _onItemTapped(fixtureIndex),
          onOpenStandings: () => _onItemTapped(standingsIndex),
        );
      case fixtureIndex:
        return const HomePage();
      case standingsIndex:
        return const StandingsPage();
      default:
        return const ClubsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
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
            icon: Icons.shield_outlined,
            selectedIcon: Icons.shield_rounded,
            label: 'Clubes',
          ),
        ],
      ),
    );
  }
}
