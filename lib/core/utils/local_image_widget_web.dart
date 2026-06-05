import 'package:flutter/material.dart';

Widget buildLocalImage({
  required String path,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  required Widget errorPlaceholder,
}) {
  if (path.startsWith('blob:') || path.startsWith('data:')) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => errorPlaceholder,
    );
  }
  return errorPlaceholder;
}
