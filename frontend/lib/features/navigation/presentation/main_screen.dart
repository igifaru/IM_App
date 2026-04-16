import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../home/presentation/home_screen.dart';
import '../../prediction/presentation/prediction_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../calendar/presentation/calendar_screen.dart';
import '../../settings/presentation/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PredictionScreen(),
    const HistoryScreen(),
    const CalendarScreen(),
    const SettingsScreen(),
  ];

  void setTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: 'home'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.add_chart_outlined),
                activeIcon: const Icon(Icons.add_chart),
                label: 'predict'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history_outlined),
                activeIcon: const Icon(Icons.history),
                label: 'history'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_month_outlined),
                activeIcon: const Icon(Icons.calendar_month),
                label: 'calendar'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings),
                label: 'settings'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
