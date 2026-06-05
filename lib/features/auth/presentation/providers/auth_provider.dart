import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shelf_sight_ui_implementation/features/auth/domain/entities/user_entity.dart';
import 'package:shelf_sight_ui_implementation/features/auth/domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  StreamSubscription<UserEntity?>? _authSubscription;

  UserEntity? _currentUser;
  bool _isLoading = true;
  bool _isUpdatingUserRole = false;
  String? _errorMessage;
  List<UserEntity> _allUsers = [];

  AuthProvider(this._authRepository) {
    _authSubscription = _authRepository.onAuthStateChanged.listen(
      (user) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
    _loadInitialUser();
  }

  Future<void> _loadInitialUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      _currentUser ??= user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  UserEntity? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isLoading => _isLoading;
  bool get isUpdatingUserRole => _isUpdatingUserRole;
  String? get errorMessage => _errorMessage;
  List<UserEntity> get allUsers => _allUsers;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _authRepository.signIn(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _authRepository.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.signOut();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchAllUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _allUsers = await _authRepository.getAllUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> updateUserRole({
    required String uid,
    required String role,
  }) async {
    _isUpdatingUserRole = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.updateUserRole(uid: uid, role: role);
      _allUsers = _allUsers
          .map((user) => user.uid == uid
              ? UserEntity(
                  uid: user.uid,
                  email: user.email,
                  name: user.name,
                  role: role,
                  scanAccuracy: user.scanAccuracy,
                  shiftsCompleted: user.shiftsCompleted,
                )
              : user)
          .toList();
      _isUpdatingUserRole = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isUpdatingUserRole = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
