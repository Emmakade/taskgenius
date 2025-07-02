import 'package:taskgenius/core/errors/exceptions.dart';

class ErrorHandler {
  static void handleError(dynamic error, StackTrace stackTrace) {
    if (error is AppException) {
      _logAppException(error);
    } else {
      _logUnknownError(error, stackTrace);
    }
  }

  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return 'An unexpected error occurred';
  }
}
