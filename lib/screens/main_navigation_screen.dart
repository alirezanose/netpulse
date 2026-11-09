import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'history_screen.dart';
import 'network_info_screen.dart';
import 'ping_tool_screen.dart';
import 'speed_test_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    SpeedTestScreen(),
    NetworkInfoScreen(),
    PingToolScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: AppTheme.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.speed_outlined, size: 22),
              activeIcon: Icon(Icons.speed, size: 22),
              label: 'Speed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hub_outlined, size: 22),
              activeIcon: Icon(Icons.hub, size: 22),
              label: 'Network',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.network_ping_outlined, size: 22),
              activeIcon: Icon(Icons.network_ping, size: 22),
              label: 'Ping',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined, size: 22),
              activeIcon: Icon(Icons.history, size: 22),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
