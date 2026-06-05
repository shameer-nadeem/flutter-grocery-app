import 'package:firebase_storage/firebase_storage.dart';

import 'firebase_storage_uploader_stub.dart'
    if (dart.library.io) 'firebase_storage_uploader_io.dart'
    if (dart.library.html) 'firebase_storage_uploader_web.dart' as uploader;

Future<String> uploadScanImage({
  required Reference reference,
  required String localPath,
}) {
  return uploader.uploadScanImage(reference: reference, localPath: localPath);
}
