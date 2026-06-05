import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadScanImage({
  required Reference reference,
  required String localPath,
}) async {
  throw UnsupportedError('Image upload is not supported on this platform.');
}
