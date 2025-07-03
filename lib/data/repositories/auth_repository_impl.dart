import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskgenius/core/errors/exceptions.dart';
import 'package:taskgenius/domain/repositories/auth_repository.dart';
import 'package:taskgenius/domain/entities/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl(this._firebaseAuth, this._secureStorage);

  @override
  Future<User> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Sign in failed');
      }

      final token = await credential.user!.getIdToken();
      await _secureStorage.write(key: 'auth_token', value: token);

      return _mapFirebaseUserToUser(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final message = e.message ?? mapFirebaseError(e.code);
      throw AuthException(message);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  String mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'The email is already in use.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'Authentication failed. ($code)';
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser != null ? _mapFirebaseUserToUser(firebaseUser) : null;
    });
  }

  User _mapFirebaseUserToUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? '',
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return _mapFirebaseUserToUser(firebaseUser);
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await _secureStorage.delete(key: 'auth_token');
    await _firebaseAuth.signOut();
  }

  @override
  Future<User> signUp(String email, String password, String name) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Sign up failed');
      }

      await credential.user!.updateDisplayName(name);

      final token = await credential.user!.getIdToken();
      await _secureStorage.write(key: 'auth_token', value: token);

      return _mapFirebaseUserToUser(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseError(e.code));
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }
}
