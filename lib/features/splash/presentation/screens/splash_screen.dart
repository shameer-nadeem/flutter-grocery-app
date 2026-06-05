import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_assets.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/providers/auth_provider.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/screens/login_screen.dart';
import 'package:shelf_sight_ui_implementation/features/home/presentation/screens/main_shell_screen.dart';
import 'package:shelf_sight_ui_implementation/features/admin/presentation/screens/admin_shell_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _fallbackTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _listenAndNavigate());
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  void _listenAndNavigate() {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isLoading) {
      _navigate(authProvider);
      return;
    }

    void listener() {
      if (!authProvider.isLoading && mounted) {
        authProvider.removeListener(listener);
        _navigate(authProvider);
      }
    }

    authProvider.addListener(listener);
    _fallbackTimer = Timer(const Duration(seconds: 5), () {
      authProvider.removeListener(listener);
      if (mounted) _navigate(authProvider);
    });
  }

  void _navigate(AuthProvider authProvider) {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    _fallbackTimer?.cancel();

    final user = authProvider.currentUser;
    if (user != null) {
      Navigator.pushReplacementNamed(
        context,
        user.role == 'admin'
            ? AdminShellScreen.routeName
            : MainShellScreen.routeName,
      );
    } else {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 44),
        child: Column(
          children: [
            const Spacer(flex: 3),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 108,
                  width: 108,
                  decoration: const BoxDecoration(
                      color: Colors.black, shape: BoxShape.circle),
                  child: Center(
                    child: Image.asset(AppAssets.appIcon, height: 56, width: 56),
                  ),
                ),
                const Positioned(
                  right: -2,
                  top: 10,
                  child: CircleAvatar(
                      radius: 11, backgroundColor: AppColors.primaryBright),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'ShelfSight',
              style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black),
            ),
            const SizedBox(height: 10),
            const Text(
              'RETAIL INTELLIGENCE PLATFORM',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 3,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 34),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryBright),
              ),
            ),
            const Spacer(flex: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Enterprise Secured',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            const Text('v4.2.0-stable',
                style: TextStyle(color: AppColors.textMuted, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
