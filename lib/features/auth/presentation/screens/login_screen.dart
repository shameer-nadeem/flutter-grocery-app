import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/providers/auth_provider.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/app_header.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/primary_button.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';
import 'package:shelf_sight_ui_implementation/features/admin/presentation/screens/admin_shell_screen.dart';
import 'package:shelf_sight_ui_implementation/features/home/presentation/screens/main_shell_screen.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateAfterLogin() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null && mounted) {
      if (user.role == 'admin') {
        Navigator.pushNamedAndRemoveUntil(
            context, AdminShellScreen.routeName, (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, MainShellScreen.routeName, (route) => false);
      }
    }
  }

  void _showError(String? message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Authentication failed.'),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (success) {
        _navigateAfterLogin();
      } else {
        _showError(authProvider.errorMessage);
      }
    }
  }

  void _googleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();
    if (success) {
      _navigateAfterLogin();
    } else if (authProvider.errorMessage != null) {
      _showError(authProvider.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return PageFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            const AppHeader(showBack: true, showProfile: true),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 54,
              backgroundColor: const Color(0xFFEAE7E7),
              child: Container(
                height: 92,
                width: 92,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.primarySoft),
                child: const Icon(Icons.storefront_rounded,
                    color: AppColors.primary, size: 48),
              ),
            ),
            const SizedBox(height: 24),
            Text('Welcome Back',
                style: AppTextStyles.title.copyWith(fontSize: 28)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Sign in to manage your inventory and shelf health.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
            ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SoftCard(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email Address', style: _fieldLabelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        decoration:
                            _inputDecoration('name@company.com', Icons.email),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Text('Password', style: _fieldLabelStyle),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, ForgotPasswordScreen.routeName),
                            child: const Text('Forgot?',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      TextFormField(
                        obscureText: _obscurePassword,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        decoration: _inputDecoration(
                          '••••••••',
                          Icons.lock,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Login',
                        isLoading: authProvider.isLoading,
                        onPressed: authProvider.isLoading ? null : _login,
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: OutlinedButton(
                          onPressed:
                              authProvider.isLoading ? null : _googleLogin,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 22,
                                      width: 22,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4285F4),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'G',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                          color: AppColors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, SignupScreen.routeName),
              child: const Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 17),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const TextStyle _fieldLabelStyle = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 16,
  color: AppColors.textPrimary,
);

InputDecoration _inputDecoration(String hint, IconData icon,
    {Widget? suffixIcon}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColors.textSecondary),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.surfaceMuted,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide.none,
    ),
    contentPadding:
        const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
  );
}
