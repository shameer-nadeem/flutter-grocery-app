import 'package:flutter/material.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/app_header.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});
  static const String routeName = '/help-center';

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
                  Text('Help Center', style: AppTextStyles.heading.copyWith(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text('Quick support topics for the ShelfSight UI flow.', style: AppTextStyles.body),
                  const SizedBox(height: 22),
                  const _HelpTile(
                    icon: Icons.camera_alt_outlined,
                    title: 'Scanning a shelf',
                    subtitle: 'Use clear lighting and keep products visible inside the preview frame.',
                  ),
                  const _HelpTile(
                    icon: Icons.image_outlined,
                    title: 'Uploading from gallery',
                    subtitle: 'Choose a front-facing shelf photo for more accurate metrics.',
                  ),
                  const _HelpTile(
                    icon: Icons.share_outlined,
                    title: 'Sharing a report',
                    subtitle: 'Open any scan detail to review, edit, delete, or share a Firebase-backed report.',
                  ),
                  const _HelpTile(
                    icon: Icons.error_outline,
                    title: 'Validation errors',
                    subtitle: 'Forms highlight missing or incorrect fields before moving ahead.',
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

class _HelpTile extends StatelessWidget {
  const _HelpTile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primarySoft,
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.body.copyWith(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
