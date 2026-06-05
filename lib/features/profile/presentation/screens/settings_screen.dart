import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/core/presentation/providers/theme_provider.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/app_header.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

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
                  Text('Settings', style: AppTextStyles.heading.copyWith(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text('Interface preferences for the ShelfSight demo.', style: AppTextStyles.body),
                  const SizedBox(height: 22),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          secondary: const CircleAvatar(
                            backgroundColor: AppColors.surfaceMuted,
                            child: Icon(Icons.dark_mode, color: AppColors.textSecondary),
                          ),
                          title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: const Text('Reduced glare interface'),
                          value: themeProvider.isDarkMode,
                          onChanged: themeProvider.setDarkMode,
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        const ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.surfaceMuted,
                            child: Icon(Icons.text_fields, color: AppColors.textSecondary),
                          ),
                          title: Text('Typography', style: TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text('Clean mobile-first type scale'),
                          trailing: Text('Default', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        const ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.surfaceMuted,
                            child: Icon(Icons.palette_outlined, color: AppColors.textSecondary),
                          ),
                          title: Text('Brand Theme', style: TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text('Black, white, soft blush, and green accents'),
                          trailing: Icon(Icons.check_circle, color: AppColors.primary),
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
