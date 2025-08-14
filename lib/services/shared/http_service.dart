import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../data/constants/api_constants.dart';
import '../../data/models/shared/http_response.dart';

/// HTTP Service for handling all HTTP requests and cookie management

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  // Cookie storage for session management
  final Map<String, String> _cookies = {};
  
  // Callback for token refresh (will be set by AuthService)
  Future<bool> Function()? _tokenRefreshCallback;
  
  // Callback for legacy cookie/token refresh (old CMS)
  Future<bool> Function()? _legacyTokenRefreshCallback;
  
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
  
  Future<HttpResponse> _sendRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool isRetry = false,
  }) async {
    try {
      final requestHeaders = _buildHeaders(headers);
      final requestBody = body != null ? jsonEncode(body) : null;

      final methodUpper = method.toUpperCase();
      print('$methodUpper Request to: $url');
      if (methodUpper == 'POST') {
        print('Body: $requestBody');
      }

      http.Response response;
      if (methodUpper == 'POST') {
        response = await http
            .post(
              Uri.parse(url),
              headers: requestHeaders,
              body: requestBody,
            )
            .timeout(ApiConstants.defaultTimeout);
      } else {
        response = await http
            .get(
              Uri.parse(url),
              headers: requestHeaders,
            )
            .timeout(ApiConstants.defaultTimeout);
      }

      print('Response Status: ${response.statusCode}');

      _storeCookies(response.headers);

      final httpResponse = HttpResponse(
        statusCode: response.statusCode,
        body: response.body,
        headers: response.headers,
        isSuccess: response.statusCode >= 200 && response.statusCode < 300,
      );

      if (!isRetry && _legacyTokenRefreshCallback != null) {
        final bool isLegacyUrl = url.startsWith(ApiConstants.legacyBaseUrl);
        if (isLegacyUrl && httpResponse.isSuccess && httpResponse.body.contains('<div>Loading...</div>')) {
          print('HttpService: Detected legacy Loading page, attempting legacy token refresh...');
          final refreshed = await _legacyTokenRefreshCallback!();
          if (refreshed) {
            print('HttpService: Legacy token refresh successful, retrying request...');
            return await _sendRequest(
              method: methodUpper,
              url: url,
              body: body,
              headers: headers,
              isRetry: true,
            );
          } else {
            print('HttpService: Legacy token refresh failed. Returning response.');
          }
        }
      }

      if (response.statusCode == 401 && !isRetry && _tokenRefreshCallback != null) {
        print('HttpService: Got 401, attempting token refresh...');
        final refreshSuccess = await _tokenRefreshCallback!();
        if (refreshSuccess) {
          print('HttpService: Token refresh successful, retrying request...');
          return await _sendRequest(
            method: methodUpper,
            url: url,
            body: body,
            headers: headers,
            isRetry: true,
          );
        } else {
          print('HttpService: Token refresh failed, returning 401 response');
        }
      }

      return httpResponse;
    } on SocketException catch (e) {
      throw HttpException('Network error: ${e.message}');
    } on HttpException catch (e) {
      throw HttpException('HTTP error: ${e.message}');
    } catch (e) {
      throw HttpException('Request failed: $e');
    }
  }

  /// Make a POST request with automatic token refresh on 401
  Future<HttpResponse> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool isRetry = false,
  }) async {
    return _sendRequest(
      method: 'POST',
      url: url,
      body: body,
      headers: headers,
      isRetry: isRetry,
    );
  }
  
  /// Make a GET request with automatic token refresh on 401
  Future<HttpResponse> get(
    String url, {
    Map<String, String>? headers,
    bool isRetry = false,
  }) async {
    return _sendRequest(
      method: 'GET',
      url: url,
      headers: headers,
      isRetry: isRetry,
    );
  }
  
  /// Low-level GET that allows disabling redirect following to capture Set-Cookie from 3xx responses.
  Future<HttpResponse> getRaw(
    String url, {
      Map<String, String>? headers,
      bool followRedirects = true,
    }) async {
    final requestHeaders = _buildHeaders(headers);
    print('RAW GET Request to: $url (followRedirects=$followRedirects)');
    final client = http.Client();
    try {
      final req = http.Request('GET', Uri.parse(url));
      req.followRedirects = followRedirects;
      req.headers.addAll(requestHeaders);
      final streamed = await client.send(req).timeout(ApiConstants.defaultTimeout);
      final resp = await http.Response.fromStream(streamed);
      _storeCookies(resp.headers);
      return HttpResponse(
        statusCode: resp.statusCode,
        body: resp.body,
        headers: resp.headers,
        isSuccess: resp.statusCode >= 200 && resp.statusCode < 300,
      );
    } on SocketException catch (e) {
      throw HttpException('Network error: ${e.message}');
    } on HttpException catch (e) {
      throw HttpException('HTTP error: ${e.message}');
    } catch (e) {
      throw HttpException('Request failed: $e');
    } finally {
      client.close();
    }
  }
  
  /// Clear all stored cookies (useful for logout)
  void clearCookies() {
    _cookies.clear();
    print('All cookies cleared');
  }
  
  /// Set token refresh callback
  void setTokenRefreshCallback(Future<bool> Function() callback) {
    _tokenRefreshCallback = callback;
  }
  
  /// Set legacy token refresh callback
  void setLegacyTokenRefreshCallback(Future<bool> Function() callback) {
    _legacyTokenRefreshCallback = callback;
  }
  
  /// Temporarily disable token refresh callback (used during refresh to prevent loops)
  void disableTokenRefresh() {
    _tokenRefreshCallback = null;
  }
  
  /// Check if token refresh is available
  bool get hasTokenRefreshCallback => _tokenRefreshCallback != null;
  
  /// Check if legacy token refresh is available
  bool get hasLegacyTokenRefreshCallback => _legacyTokenRefreshCallback != null;

  /// Get current cookies (for debugging)
  Map<String, String> get currentCookies => Map.unmodifiable(_cookies);
}

