import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/core/utils/image_utils.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/providers/shelf_analysis_provider.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/responsive_card_grid.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/state_views.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/screens/scan_detail_screen.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/screens/scans_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShelfAnalysisProvider>();
    final scans = provider.scanHistory;
    final totalScans = scans.length;
    final lowStockScans = scans.where((s) => s.compliance < 85).length;
    final averageCompliance = totalScans > 0
        ? scans.map((s) => s.compliance).reduce((a, b) => a + b) / totalScans
        : 0.0;

    if (provider.isFetching) {
      return const PageFrame(
        safeBottom: false,
        child: LoadingStateView(message: 'Loading latest Firestore scans...'),
      );
    }

    if (provider.errorMessage != null) {
      return PageFrame(
        safeBottom: false,
        child: ErrorStateView(
          message: provider.errorMessage!,
          onRetry: provider.retryCurrentStream,
        ),
      );
    }

    return PageFrame(
      safeBottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SYSTEM OVERVIEW', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 8),
            Text('Scan Activity',
                style: AppTextStyles.title.copyWith(fontSize: 30)),
            const SizedBox(height: 24),
            ResponsiveCardGrid(
              children: [
                _SummaryCard(
                  icon: Icons.qr_code_scanner,
                  chipLabel: 'TOTAL',
                  chipColor: const Color(0xFFE7F9EB),
                  iconColor: AppColors.primary,
                  value: '$totalScans',
                  label: 'Total Scans',
                ),
                _SummaryCard(
                  icon: Icons.warning_amber_rounded,
                  chipLabel: 'ALERT',
                  chipColor: const Color(0xFFFFEFF0),
                  iconColor: AppColors.danger,
                  value: '$lowStockScans',
                  label: 'Low Stock',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Overall Shelf Health',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        '${averageCompliance.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: AppColors.primaryBright,
                            fontSize: 24,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: averageCompliance / 100.0,
                      minHeight: 8,
                      backgroundColor: const Color(0xFF6D6D6D),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBright),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Scans',
                    style: AppTextStyles.heading.copyWith(fontSize: 22)),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, ScansScreen.routeName),
                  child: const Text(
                    'VIEW ALL',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (scans.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No scans found.',
                    style: AppTextStyles.body
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              for (final scan in scans)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SoftCard(
                    padding: const EdgeInsets.all(12),
                    radius: 4,
                    onTap: () {
                      context
                          .read<ShelfAnalysisProvider>()
                          .selectScan(scan);
                      Navigator.pushNamed(context, ScanDetailScreen.routeName);
                    },
                    child: Row(
                      children: [
                        ScanImage(
                          imagePath: scan.imagePath,
                          width: 58,
                          height: 58,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(scan.title,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(scan.subtitle,
                                  style: AppTextStyles.body),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.chipLabel,
    required this.chipColor,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String chipLabel;
  final Color chipColor;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      radius: 0,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(chipLabel,
                    style: TextStyle(
                        color: iconColor, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(value,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
