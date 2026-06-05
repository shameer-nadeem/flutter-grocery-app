import 'package:flutter/material.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 10,
          shadowColor: AppColors.buttonShadow,
          backgroundColor: AppColors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.black,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
              ),
              const SizedBox(width: 12),
            ],
            Text(label),
            if (!isLoading && icon != null) ...[
              const SizedBox(width: 14),
              Icon(icon, size: 24),
            ],
          ],
        ),
      ),
    );
  }
}
