import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'constants.dart';

/// HTTP Service for handling all HTTP requests and cookie management
/// 
/// This service manages:
/// - HTTP requests with proper headers
/// - Cookie persistence across requests
/// - Error handling and response parsing
/// - Timeout configuration

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  // Cookie storage for session management
  final Map<String, String> _cookies = {};
  
  /// Replace in-memory cookies (used for restoring persisted cookies)
  void setCookies(Map<String, String> cookies) {
    _cookies
      ..clear()
      ..addAll(cookies);
    print('HttpService: Cookies restored (${_cookies.length})');
  }
  
  /// Get stored cookies as a cookie header string
  String get cookieHeader {
    if (_cookies.isEmpty) return '';
    return _cookies.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('; ');
  }
  
  /// Parse and store cookies from response headers
  void _storeCookies(Map<String, String> responseHeaders) {
    final cookies = responseHeaders['set-cookie'];
    if (cookies != null) {
      final cookieList = cookies.split(',');
      for (String cookie in cookieList) {
        final parts = cookie.trim().split(';')[0].split('=');
        if (parts.length == 2) {
          final key = parts[0].trim();
          final value = parts[1].trim();
          _cookies[key] = value;
          print('Stored cookie: $key=$value');
        }
      }
    }
  }
  
  /// Build headers with cookies and default headers
  Map<String, String> _buildHeaders([Map<String, String>? additionalHeaders]) {
    final headers = Map<String, String>.from(ApiConstants.defaultHeaders);
    
    // Add cookies if available
    if (_cookies.isNotEmpty) {
      headers['Cookie'] = cookieHeader;
    }
    
    // Add any additional headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }
  
  /// Make a POST request
  Future<HttpResponse> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final requestHeaders = _buildHeaders(headers);
      final requestBody = body != null ? jsonEncode(body) : null;
      
      print('POST Request to: $url');
      print('Headers: $requestHeaders');
      print('Body: $requestBody');
      
      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: requestBody,
      ).timeout(ApiConstants.defaultTimeout);
      
      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      
      // Store cookies from response
      _storeCookies(response.headers);
      
      return HttpResponse(
        statusCode: response.statusCode,
        body: response.body,
        headers: response.headers,
        isSuccess: response.statusCode >= 200 && response.statusCode < 300,
      );
    } on SocketException catch (e) {
      throw HttpException('Network error: ${e.message}');
    } on HttpException catch (e) {
      throw HttpException('HTTP error: ${e.message}');
    } catch (e) {
      throw HttpException('Request failed: $e');
    }
  }
  
  /// Make a GET request
  Future<HttpResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final requestHeaders = _buildHeaders(headers);
      
      print('GET Request to: $url');
      print('Headers: $requestHeaders');
      
      final response = await http.get(
        Uri.parse(url),
        headers: requestHeaders,
      ).timeout(ApiConstants.defaultTimeout);
      
      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      
      // Store cookies from response
      _storeCookies(response.headers);
      
      return HttpResponse(
        statusCode: response.statusCode,
        body: response.body,
        headers: response.headers,
        isSuccess: response.statusCode >= 200 && response.statusCode < 300,
      );
    } on SocketException catch (e) {
      throw HttpException('Network error: ${e.message}');
    } on HttpException catch (e) {
      throw HttpException('HTTP error: ${e.message}');
    } catch (e) {
      throw HttpException('Request failed: $e');
    }
  }
  
  /// Clear all stored cookies (useful for logout)
  void clearCookies() {
    _cookies.clear();
    print('All cookies cleared');
  }
  
  /// Get current cookies (for debugging)
  Map<String, String> get currentCookies => Map.unmodifiable(_cookies);
}

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
