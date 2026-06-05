import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_fonts.dart';
import 'package:shelf_sight_ui_implementation/features/auth/domain/repositories/auth_repository.dart';
import 'package:shelf_sight_ui_implementation/features/scans/domain/repositories/scan_repository.dart';
import 'package:shelf_sight_ui_implementation/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:shelf_sight_ui_implementation/features/scans/data/repositories/firebase_scan_repository.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/providers/auth_provider.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/providers/shelf_analysis_provider.dart';
import 'package:shelf_sight_ui_implementation/core/presentation/providers/theme_provider.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/screens/login_screen.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/screens/signup_screen.dart';
import 'package:shelf_sight_ui_implementation/features/home/presentation/screens/main_shell_screen.dart';
import 'package:shelf_sight_ui_implementation/features/profile/presentation/screens/account_screen.dart';
import 'package:shelf_sight_ui_implementation/features/profile/presentation/screens/notifications_screen.dart';
import 'package:shelf_sight_ui_implementation/features/profile/presentation/screens/settings_screen.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/screens/preview_screen.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/screens/results_screen.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/screens/scan_detail_screen.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/screens/scans_screen.dart';
import 'package:shelf_sight_ui_implementation/features/splash/presentation/screens/splash_screen.dart';
import 'package:shelf_sight_ui_implementation/features/support/presentation/screens/help_center_screen.dart';
import 'package:shelf_sight_ui_implementation/features/support/presentation/screens/privacy_policy_screen.dart';
import 'package:shelf_sight_ui_implementation/features/admin/presentation/screens/admin_shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
    runApp(FirebaseConfigurationErrorApp(error: e.toString()));
    return;
  }

  runApp(
    ShelfSightApp(
      authRepository: FirebaseAuthRepository(),
      scanRepository: FirebaseScanRepository(),
    ),
  );
}


class FirebaseConfigurationErrorApp extends StatelessWidget {
  final String error;

  const FirebaseConfigurationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 54, color: AppColors.primary),
                  const SizedBox(height: 18),
                  const Text(
                    'Firebase is not configured',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Run the Firebase setup commands from FIREBASE_CONNECT_AND_TEST.md, then run the app again. The app intentionally does not fall back to local mock repositories for final grading.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  SelectableText(
                    error,
                    style: const TextStyle(fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShelfSightApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ScanRepository scanRepository;
  const ShelfSightApp({super.key, required this.authRepository, required this.scanRepository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<ScanRepository>.value(value: scanRepository),
        ChangeNotifierProvider<AuthProvider>(create: (context) => AuthProvider(authRepository)),
        ChangeNotifierProxyProvider<AuthProvider, ShelfAnalysisProvider>(
          create: (context) => ShelfAnalysisProvider(scanRepository),
          update: (context, authProvider, shelfProvider) {
            shelfProvider!.setUserId(authProvider.currentUser?.uid, authProvider.isAdmin);
            return shelfProvider;
          },
        ),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ShelfSight',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: AppColors.background,
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
              fontFamily: AppFonts.primary,
              navigationBarTheme: const NavigationBarThemeData(
                labelTextStyle: WidgetStatePropertyAll(
                  TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                ),
              ),
              snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.darkBackground,
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark)
                  .copyWith(surface: AppColors.darkSurface, primary: AppColors.primaryBright),
              fontFamily: AppFonts.primary,
              snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
            ),
            initialRoute: SplashScreen.routeName,
            routes: {
              SplashScreen.routeName: (_) => const SplashScreen(),
              LoginScreen.routeName: (_) => const LoginScreen(),
              SignupScreen.routeName: (_) => const SignupScreen(),
              ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
              MainShellScreen.routeName: (_) => const MainShellScreen(),
              PreviewScreen.routeName: (_) => const PreviewScreen(),
              ResultsScreen.routeName: (_) => const ResultsScreen(),
              SettingsScreen.routeName: (_) => const SettingsScreen(),
              AccountScreen.routeName: (_) => const AccountScreen(),
              NotificationsScreen.routeName: (_) => const NotificationsScreen(),
              HelpCenterScreen.routeName: (_) => const HelpCenterScreen(),
              PrivacyPolicyScreen.routeName: (_) => const PrivacyPolicyScreen(),
              ScanDetailScreen.routeName: (_) => const ScanDetailScreen(),
              ScansScreen.routeName: (_) => const ScansScreen(),
              AdminShellScreen.routeName: (_) => const AdminShellScreen(),
            },
          );
        },
      ),
    );
  }
}
