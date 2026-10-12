import 'package:flutter/material.dart';

import 'home_page.dart';
import 'my_club_page.dart';
import 'standings_page.dart';
import 'clubs_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MyClubPage(),
    const StandingsPage(),
    const ClubsPage(),
  ];

  final List<String> _titles = [
    'ANFA Chiguayante',
    'Mi Club',
    'Tabla General',
    'Clubes',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Fixture',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Mi Club',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Tabla',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Clubes',
          ),
        ],
      ),
    );
  }
}