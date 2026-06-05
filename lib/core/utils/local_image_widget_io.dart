import 'dart:io';
import 'package:flutter/material.dart';

Widget buildLocalImage({
  required String path,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  required Widget errorPlaceholder,
}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, __, ___) => errorPlaceholder,
  );
}
