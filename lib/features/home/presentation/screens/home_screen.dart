import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/utils/image_utils.dart';
import 'package:shelf_sight_ui_implementation/features/scans/domain/entities/scan_result_entity.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/providers/auth_provider.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/providers/shelf_analysis_provider.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/screens/preview_screen.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/screens/scan_detail_screen.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/screens/scans_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shelfProvider = context.watch<ShelfAnalysisProvider>();
    final scans = shelfProvider.scanHistory;
    final user = context.watch<AuthProvider>().currentUser;
    final userName = user?.name ?? 'User';

    return PageFrame(
      safeBottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 26, 28, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning, $userName',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text('Shelf Health Overview',
                          style: AppTextStyles.heading.copyWith(fontSize: 26)),
                      const SizedBox(height: 6),
                      Text(
                        'Choose how you want to capture or upload below to start scanning.',
                        style: AppTextStyles.body.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryBright,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    onPressed: () =>
                        _message(context, 'No new notifications'),
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ActionCard(
              icon: Icons.camera_alt,
              title: 'Open Camera',
              subtitle: 'Real-time shelf scanning',
              highlighted: true,
              isLoading: shelfProvider.isPickingImage,
              onTap: shelfProvider.isPickingImage
                  ? null
                  : () async {
                      final analysisProvider = context.read<ShelfAnalysisProvider>();
                      final path = await analysisProvider.pickImage(ImageSource.camera);
                      if (path != null && context.mounted) {
                        Navigator.pushNamed(context, PreviewScreen.routeName);
                      } else if (analysisProvider.errorMessage != null && context.mounted) {
                        _message(context, analysisProvider.errorMessage!);
                      }
                    },
            ),
            const SizedBox(height: 18),
            _ActionCard(
              icon: Icons.upload_file,
              title: 'Upload Gallery',
              subtitle: 'Process saved shelf images',
              highlighted: false,
              isLoading: shelfProvider.isPickingImage,
              onTap: shelfProvider.isPickingImage
                  ? null
                  : () async {
                      final analysisProvider = context.read<ShelfAnalysisProvider>();
                      final path = await analysisProvider.pickImage(ImageSource.gallery);
                      if (path != null && context.mounted) {
                        Navigator.pushNamed(context, PreviewScreen.routeName);
                      } else if (analysisProvider.errorMessage != null && context.mounted) {
                        _message(context, analysisProvider.errorMessage!);
                      }
                    },
            ),
            (() {
              final averageAccuracy = scans.isNotEmpty
                  ? (scans
                              .map((s) => s.compliance)
                              .reduce((a, b) => a + b) /
                          scans.length)
                      .round()
                  : (user?.scanAccuracy ?? 0).round();

              String lastUpdatedText = 'No scans performed yet.';
              if (scans.isNotEmpty) {
                final latestScan = scans.first;
                final diff = DateTime.now().difference(latestScan.timestamp);
                final minutes = diff.inMinutes;
                if (minutes < 1) {
                  lastUpdatedText =
                      'Last updated just now for ${latestScan.title}.';
                } else if (minutes < 60) {
                  lastUpdatedText =
                      'Last updated $minutes minutes ago for ${latestScan.title}.';
                } else {
                  final hours = diff.inHours;
                  lastUpdatedText =
                      'Last updated $hours hours ago for ${latestScan.title}.';
                }
              }

              return SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Current Shelf\nHealth',
                            style: AppTextStyles.heading
                                .copyWith(fontSize: 24, height: 1.15),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            '$averageAccuracy%\nACCURACY',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: averageAccuracy / 100.0,
                        minHeight: 10,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(lastUpdatedText, style: AppTextStyles.body),
                  ],
                ),
              );
            })(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Audits',
                    style: AppTextStyles.heading.copyWith(fontSize: 20)),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, ScansScreen.routeName),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (scans.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                child: Text(
                  'No recent audits. Capture or upload a photo to start.',
                  style:
                      AppTextStyles.body.copyWith(fontStyle: FontStyle.italic),
                ),
              )
            else
              for (final scan in scans.take(3)) _AuditTile(scan: scan),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.highlighted,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlighted;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor:
                highlighted ? AppColors.primaryBright : const Color(0xFFEAE7E7),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
                  )
                : Icon(
                    icon,
                    color: highlighted ? AppColors.primary : AppColors.textSecondary,
                    size: 32,
                  ),
          ),
          const SizedBox(height: 18),
          Text(title,
              style: AppTextStyles.heading.copyWith(fontSize: 24)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: AppTextStyles.body, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.scan});

  final ScanResultEntity scan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
        padding: const EdgeInsets.all(12),
        radius: 22,
        onTap: () {
          context.read<ShelfAnalysisProvider>().selectScan(scan);
          Navigator.pushNamed(context, ScanDetailScreen.routeName);
        },
        child: Row(
          children: [
            ScanImage(
              imagePath: scan.imagePath,
              width: 58,
              height: 58,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scan.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(scan.subtitle,
                      style: AppTextStyles.body.copyWith(fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

void _message(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}
