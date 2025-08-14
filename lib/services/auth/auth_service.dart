library;

// Export all function modules
export 'functions/login_functions.dart';
export 'functions/session_functions.dart';
export 'functions/token_functions.dart';
export 'functions/legacy_functions.dart';

// Export the base class
export 'auth_service_base.dart';

import 'auth_service_base.dart';
import 'functions/login_functions.dart' as login_funcs;
import 'functions/session_functions.dart' as session_funcs;
import 'functions/token_functions.dart' as token_funcs;
import 'functions/legacy_functions.dart' as legacy_funcs;
import '../../data/models/auth/login_result.dart';

/// Handles all authentication-related API calls including:
/// - User login with captcha verification
/// - Session management
/// - Authentication state
/// 
/// This class acts as a facade over the separated function modules.
class AuthService extends AuthServiceBase {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  AuthService._internal() {
    // Set up token refresh callback for HttpService
    httpService.setTokenRefreshCallback(() => token_funcs.refreshToken(this));
    // Set up legacy token refresh for old CMS
    httpService.setLegacyTokenRefreshCallback(() => legacy_funcs.ensureLegacyCookies(this));
  }

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
    return await login_funcs.performLogin(
      this,
      username: username,
      password: password,
      captchaData: captchaData,
    );
  }
  
  /// Restore session from saved cookies and validate by fetching current user
  /// Returns true if cookies are valid and user info has been set.
  Future<bool> restoreSessionFromCookies() async {
    return await session_funcs.restoreSessionFromCookies(this);
  }

  /// Fetch current user info and merge into auth state. Returns true on success.
  Future<bool> fetchAndSetCurrentUserInfo() async {
    return await session_funcs.fetchAndSetCurrentUserInfo(this);
  }
  
  /// Logout user and clear session
  Future<void> logout() async {
    return await session_funcs.performLogout(this);
  }
  
  /// Refresh authentication token using the refresh endpoint
  /// Returns true if refresh was successful, false otherwise
  Future<bool> refreshToken() async {
    return await token_funcs.refreshToken(this);
  }

  /// Check if current session is still valid
  bool isSessionValid() {
    return session_funcs.isSessionValid(this);
  }
  
  /// Proactively refresh token if session is getting close to expiration
  /// Call this periodically or before important operations
  Future<bool> refreshTokenIfNeeded() async {
    return await token_funcs.refreshTokenIfNeeded(this);
  }

  /// Get debug information about current session
  Map<String, dynamic> getSessionDebugInfo() {
    return session_funcs.getSessionDebugInfo(this);
  }

  /// Acquire legacy (old CMS) cookies by exchanging a legacy token and visiting legacy site.
  /// Returns true on success, false otherwise.
  Future<bool> ensureLegacyCookies() async {
    return await legacy_funcs.ensureLegacyCookies(this);
  }
}
