// presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/exceptions.dart';

import 'dart:async';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthProvider(this._authRepository) {
    _initializeAuth();
  }

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  void _initializeAuth() {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      _currentUser = user;
      _isInitialized = true;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    setLoading(true);
    clearError();

    try {
      final user = await _authRepository.signIn(email, password);
      _currentUser = user;
    } catch (e) {
      _error = getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    setLoading(true);
    clearError();

    try {
      final user = await _authRepository.signUp(email, password, name);
      _currentUser = user;
    } catch (e) {
      _error = getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    setLoading(true);
    clearError();

    try {
      await _authRepository.signOut();
      _currentUser = null;
    } catch (e) {
      _error = getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Returns a user-friendly error message based on the error type.
  String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    return 'An unexpected error occurred';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
