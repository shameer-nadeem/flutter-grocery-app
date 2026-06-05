import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:shelf_sight_ui_implementation/core/bootstrap/firebase_demo_data_seeder.dart';
import 'package:shelf_sight_ui_implementation/features/auth/data/datasources/firebase_auth_remote_data_source.dart';
import 'package:shelf_sight_ui_implementation/features/auth/data/models/user_model.dart';
import 'package:shelf_sight_ui_implementation/features/auth/domain/entities/user_entity.dart';
import 'package:shelf_sight_ui_implementation/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuthRemoteDataSource? remoteDataSource,
    FirebaseDemoDataSeeder? demoDataSeeder,
  })  : _remoteDataSource = remoteDataSource ?? FirebaseAuthRemoteDataSource(),
        _demoDataSeeder = demoDataSeeder ?? FirebaseDemoDataSeeder();

  final FirebaseAuthRemoteDataSource _remoteDataSource;
  final FirebaseDemoDataSeeder _demoDataSeeder;

  fb.FirebaseAuth get _firebaseAuth => _remoteDataSource.firebaseAuth;
  GoogleSignIn get _googleSignIn => _remoteDataSource.googleSignIn;

  @override
  Stream<UserEntity?> get onAuthStateChanged {
    late final StreamController<UserEntity?> controller;
    StreamSubscription<fb.User?>? authSubscription;
    StreamSubscription<dynamic>? profileSubscription;

    controller = StreamController<UserEntity?>.broadcast(
      onListen: () {
        authSubscription = _firebaseAuth.authStateChanges().listen(
          (fbUser) async {
            await profileSubscription?.cancel();
            profileSubscription = null;

            if (fbUser == null) {
              if (!controller.isClosed) controller.add(null);
              return;
            }

            profileSubscription = _remoteDataSource.usersCollection
                .doc(fbUser.uid)
                .snapshots()
                .listen(
              (snapshot) {
                if (controller.isClosed) return;
                if (!snapshot.exists || snapshot.data() == null) {
                  controller.add(_fallbackUserFromFirebase(fbUser));
                  return;
                }
                controller.add(UserModel.fromMap(snapshot.data()!, fbUser.uid));
              },
              onError: controller.addError,
            );
          },
          onError: controller.addError,
        );
      },
      onCancel: () async {
        await profileSubscription?.cancel();
        await authSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    return _getOrCreateProfile(fbUser, preferredRole: _roleFromEmail(fbUser.email));
  }

  @override
  Future<UserEntity?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) return null;
      final user = await _getOrCreateProfile(
        credential.user!,
        preferredRole: _roleFromEmail(email),
      );
      if (user != null) await _demoDataSeeder.seedForUser(user);
      return user;
    } on fb.FirebaseAuthException catch (e) {
      if ((e.code == 'user-not-found' || e.code == 'invalid-credential') && _isDemoCredential(email, password)) {
        return _createDemoAccount(email: email, password: password);
      }
      throw Exception(e.message ?? 'Sign in failed.');
    }
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final fbUser = userCredential.user;
      if (fbUser == null) return null;

      final user = await _getOrCreateProfile(fbUser, preferredRole: 'user');
      if (user != null) await _demoDataSeeder.seedForUser(user);
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Google sign in failed.');
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser == null) return null;

      await fbUser.updateDisplayName(name);

      final userModel = UserModel(
        uid: fbUser.uid,
        email: email,
        name: name,
        role: role,
        scanAccuracy: 95.0,
        shiftsCompleted: 0,
      );

      await _remoteDataSource.usersCollection.doc(fbUser.uid).set(userModel.toMap());
      await _demoDataSeeder.seedForUser(userModel);
      return userModel;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign up failed.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Password reset failed.');
    }
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      final snapshot = await _remoteDataSource.usersCollection.get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
      users.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return users;
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }


  @override
  Future<void> updateUserRole({
    required String uid,
    required String role,
  }) async {
    if (role != 'admin' && role != 'user') {
      throw Exception('Invalid role selected.');
    }

    try {
      await _remoteDataSource.usersCollection.doc(uid).update({
        'role': role,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  Future<UserEntity?> _createDemoAccount({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final fbUser = credential.user;
    if (fbUser == null) return null;

    final role = _roleFromEmail(email);
    final name = role == 'admin' ? 'Admin User' : 'Standard User';
    await fbUser.updateDisplayName(name);

    final userModel = UserModel(
      uid: fbUser.uid,
      email: email,
      name: name,
      role: role,
      scanAccuracy: role == 'admin' ? 98.5 : 94.2,
      shiftsCompleted: role == 'admin' ? 15 : 8,
    );

    await _remoteDataSource.usersCollection.doc(fbUser.uid).set(userModel.toMap());
    await _demoDataSeeder.seedForUser(userModel);
    return userModel;
  }

  Future<UserEntity?> _getOrCreateProfile(
    fb.User fbUser, {
    String? preferredRole,
  }) async {
    final docRef = _remoteDataSource.usersCollection.doc(fbUser.uid);
    final doc = await docRef.get();
    if (doc.exists && doc.data() != null) {
      final user = UserModel.fromMap(doc.data()!, fbUser.uid);
      await _demoDataSeeder.seedForUser(user);
      return user;
    }

    final role = preferredRole ?? 'user';
    final userModel = UserModel(
      uid: fbUser.uid,
      email: fbUser.email ?? '',
      name: fbUser.displayName?.trim().isNotEmpty == true
          ? fbUser.displayName!.trim()
          : _friendlyName(fbUser.email ?? 'user@shelfsight.com'),
      role: role,
      scanAccuracy: role == 'admin' ? 98.5 : 95.0,
      shiftsCompleted: role == 'admin' ? 15 : 0,
    );

    await docRef.set(userModel.toMap());
    await _demoDataSeeder.seedForUser(userModel);
    return userModel;
  }

  UserModel _fallbackUserFromFirebase(fb.User fbUser) {
    final role = _roleFromEmail(fbUser.email);
    return UserModel(
      uid: fbUser.uid,
      email: fbUser.email ?? '',
      name: fbUser.displayName ?? _friendlyName(fbUser.email ?? ''),
      role: role,
      scanAccuracy: role == 'admin' ? 98.5 : 95.0,
      shiftsCompleted: role == 'admin' ? 15 : 0,
    );
  }

  bool _isDemoCredential(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    return (normalizedEmail == 'admin@shelfsight.com' && password == 'admin123') ||
        (normalizedEmail == 'user@shelfsight.com' && password == 'user123');
  }

  String _roleFromEmail(String? email) {
    return email?.trim().toLowerCase() == 'admin@shelfsight.com'
        ? 'admin'
        : 'user';
  }

  String _friendlyName(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) return 'ShelfSight User';
    return local
        .split(RegExp(r'[._-]'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
