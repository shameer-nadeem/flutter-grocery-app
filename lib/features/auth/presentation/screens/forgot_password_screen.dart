import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/providers/auth_provider.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/app_header.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/primary_button.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  static const String routeName = '/forgot-password';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success =
          await authProvider.sendPasswordReset(_emailController.text.trim());
      if (success && mounted) {
        setState(() => _submitted = true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to send reset link.'),
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
            const AppHeader(showBack: true, showProfile: true),
            const SizedBox(height: 34),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(
                      _submitted ? Icons.mark_email_read : Icons.lock_reset,
                      color: AppColors.primary,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _submitted ? 'Check Your Email' : 'Reset Password',
                    style: AppTextStyles.heading.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _submitted
                        ? 'A reset link has been sent to ${_emailController.text}. Check your inbox.'
                        : 'Enter your registered email and we will send a secure reset link.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 24),
                  SoftCard(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EMAIL ADDRESS',
                            style: TextStyle(
                                letterSpacing: 1.2,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_submitted,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'name@company.com',
                              prefixIcon: const Icon(Icons.email,
                                  color: AppColors.textSecondary),
                              filled: true,
                              fillColor: AppColors.surfaceMuted,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 22),
                          PrimaryButton(
                            label: _submitted
                                ? 'Back to Login'
                                : 'Send Reset Link',
                            icon: Icons.arrow_forward,
                            isLoading: authProvider.isLoading,
                            onPressed: authProvider.isLoading
                                ? null
                                : () {
                                    if (_submitted) {
                                      Navigator.pop(context);
                                    } else {
                                      _sendReset();
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
