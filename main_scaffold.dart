import 'package:flutter/material.dart';

import 'screens/explorer_screen.dart';
import 'screens/earth_view_screen.dart';
import 'screens/asteroid_tracker_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/bottom_nav_bar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey(DateTime.now()), 

      extendBody: true,
      backgroundColor: Colors.transparent,

      body: IndexedStack(
        index: _currentIndex,
        children: [
          ExplorerScreen(
            key: ValueKey(_currentIndex == 0),
            resetStarred: true,
          ),

        
          EarthViewScreen(
            key: ValueKey('earth_${_currentIndex}_${DateTime.now()}'),
          ),

          AsteroidTrackerScreen(
            key: ValueKey(_currentIndex == 2),
            resetReminders: true,
          ),

          const SettingsScreen(),
        ],
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}