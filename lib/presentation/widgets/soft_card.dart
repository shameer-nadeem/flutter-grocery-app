import 'package:flutter/material.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_dimensions.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = AppDimensions.cardRadius,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? (isDark ? AppColors.darkSurface : AppColors.surface);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.shadow,
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
