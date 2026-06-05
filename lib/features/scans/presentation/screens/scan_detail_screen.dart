import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/core/utils/image_utils.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/providers/auth_provider.dart';
import 'package:shelf_sight_ui_implementation/features/scans/domain/entities/scan_result_entity.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/providers/shelf_analysis_provider.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/app_header.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/metric_card.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/primary_button.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/shelf_bottom_navigation.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';
import 'package:shelf_sight_ui_implementation/features/home/presentation/screens/main_shell_screen.dart';

class ScanDetailScreen extends StatelessWidget {
  const ScanDetailScreen({super.key});
  static const String routeName = '/scan-detail';

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ShelfAnalysisProvider>().selectedScan;
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    if (scan == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PageFrame(
      safeBottom: false,
      bottomNavigationBar: isAdmin
          ? null
          : ShelfBottomNavigation(
              selectedIndex: 1,
              onDestinationSelected: (index) => _openShell(context, index),
            ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          children: [
            const AppHeader(showBack: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScanImage(
                    imagePath: scan.imagePath,
                    width: double.infinity,
                    height: 240,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          scan.title,
                          style: AppTextStyles.heading.copyWith(fontSize: 22),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit scan',
                        onPressed: () => _showEditDialog(context, scan),
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                      ),
                      IconButton(
                        tooltip: 'Delete scan',
                        onPressed: () => _confirmDelete(context, scan),
                        icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SCN-${scan.id.hashCode.abs().toString().padLeft(6, '0').substring(0, 6)} • ${scan.subtitle}',
                    style: AppTextStyles.body,
                  ),
                  if (scan.userName != null || scan.userEmail != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${scan.userName ?? 'ShelfSight User'}${scan.userEmail == null ? '' : ' • ${scan.userEmail}'}',
                      style: AppTextStyles.body.copyWith(fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      MetricCard(
                        icon: Icons.inventory_2_outlined,
                        label: 'Product Count',
                        value: '${scan.productCount}',
                        valueColor: AppColors.black,
                      ),
                      MetricCard(
                        icon: Icons.pie_chart_outline,
                        label: 'Share of Shelf',
                        value: '${scan.shareOfShelf}%',
                      ),
                      MetricCard(
                        icon: Icons.check_circle_outline,
                        label: 'On-Shelf Availability',
                        value: '${scan.onShelfAvailability}%',
                      ),
                      MetricCard(
                        icon: Icons.verified_outlined,
                        label: 'Compliance',
                        value: '${scan.compliance}%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SoftCard(
                    color: const Color(0xFFF1F4F0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_graph, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(
                              'Recommendation',
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          scan.recommendation,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Detailed Shelf Health',
                    style: AppTextStyles.heading.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  SoftCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'CATEGORY ACCURACY',
                                style: TextStyle(
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              '${scan.compliance}%',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: scan.compliance / 100.0,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Share Scan Detail',
                    icon: Icons.ios_share,
                    onPressed: () => _message(context, 'Report ready to share.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, ScanResultEntity scan) async {
    final titleController = TextEditingController(text: scan.title);
    final productsController = TextEditingController(text: '${scan.productCount}');
    final shareController = TextEditingController(text: '${scan.shareOfShelf}');
    final osaController = TextEditingController(text: '${scan.onShelfAvailability}');
    final complianceController = TextEditingController(text: '${scan.compliance}');
    final recommendationController = TextEditingController(text: scan.recommendation);
    final formKey = GlobalKey<FormState>();

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Edit Scan'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _EditField(label: 'Title', controller: titleController),
                    _EditField(label: 'Product Count', controller: productsController, isNumber: true),
                    _EditField(label: 'Share of Shelf %', controller: shareController, isNumber: true),
                    _EditField(label: 'OSA %', controller: osaController, isNumber: true),
                    _EditField(label: 'Compliance %', controller: complianceController, isNumber: true),
                    _EditField(label: 'Recommendation', controller: recommendationController, maxLines: 3),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  final updatedScan = scan.copyWith(
                    title: titleController.text.trim(),
                    productCount: int.parse(productsController.text.trim()),
                    shareOfShelf: int.parse(shareController.text.trim()),
                    onShelfAvailability: int.parse(osaController.text.trim()),
                    compliance: int.parse(complianceController.text.trim()),
                    recommendation: recommendationController.text.trim(),
                  );
                  final success = await context.read<ShelfAnalysisProvider>().updateScan(updatedScan);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  if (context.mounted) {
                    _message(
                      context,
                      success ? 'Scan updated in Firebase.' : context.read<ShelfAnalysisProvider>().errorMessage ?? 'Update failed.',
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    } finally {
      titleController.dispose();
      productsController.dispose();
      shareController.dispose();
      osaController.dispose();
      complianceController.dispose();
      recommendationController.dispose();
    }
  }

  Future<void> _confirmDelete(BuildContext context, ScanResultEntity scan) async {
    final shelfAnalysisProvider = context.read<ShelfAnalysisProvider>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Scan?'),
          content: Text('This will remove "${scan.title}" from Firebase.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;
    await shelfAnalysisProvider.deleteScan(scan.id);
    if (!context.mounted) return;
    _message(context, 'Scan deleted from Firebase.');
    Navigator.of(context).maybePop();
  }

  void _openShell(BuildContext context, int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainShellScreen(initialIndex: index)),
      (route) => false,
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    this.isNumber = false,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final bool isNumber;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) return '$label is required';
          if (isNumber) {
            final parsed = int.tryParse(text);
            if (parsed == null) return 'Enter a valid number';
            if (parsed < 0 || parsed > 200) return 'Enter a realistic value';
            if (label.contains('%') && parsed > 100) return 'Percentage cannot be above 100';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.surfaceMuted,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

void _message(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
