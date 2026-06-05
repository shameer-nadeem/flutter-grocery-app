import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shelf_sight_ui_implementation/core/constants/app_assets.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_text_styles.dart';
import 'package:shelf_sight_ui_implementation/core/utils/image_utils.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/providers/shelf_analysis_provider.dart';
import 'package:shelf_sight_ui_implementation/features/auth/presentation/providers/auth_provider.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/app_header.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/page_frame.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/primary_button.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/shelf_bottom_navigation.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';
import 'package:shelf_sight_ui_implementation/features/home/presentation/screens/main_shell_screen.dart';
import 'package:shelf_sight_ui_implementation/features/scans/presentation/screens/results_screen.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});
  static const String routeName = '/preview';

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final TextEditingController _aisleController = TextEditingController();

  @override
  void dispose() {
    _aisleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shelfProvider = context.watch<ShelfAnalysisProvider>();
    final isAnalyzing = shelfProvider.isAnalyzing;
    final isPickingImage = shelfProvider.isPickingImage;
    final pickedImagePath = shelfProvider.pickedImagePath;

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
                children: [
                  Text('Preview Capture', style: AppTextStyles.heading.copyWith(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    'Review your shelf image before analysis.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final imageHeight = (constraints.maxWidth * 0.95).clamp(250.0, 390.0).toDouble();
                      return Stack(
                        children: [
                          ScanImage(
                            imagePath: pickedImagePath ?? AppAssets.shelfEmpty,
                            height: imageHeight,
                            width: double.infinity,
                            borderRadius: BorderRadius.circular(28),
                          ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(34, 50, 34, 44),
                          child: CustomPaint(painter: _DashedFramePainter()),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        top: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'READY FOR ANALYSIS',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                          if (isAnalyzing || isPickingImage)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0x6B000000),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(color: AppColors.primaryBright),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isAnalyzing || isPickingImage
                              ? null
                              : () async {
                                  final provider = context.read<ShelfAnalysisProvider>();
                                  final path = await provider.pickImage(ImageSource.camera);
                                  if (path == null && provider.errorMessage != null && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
                                  }
                                },
                          icon: const Icon(Icons.camera_alt, color: AppColors.black),
                          label: const Text('Retake', style: TextStyle(color: AppColors.black, fontSize: 15, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(58),
                            side: const BorderSide(color: Color(0xFF999999)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isAnalyzing || isPickingImage
                              ? null
                              : () async {
                                  final provider = context.read<ShelfAnalysisProvider>();
                                  final path = await provider.pickImage(ImageSource.gallery);
                                  if (path == null && provider.errorMessage != null && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
                                  }
                                },
                          icon: const Icon(Icons.image, color: AppColors.black),
                          label: const Text('Choose\nAnother', textAlign: TextAlign.center, style: TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(58),
                            side: const BorderSide(color: Color(0xFF999999)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Aisle / location name field
                  TextField(
                    controller: _aisleController,
                    enabled: !isAnalyzing && !isPickingImage,
                    decoration: InputDecoration(
                      hintText: 'Aisle name (e.g. Aisle 4B)',
                      prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(color: Color(0xFF999999)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(color: Color(0xFF999999)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: isAnalyzing ? 'Analyzing Shelf...' : 'Continue to Analysis',
                    icon: Icons.arrow_forward,
                    isLoading: isAnalyzing,
                    onPressed: isAnalyzing || isPickingImage
                        ? null
                        : () async {
                            final authProvider = context.read<AuthProvider>();
                            final currentUser = authProvider.currentUser;

                            if (currentUser == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please log in before saving a scan.')),
                              );
                              return;
                            }

                            final targetImagePath = pickedImagePath ?? AppAssets.shelfEmpty;
                            final aisleName = _aisleController.text.trim();

                            final result = await context.read<ShelfAnalysisProvider>().analyzeAndSaveScan(
                              userId: currentUser.uid,
                              localImagePath: targetImagePath,
                              aisleName: aisleName,
                              userName: currentUser.name,
                              userEmail: currentUser.email,
                            );

                            if (result != null && context.mounted) {
                              Navigator.pushNamed(context, ResultsScreen.routeName);
                            } else if (context.mounted) {
                              final errMsg = context.read<ShelfAnalysisProvider>().errorMessage ?? 'Analysis failed';
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errMsg)));
                            }
                          },
                  ),
                  const SizedBox(height: 20),
                  SoftCard(
                    color: AppColors.surfaceMuted,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'PRE-SCAN QUALITY',
                                style: AppTextStyles.sectionLabel.copyWith(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ),
                            const Text(
                              '94%',
                              style: TextStyle(color: AppColors.primary, fontSize: 17, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: const LinearProgressIndicator(
                            value: .94,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Lighting and focus are optimal for accurate object detection.',
                          style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic, fontSize: 12),
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

  void _openShell(BuildContext context, int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainShellScreen(initialIndex: index)),
      (route) => false,
    );
  }
}

class _DashedFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 8.0;
    const dashSpace = 5.0;
    final paint = Paint()
      ..color = const Color(0x8C087E3B)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    void drawDashedLine(Offset start, Offset end) {
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final distance = math.sqrt(dx * dx + dy * dy);
      final unitX = dx / distance;
      final unitY = dy / distance;
      var drawn = 0.0;
      while (drawn < distance) {
        final currentStart = Offset(start.dx + unitX * drawn, start.dy + unitY * drawn);
        final currentEndDistance = (drawn + dashWidth).clamp(0.0, distance).toDouble();
        final currentEnd = Offset(start.dx + unitX * currentEndDistance, start.dy + unitY * currentEndDistance);
        canvas.drawLine(currentStart, currentEnd, paint);
        drawn += dashWidth + dashSpace;
      }
    }

    drawDashedLine(Offset.zero, Offset(size.width, 0));
    drawDashedLine(Offset(size.width, 0), Offset(size.width, size.height));
    drawDashedLine(Offset(size.width, size.height), Offset(0, size.height));
    drawDashedLine(Offset(0, size.height), Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
