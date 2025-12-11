/// Contains all data structures related to login responses and results
library;

/// Enum representing simplified login result types
enum LoginResultType { success, error }

/// Login result data class
class LoginResult {
  final bool isSuccess;
  final String message;
  final LoginResultType resultType;
  final String? errorCode;
  final Map<String, dynamic>? data;
  final Object? exception;
  final Map<String, dynamic>?
  debugInfo; // optional rich debug details (request/response)

  LoginResult({
    required this.isSuccess,
    required this.message,
    required this.resultType,
    this.errorCode,
    this.data,
    this.exception,
    this.debugInfo,
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
      resultType: LoginResultType.success,
      data: data,
      debugInfo: debugInfo,
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
      resultType: LoginResultType.error,
      errorCode: errorCode,
      data: data,
      exception: exception,
      debugInfo: debugInfo,
    );
  }

  @override
  String toString() {
    return 'LoginResult(isSuccess: $isSuccess, resultType: $resultType, message: $message, errorCode: $errorCode)';
  }
}
