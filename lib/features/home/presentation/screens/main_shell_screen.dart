import 'package:flutter/material.dart';

import 'package:shelf_sight_ui_implementation/presentation/widgets/shelf_bottom_navigation.dart';
import 'package:shelf_sight_ui_implementation/features/home/presentation/screens/dashboard_screen.dart';
import 'package:shelf_sight_ui_implementation/features/home/presentation/screens/home_screen.dart';
import 'package:shelf_sight_ui_implementation/features/profile/presentation/screens/profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key, this.initialIndex = 0});
  static const String routeName = '/main';

  final int initialIndex;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _index;

  final List<Widget> _screens = const [
    HomeScreen(),
    DashboardScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _screens[_index],
      bottomNavigationBar: ShelfBottomNavigation(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}
