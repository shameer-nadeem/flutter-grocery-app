import 'package:flutter/material.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';

class ShelfBottomNavigation extends StatelessWidget {
  const ShelfBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      height: 76,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primarySoft,
      surfaceTintColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
          label: 'HOME',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart_rounded, color: AppColors.primary),
          label: 'HISTORY',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppColors.primary),
          label: 'PROFILE',
        ),
      ],
    );
  }
}
