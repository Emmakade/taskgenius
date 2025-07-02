import 'package:taskgenius/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void handleError(dynamic error, StackTrace stackTrace) {
    if (error is AppException) {
      _logAppException(error);
    } else {
      _logUnknownError(error, stackTrace);
    }
  }

  static void _logAppException(AppException error) {
    // Example: log to a remote server or analytics
    debugPrint('AppException: ${error.message}');
  }

  static void _logUnknownError(dynamic error, StackTrace stackTrace) {
    // Example: log to a remote server or analytics
    debugPrint('Unknown error: ${error.toString()}');
    debugPrint('StackTrace: ${stackTrace.toString()}');
  }

  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return 'An unexpected error occurred';
  }
}
