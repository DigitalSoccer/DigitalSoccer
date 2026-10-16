import 'package:flutter/material.dart';

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
    'Tabla General',
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
        return InicioPage(
          onOpenFixture: () => _onItemTapped(fixtureIndex),
        );
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
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: _page(_selectedIndex),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.sports_soccer_outlined),
              selectedIcon: Icon(Icons.sports_soccer),
              label: 'Fixture',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events),
              label: 'Tabla',
            ),
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: 'Clubes',
            ),
          ],
        ),
      ),
    );
  }
}
