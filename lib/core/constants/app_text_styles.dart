import 'package:flutter/material.dart';
import 'package:shelf_sight_ui_implementation/core/constants/app_colors.dart';

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.05,
    color: AppColors.textPrimary,
  );
  static const TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 2.2,
    color: AppColors.primary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: AppColors.textSecondary,
  );
}
