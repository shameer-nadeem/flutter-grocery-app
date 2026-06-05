import 'package:flutter/material.dart';

import 'package:shelf_sight_ui_implementation/core/utils/local_image_widget.dart';

/// Platform-safe image widget that handles:
/// - HTTP/HTTPS URLs → Firebase Storage URLs
/// - Asset paths → packaged shelf demo photos
/// - Local file paths → Image.file on Android/iOS and blob/data URLs on Web
class ScanImage extends StatelessWidget {
  const ScanImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final img = _buildImage();
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }

  Widget _buildImage() {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _loading();
        },
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return buildLocalImage(
      path: imagePath,
      width: width,
      height: height,
      fit: fit,
      errorPlaceholder: _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEAE7E7),
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 42, color: Color(0xFF9B9BA3)),
      ),
    );
  }

  Widget _loading() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFEAE7E7),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
