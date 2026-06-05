import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/core/utils/image_utils.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/providers/shelf_analysis_provider.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/app_header.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/metric_card.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/primary_button.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/responsive_card_grid.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/state_views.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/shelf_bottom_navigation.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';
import 'package:shelf_sight_ui_implementation/features/home/presentation/screens/main_shell_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});
  static const String routeName = '/results';

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ShelfAnalysisProvider>().selectedScan;

    if (scan == null) {
      return const Scaffold(
        body: LoadingStateView(message: 'Preparing scan result...'),
      );
    }

    return PageFrame(
      safeBottom: false,
      bottomNavigationBar: ShelfBottomNavigation(
        selectedIndex: 1,
        onDestinationSelected: (index) => _openShell(context, index),
      ),
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
                  Stack(
                    children: [
                      ScanImage(
                        imagePath: scan.imagePath,
                        width: double.infinity,
                        height: 250,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      Positioned(
                        left: 18,
                        bottom: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle,
                                  size: 16, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'SCAN COMPLETE',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ResponsiveCardGrid(
                    minTileWidth: 165,
                    childAspectRatio: 1.1,
                    children: [
                      MetricCard(
                          icon: Icons.inventory_2_outlined,
                          label: 'Product Count',
                          value: '${scan.productCount}',
                          valueColor: AppColors.black),
                      MetricCard(
                          icon: Icons.pie_chart,
                          label: 'Share of Shelf',
                          value: '${scan.shareOfShelf}%'),
                      MetricCard(
                          icon: Icons.show_chart,
                          label: 'On-Shelf Availability',
                          value: '${scan.onShelfAvailability}%'),
                      MetricCard(
                          icon: Icons.verified,
                          label: 'Compliance',
                          value: '${scan.compliance}%'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SoftCard(
                    color: const Color(0xFFF0F4F1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_graph,
                                color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(
                              'Recommendation',
                              style: AppTextStyles.heading.copyWith(
                                  fontSize: 18, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          scan.recommendation,
                          style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary, height: 1.55),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Detailed Shelf Health',
                      style: AppTextStyles.heading.copyWith(fontSize: 18)),
                  const SizedBox(height: 12),
                  SoftCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'CATEGORY ACCURACY',
                                style: TextStyle(
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    fontSize: 12),
                              ),
                            ),
                            Text('${scan.compliance}%',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: scan.compliance / 100.0,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: 'Share Result',
                    icon: Icons.ios_share,
                    onPressed: () =>
                        _message(context, 'Report ready to share.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openShell(BuildContext context, int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (_) => MainShellScreen(initialIndex: index)),
      (route) => false,
    );
  }
}

void _message(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}
