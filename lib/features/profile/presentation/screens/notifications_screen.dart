import 'package:flutter/material.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/app_header.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  static const String routeName = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool lowStock = true;
  bool scanComplete = true;
  bool weeklyReport = false;

  @override
  Widget build(BuildContext context) {
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
                  Text('Notifications', style: AppTextStyles.heading.copyWith(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text('Choose which ShelfSight alerts should appear in the app.', style: AppTextStyles.body),
                  const SizedBox(height: 22),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _SwitchRow(
                          icon: Icons.warning_amber_rounded,
                          title: 'Low Stock Alerts',
                          subtitle: 'Notify when OSA drops below target.',
                          value: lowStock,
                          onChanged: (value) => setState(() => lowStock = value),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        _SwitchRow(
                          icon: Icons.check_circle_outline,
                          title: 'Scan Complete',
                          subtitle: 'Show a prompt when analysis is finished.',
                          value: scanComplete,
                          onChanged: (value) => setState(() => scanComplete = value),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        _SwitchRow(
                          icon: Icons.insights,
                          title: 'Weekly Report',
                          subtitle: 'Receive weekly shelf health summaries.',
                          value: weeklyReport,
                          onChanged: (value) => setState(() => weeklyReport = value),
                        ),
                      ],
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

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceMuted,
          child: Icon(icon, color: AppColors.textSecondary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        subtitle: Text(subtitle),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
