import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadScanImage({
  required Reference reference,
  required String localPath,
}) async {
  final task = reference.putFile(File(localPath));
  final snapshot = await task;
  return snapshot.ref.getDownloadURL();
}
