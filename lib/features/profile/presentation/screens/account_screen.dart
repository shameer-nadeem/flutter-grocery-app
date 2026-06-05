import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/providers/auth_provider.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/app_header.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/primary_button.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  static const String routeName = '/account';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final name = user?.name ?? 'User';
    final email = user?.email ?? '';
    final role = user?.role == 'admin' ? 'Administrator' : 'Store Associate';
    final accessLevel = user?.role == 'admin' ? 'Admin' : 'Associate';

    return PageFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          children: [
            const AppHeader(showBack: true, showProfile: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account', style: AppTextStyles.heading.copyWith(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text('Personal information and security details.', style: AppTextStyles.body),
                  const SizedBox(height: 22),
                  SoftCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Name', value: name),
                        const Divider(color: AppColors.border),
                        _InfoRow(label: 'Email', value: email),
                        const Divider(color: AppColors.border),
                        _InfoRow(label: 'Role', value: role),
                        const Divider(color: AppColors.border),
                        _InfoRow(label: 'Access Level', value: accessLevel),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SoftCard(
                    color: AppColors.primarySoft,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.verified_user, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Two-factor authentication is enabled for this demo account.',
                            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: 'Save Changes',
                    icon: Icons.check,
                    onPressed: () => _message(context, 'Account changes saved'),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700))),
          const SizedBox(width: 12),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

void _message(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
