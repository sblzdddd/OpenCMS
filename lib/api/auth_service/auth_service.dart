import '../http_service.dart';
import '../constants.dart';
import '../secure_storage_service/cookies_storage_service.dart';
import 'login_result.dart';
import 'auth_state.dart';

/// Handles all authentication-related API calls including:
/// - User login with captcha verification
/// - Session management
/// - Authentication state

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final HttpService _httpService = HttpService();
  final AuthState _authState = AuthState();
  final CookiesStorageService _cookiesStorageService = CookiesStorageService();
  
  /// Check if user is currently authenticated
  bool get isAuthenticated => _authState.isAuthenticated;
  
  /// Get current user information
  Map<String, dynamic>? get userInfo => _authState.userInfo;
  
  /// Login with username, password and captcha verification
  /// 
  /// Returns [LoginResult] with success status and relevant data
  /// Handles multiple response scenarios:
  /// - Success: {"detail": "Successfully logged in!"}
  /// - Token Expired: {"error": "Token Expired"}
  /// - Captcha Fail: {"error": "Captcha Fail"}
  /// - Other errors: Various error formats
  Future<LoginResult> login({
    required String username,
    required String password,
    required Object captchaData,
  }) async {
    // Prepare login payload and headers early so they are available for error debug info
    final loginPayload = {
      'username': username,
      'password': password, // Plain text as requested
      'captcha': captchaData, // Whole captcha object as requested
    };

    final loginHeaders = {
      ...ApiConstants.defaultHeaders,
      'referer': 'https://cms.alevel.com.cn/cms/auth/login',
    };

    try {
      print('AuthService: Starting login process for user: $username');
      
      // Prepare and send login request
      final response = await _sendLoginRequest(
        payload: loginPayload,
        headers: loginHeaders,
      );
      
      // Build debug info (mask sensitive fields)
      final sanitizedPayload = Map<String, dynamic>.from(loginPayload);
      if (sanitizedPayload.containsKey('password')) {
        sanitizedPayload['password'] = '[HIDDEN]';
      }

      final debugInfo = <String, dynamic>{
        'request': {
          'method': 'POST',
          'url': ApiConstants.loginUrl,
          'headers': {
            ...loginHeaders,
            if (_httpService.currentCookies.isNotEmpty)
              'Cookie': _httpService.cookieHeader,
          },
          'body': sanitizedPayload,
        },
        'response': {
          'statusCode': response.statusCode,
          'headers': response.headers,
          'body': response.body,
          'json': response.jsonBody,
        },
      };

      // Process the response
      final result = _processLoginResponse(response, username, debugInfo);
      
      // Update authentication state on success
      if (result.isSuccess) {
        _authState.setAuthenticated(username: username);
        // Persist cookies for auto-login on app restart
        try {
          await _cookiesStorageService.saveCookies(_httpService.currentCookies);
        } catch (err) {
          print('AuthService: Error saving cookies: $err');
        }

        // Fetch user profile to hydrate userInfo (e.g., en_name) immediately after first login
        try {
          final userResp = await _httpService.get(
            ApiConstants.accountUserUrl,
            headers: {
              'referer': ApiConstants.cmsReferer,
            },
          );
          if (userResp.statusCode == 200) {
            final data = userResp.jsonBody ?? {};
            _authState.updateUserInfo(data);
          } else {
            print('AuthService: Failed to fetch user info after login. Status: ${userResp.statusCode}');
          }
        } catch (e) {
          print('AuthService: Exception while fetching user info after login: $e');
        }
      }
      
      return result;
      
    } catch (e) {
      print('AuthService: Login exception: $e');
      
      final sanitizedPayload = Map<String, dynamic>.from(loginPayload);
      if (sanitizedPayload.containsKey('password')) {
        sanitizedPayload['password'] = '[HIDDEN]';
      }
      final debugInfo = <String, dynamic>{
        'request': {
          'method': 'POST',
          'url': ApiConstants.loginUrl,
          'headers': {
            ...loginHeaders,
            if (_httpService.currentCookies.isNotEmpty)
              'Cookie': _httpService.cookieHeader,
          },
          'body': sanitizedPayload,
        },
        'exception': e.toString(),
      };

      return LoginResult.error(
        message: 'Login request failed: $e',
        exception: e,
        debugInfo: debugInfo,
      );
    }
  }
  
  /// Restore session from saved cookies and validate by fetching current user
  /// Returns true if cookies are valid and user info has been set.
  Future<bool> restoreSessionFromCookies() async {
    try {
      final savedCookies = await _cookiesStorageService.loadCookies();
      if (savedCookies.isEmpty) {
        return false;
      }
      _httpService.setCookies(savedCookies);
      final response = await _httpService.get(
        ApiConstants.accountUserUrl,
        headers: {
          'referer': ApiConstants.cmsReferer,
        },
      );
      if (response.statusCode == 200) {
        final data = response.jsonBody ?? {};
        final username = (data['username'] ?? '').toString();
        // Update auth state and user info
        _authState.setAuthenticated(
          username: username,
          additionalInfo: data,
        );
        return true;
      }
      // Invalidate bad cookies to force login fallback
      _authState.clearAuthentication();
      _httpService.clearCookies();
      await _cookiesStorageService.clearCookies();
      return false;
    } catch (e) {
      // On error, clear and fallback to login
      _authState.clearAuthentication();
      _httpService.clearCookies();
      await _cookiesStorageService.clearCookies();
      return false;
    }
  }

  /// Fetch current user info and merge into auth state. Returns true on success.
  Future<bool> fetchAndSetCurrentUserInfo() async {
    try {
      final response = await _httpService.get(
        ApiConstants.accountUserUrl,
        headers: {
          'referer': ApiConstants.cmsReferer,
        },
      );
      if (response.statusCode == 200) {
        final data = response.jsonBody ?? {};
        if ((data['username'] ?? '').toString().isNotEmpty) {
          _authState.updateUserInfo(data);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Send login request to the API
  Future<HttpResponse> _sendLoginRequest({
    required Map<String, dynamic> payload,
    required Map<String, String> headers,
  }) async {
    print('AuthService: Sending login request to ${ApiConstants.loginUrl}');
    print('AuthService: Payload keys: ${payload.keys}');
    
    // Make POST request to login endpoint
    final response = await _httpService.post(
      ApiConstants.loginUrl,
      body: payload,
      headers: headers,
    );
    
    print('AuthService: Login response status: ${response.statusCode}');
    print('AuthService: Login response body: ${response.body}');
    
    return response;
  }
  
  /// Process login response and return appropriate LoginResult
  LoginResult _processLoginResponse(
    HttpResponse response,
    String username,
    Map<String, dynamic> debugInfo,
  ) {
    final responseData = response.jsonBody;
    
    if (response.isSuccess) {
      return _handleSuccessResponse(responseData, debugInfo);
    } else {
      return _handleErrorResponse(responseData, response.statusCode, debugInfo);
    }
  }
  
  /// Handle successful HTTP responses
  LoginResult _handleSuccessResponse(
    Map<String, dynamic>? responseData,
    Map<String, dynamic> debugInfo,
  ) {
    if (responseData != null && responseData.containsKey('detail')) {
      final detail = responseData['detail'] as String;
      
      if (detail == 'Successfully logged in!') {
        print('AuthService: Login successful');
        
        return LoginResult.success(
          message: detail,
          data: responseData,
          debugInfo: debugInfo,
        );
      }
    }
    
    // Unexpected success response format
    return LoginResult.error(
      message: 'Unexpected response format',
      data: responseData,
      debugInfo: debugInfo,
    );
  }
  
  /// Handle error HTTP responses (surface server-provided string if present)
  LoginResult _handleErrorResponse(
    Map<String, dynamic>? responseData,
    int statusCode,
    Map<String, dynamic> debugInfo,
  ) {
    if (responseData != null) {
      // Prefer explicit 'error' string from API
      if (responseData['error'] is String) {
        final error = responseData['error'] as String;
        print('AuthService: Login failed with error: $error');
        return LoginResult.error(
          message: error,
          errorCode: error,
          data: responseData,
          debugInfo: debugInfo,
        );
      }

      // Sometimes servers put error message under 'detail'
      if (responseData['detail'] is String) {
        final detail = responseData['detail'] as String;
        print('AuthService: Login failed with detail: $detail');
        return LoginResult.error(message: detail, data: responseData, debugInfo: debugInfo);
      }
    }

    // Fallback generic message
    return LoginResult.error(
      message: 'Login failed with status $statusCode',
      data: responseData,
      debugInfo: debugInfo,
    );
  }
  
  /// Logout user and clear session
  Future<void> logout() async {
    print('AuthService: Logging out user');
    
    _authState.clearAuthentication();
    _httpService.clearCookies();
    await _cookiesStorageService.clearCookies();
    
    print('AuthService: Logout completed');
  }
  
  /// Check if current session is still valid
  bool isSessionValid() {
    return _authState.isAuthenticated && 
           _httpService.currentCookies.isNotEmpty &&
           !_authState.isSessionExpired();
  }
  
  /// Get debug information about current session
  Map<String, dynamic> getSessionDebugInfo() {
    return {
      'authState': _authState.getDebugInfo(),
      'cookies': _httpService.currentCookies,
      'sessionValid': isSessionValid(),
    };
  }
}
