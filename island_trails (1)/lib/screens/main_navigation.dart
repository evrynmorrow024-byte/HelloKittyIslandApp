import 'package:flutter/material.dart';
import 'package:island_trails/screens/dashboard_screen.dart';
import 'package:island_trails/screens/daily_checklist_screen.dart';
import 'package:island_trails/screens/quest_tracker_screen.dart';
import 'package:island_trails/screens/friendship_tracker_screen.dart';
import 'package:island_trails/screens/collectibles_screen.dart';
import 'package:island_trails/screens/visitors_screen.dart';
import 'package:island_trails/theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const DailyChecklistScreen(),
    const QuestTrackerScreen(),
    const FriendshipTrackerScreen(),
    const CollectiblesScreen(),
    const VisitorsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: SanrioColors.surface,
          boxShadow: [
            BoxShadow(
              color: SanrioColors.lightShadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, '🌸', 'Home'),
                _buildNavItem(1, '✅', 'Daily'),
                _buildNavItem(2, '🎁', 'Quests'),
                _buildNavItem(3, '🎂', 'Friends'),
                _buildNavItem(4, '📸', 'Items'),
                _buildNavItem(5, '🏡', 'Visitors'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String emoji, String label) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? SanrioColors.pastelPink : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: isSelected ? 22 : 18,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? SanrioColors.brightPink : SanrioColors.lightText,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}