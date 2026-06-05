import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/providers/auth_provider.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/providers/shelf_analysis_provider.dart';
import 'package:shelf_sight_ui_implementation/core/presentation/providers/theme_provider.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/screens/login_screen.dart';
import 'package:shelf_sight_ui_implementation/features/support/presentation/screens/help_center_screen.dart';
import 'package:shelf_sight_ui_implementation/features/support/presentation/screens/privacy_policy_screen.dart';
import 'package:shelf_sight_ui_implementation/features/profile/presentation/screens/account_screen.dart';
import 'package:shelf_sight_ui_implementation/features/profile/presentation/screens/notifications_screen.dart';
import 'package:shelf_sight_ui_implementation/features/profile/presentation/screens/settings_screen.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final scans = context.watch<ShelfAnalysisProvider>().scanHistory;

    final name = user?.name ?? 'User';
    final role = user?.role == 'admin' ? 'Administrator' : 'Store Associate';
    final shifts = user?.shiftsCompleted ?? 0;
    final averageAccuracy = scans.isNotEmpty
        ? scans.map((s) => s.compliance).reduce((a, b) => a + b) / scans.length
        : (user?.scanAccuracy ?? 0.0);


    return PageFrame(
      safeBottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 18, 28, 110),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 52,
              backgroundColor: const Color(0xFFEAE7E7),
              child: const Icon(Icons.person, size: 54, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Text(name, style: AppTextStyles.heading.copyWith(fontSize: 24)),
            const SizedBox(height: 6),
            Text(role, style: AppTextStyles.body),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _StatCard(label: 'SCAN ACCURACY', value: '${averageAccuracy.toStringAsFixed(1)}%', valueColor: AppColors.primary)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(label: 'SHIFTS COMPLETED', value: '$shifts', valueColor: AppColors.black)),
              ],
            ),

            const SizedBox(height: 26),
            const _SectionLabel('GENERAL SETTINGS'),
            const SizedBox(height: 12),
            SoftCard(
              padding: EdgeInsets.zero,
              radius: 26,
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.person,
                    title: 'Account',
                    subtitle: 'Personal info & security',
                    onTap: () => Navigator.pushNamed(context, AccountScreen.routeName),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _SettingRow(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Alerts, updates & pushes',
                    onTap: () => Navigator.pushNamed(context, NotificationsScreen.routeName),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _SettingRow(
                    icon: Icons.settings,
                    title: 'App Settings',
                    subtitle: 'Theme and interface preferences',
                    onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFF0EEEE),
                        child: Icon(Icons.dark_mode, color: AppColors.textSecondary),
                      ),
                      title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                      subtitle: const Text('Reduced glare interface'),
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: themeProvider.setDarkMode,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const _SectionLabel('SUPPORT'),
            const SizedBox(height: 12),
            SoftCard(
              padding: EdgeInsets.zero,
              radius: 26,
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: '',
                    trailingIcon: Icons.open_in_new,
                    onTap: () => Navigator.pushNamed(context, HelpCenterScreen.routeName),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _SettingRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: '',
                    onTap: () => Navigator.pushNamed(context, PrivacyPolicyScreen.routeName),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 62,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.danger),
                label: const Text('Sign Out', style: TextStyle(color: AppColors.danger, fontSize: 18, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text('ShelfSight v2.4.12 Build 892', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.valueColor});

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w800, fontSize: 12)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w800, fontSize: 24)),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingIcon = Icons.chevron_right,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFF0EEEE),
        child: Icon(icon, color: AppColors.textSecondary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: Icon(trailingIcon, color: AppColors.textMuted),
    );
  }
}
