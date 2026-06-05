import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase remote data source for scan documents and scan image uploads.
///
/// All scan CRUD operations are stored in Firebase through this source.
class FirebaseScanRemoteDataSource {
  FirebaseScanRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  CollectionReference<Map<String, dynamic>> get scansCollection =>
      firestore.collection('scans');

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      firestore.collection('users');
}
