import 'package:shelf_sight_ui_implementation/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  });

  Future<UserEntity?> signIn({
    required String email,
    required String password,
  });

  Future<UserEntity?> signInWithGoogle();

  Future<void> signOut();

  Future<UserEntity?> getCurrentUser();

  Future<void> sendPasswordResetEmail(String email);

  Future<List<UserEntity>> getAllUsers();

  Future<void> updateUserRole({
    required String uid,
    required String role,
  });

  Stream<UserEntity?> get onAuthStateChanged;
}
