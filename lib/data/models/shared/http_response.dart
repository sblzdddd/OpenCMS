import 'dart:convert';

/// HTTP Response wrapper
class HttpResponse {
  final int statusCode;
  final String body;
  final Map<String, String> headers;
  final bool isSuccess;

  HttpResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
    required this.isSuccess,
  });

  /// Parse response body as JSON
  Map<String, dynamic>? get jsonBody {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}

/// Custom HTTP Exception
class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => 'HttpException: $message';
}
