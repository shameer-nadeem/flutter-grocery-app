import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase remote data source for authentication and user-profile documents.
///
/// The repository talks to this data source instead of keeping Firebase calls
/// inside the UI layer. This keeps the auth feature separated into:
/// data → domain → presentation.
class FirebaseAuthRemoteDataSource {
  FirebaseAuthRemoteDataSource({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance,
        googleSignIn = googleSignIn ?? GoogleSignIn();

  final fb.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      firestore.collection('users');
}
