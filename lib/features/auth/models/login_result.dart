/// Contains all data structures related to login responses and results
library;

/// Enum representing simplified login result types
enum LoginResultType { success, error }

/// Login result data class
class LoginResult {
  final bool isSuccess;
  final String message;
  final String? errorCode;
  final Map<String, dynamic>? data;
  final Object? exception;

  LoginResult({
    required this.isSuccess,
    required this.message,
    this.errorCode,
    this.data,
    this.exception,
  });

  /// Factory constructor for successful login
  factory LoginResult.success({
    required String message,
    Map<String, dynamic>? data,
    Map<String, dynamic>? debugInfo,
  }) {
    return LoginResult(
      isSuccess: true,
      message: message,
      data: data,
    );
  }

  /// Factory constructor for generic error
  factory LoginResult.error({
    required String message,
    String? errorCode,
    Map<String, dynamic>? data,
    Object? exception,
    Map<String, dynamic>? debugInfo,
  }) {
    return LoginResult(
      isSuccess: false,
      message: message,
      errorCode: errorCode,
      data: data,
      exception: exception,
    );
  }

  @override
  String toString() {
    return 'LoginResult(isSuccess: $isSuccess, message: $message, errorCode: $errorCode)';
  }
}
