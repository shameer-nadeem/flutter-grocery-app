import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/providers/auth_provider.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/app_header.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/primary_button.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';
import 'package:shelf_sight_ui_implementation/features/home/presentation/screens/main_shell_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  static const String routeName = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        role: 'user', // default role is standard user/associate
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );
        Navigator.pushNamedAndRemoveUntil(context, MainShellScreen.routeName, (route) => false);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Sign up failed.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return PageFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          children: [
            const AppHeader(showBack: true),
            const SizedBox(height: 12),
            Text('Join the Fleet', style: AppTextStyles.heading.copyWith(fontSize: 24)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                'Streamline your inventory management with professional-grade intelligence.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(fontSize: 17),
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SoftCard(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SignupField(
                        label: 'FULL NAME',
                        hint: 'Enter your full name',
                        icon: Icons.person,
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),
                      _SignupField(
                        label: 'EMAIL ADDRESS',
                        hint: 'name@company.com',
                        icon: Icons.email,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email address is required';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      _SignupField(
                        label: 'PASSWORD',
                        hint: 'Min. 6 characters',
                        icon: Icons.lock,
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      _SignupField(
                        label: 'CONFIRM PASSWORD',
                        hint: 'Repeat your password',
                        icon: Icons.verified_user,
                        controller: _confirmPasswordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm password is required';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: 'Sign Up',
                        icon: Icons.arrow_forward,
                        isLoading: authProvider.isLoading,
                        onPressed: authProvider.isLoading ? null : _submit,
                      ),
                      const SizedBox(height: 18),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 18),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text.rich(
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                              children: [
                                TextSpan(text: 'Log In', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: const [
                  Expanded(child: _MiniFeature(icon: Icons.inventory_2_outlined, title: 'REAL-TIME SYNC')),
                  SizedBox(width: 16),
                  Expanded(child: _MiniFeature(icon: Icons.auto_graph, title: 'AI PREDICTIONS')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignupField extends StatefulWidget {
  const _SignupField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  @override
  State<_SignupField> createState() => _SignupFieldState();
}

class _SignupFieldState extends State<_SignupField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(letterSpacing: 1.2, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: Icon(widget.icon, color: AppColors.textSecondary),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceMuted,
              errorMaxLines: 2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniFeature extends StatelessWidget {
  const _MiniFeature({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ],
      ),
    );
  }
}
