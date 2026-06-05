import 'package:flutter/material.dart';

import 'local_image_widget_stub.dart'
    if (dart.library.io) 'local_image_widget_io.dart'
    if (dart.library.html) 'local_image_widget_web.dart' as local_image;

Widget buildLocalImage({
  required String path,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  required Widget errorPlaceholder,
}) {
  return local_image.buildLocalImage(
    path: path,
    width: width,
    height: height,
    fit: fit,
    errorPlaceholder: errorPlaceholder,
  );
}
