import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart' show XFile;

Future<String> uploadScanImage({
  required Reference reference,
  required String localPath,
}) async {
  final bytes = await XFile(localPath).readAsBytes();
  final task = reference.putData(
    bytes,
    SettableMetadata(contentType: 'image/jpeg'),
  );
  final snapshot = await task;
  return snapshot.ref.getDownloadURL();
}
