import 'package:flutter/material.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/app_header.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  static const String routeName = '/privacy-policy';

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
                  Text('Privacy Policy', style: AppTextStyles.heading.copyWith(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text('ShelfSight stores authentication profiles and shelf scan reports in Firebase for the project demo.', style: AppTextStyles.body),
                  const SizedBox(height: 22),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PolicyBlock(title: 'Images', body: 'Shelf images are saved as Firebase Storage URLs when captured from the device, while seeded demo records may reference packaged assets.'),
                        _PolicyBlock(title: 'Metrics', body: 'Product count, SOS, OSA, and compliance values are saved with each scan document and can be updated from the scan detail screen.'),
                        _PolicyBlock(title: 'Account', body: 'Profile details are read from the Firebase users collection after sign in.'),
                        _PolicyBlock(title: 'Sharing', body: 'Scan reports can be created, read, updated, and deleted through the app UI.'),
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

class _PolicyBlock extends StatelessWidget {
  const _PolicyBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(body, style: AppTextStyles.body.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
