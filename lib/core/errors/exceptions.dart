// core/errors/exceptions.dart
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

class AIException extends AppException {
  const AIException(super.message);
}
