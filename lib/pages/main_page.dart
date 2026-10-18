import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
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

  Widget _page(int index) {
    switch (index) {
      case 0:
        return InicioPage(onOpenFixture: () => _onItemTapped(fixtureIndex));
      case fixtureIndex:
        return const HomePage();
      case 2:
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
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: AppShadows.navBar,
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Fixture',
            ),
            NavigationDestination(
              icon: Icon(Icons.leaderboard_outlined),
              selectedIcon: Icon(Icons.leaderboard_rounded),
              label: 'Tabla',
            ),
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield_rounded),
              label: 'Clubes',
            ),
          ],
        ),
      ),
    );
  }
}
