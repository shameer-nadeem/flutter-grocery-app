import 'package:flutter/material.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/presentation/widgets/soft_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      radius: 22,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: valueColor, size: 22),
          const SizedBox(height: 9),
          Text(
            label.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.adaptiveTextPrimary(context),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              fontSize: 10.5,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: valueColor,
                fontSize: 28,
                height: 0.95,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}