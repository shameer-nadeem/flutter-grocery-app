import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/core/utils/image_utils.dart';
import 'package:shelf_sight_ui_implementation/features/scans/domain/entities/scan_result_entity.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/providers/shelf_analysis_provider.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/app_header.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/shelf_bottom_navigation.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/state_views.dart';
import 'package:shelf_sight_ui_implementation/features/home/presentation/screens/main_shell_screen.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/screens/scan_detail_screen.dart';

class ScansScreen extends StatelessWidget {
  const ScansScreen({super.key, this.embedded = false});
  static const String routeName = '/scans';

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShelfAnalysisProvider>();
    final scans = provider.scanHistory;

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!embedded) const AppHeader(showBack: true),
          if (!embedded) const SizedBox(height: 16),
          Text('SYSTEM OVERVIEW', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 8),
          Text('Previous Scans', style: AppTextStyles.title.copyWith(fontSize: 30)),
          const SizedBox(height: 20),
          if (provider.isFetching)
            const SizedBox(
              height: 260,
              child: LoadingStateView(message: 'Loading scan history...'),
            )
          else if (provider.errorMessage != null)
            SizedBox(
              height: 300,
              child: ErrorStateView(
                message: provider.errorMessage!,
                onRetry: provider.retryCurrentStream,
              ),
            )
          else if (scans.isEmpty)
            const SizedBox(
              height: 260,
              child: EmptyStateView(
                title: 'No scans yet',
                message: 'Capture or upload a shelf image to create your first Firestore scan record.',
                icon: Icons.qr_code_scanner_rounded,
              ),
            )
          else
            for (final scan in scans) _ScanTile(scan: scan),
        ],
      ),
    );

    if (embedded) {
      return SingleChildScrollView(padding: const EdgeInsets.only(bottom: 110), child: content);
    }

    return PageFrame(
      safeBottom: false,
      bottomNavigationBar: ShelfBottomNavigation(
        selectedIndex: 1,
        onDestinationSelected: (index) => _openShell(context, index),
      ),
      child: SingleChildScrollView(padding: const EdgeInsets.only(bottom: 28), child: content),
    );
  }

  void _openShell(BuildContext context, int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainShellScreen(initialIndex: index)),
      (route) => false,
    );
  }
}

class _ScanTile extends StatelessWidget {
  const _ScanTile({required this.scan});

  final ScanResultEntity scan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
        padding: const EdgeInsets.all(12),
        radius: 4,
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
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(scan.subtitle, style: AppTextStyles.body),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
