import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFFF8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF7F1F0);
  static const Color primary = Color(0xFF087E3B);
  static const Color primarySoft = Color(0xFFE8F8EE);
  static const Color primaryBright = Color(0xFF28E87A);
  static const Color black = Color(0xFF111111);
  static const Color textPrimary = Color(0xFF171717);
  static const Color textSecondary = Color(0xFF5D5D63);
  static const Color textMuted = Color(0xFF9B9BA3);
  static const Color border = Color(0xFFEAE6E5);
  static const Color danger = Color(0xFFC62828);
  static const Color dangerSoft = Color(0xFFFCE9E9);
  static const Color warning = Color(0xFFE29A18);
  static const Color shadow = Color(0x0C000000);
  static const Color buttonShadow = Color(0x33000000);
  static const Color darkBackground = Color(0xFF0F1714);
  static const Color darkSurface = Color(0xFF17241F);
  static const Color darkSurfaceMuted = Color(0xFF1E2E28);
  static const Color darkBorder = Color(0xFF2A3D35);
  static const Color darkTextPrimary = Color(0xFFF0F0F0);
  static const Color darkTextSecondary = Color(0xFFADB5AD);

  static Color adaptiveBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBackground : background;

  static Color adaptiveSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : surface;

  static Color adaptiveSurfaceMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceMuted : surfaceMuted;

  static Color adaptiveBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : border;

  static Color adaptiveTextPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : textPrimary;

  static Color adaptiveTextSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : textSecondary;

  static Color adaptiveBlack(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white : black;
}
