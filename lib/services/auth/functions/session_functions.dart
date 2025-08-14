import '../../../data/constants/api_constants.dart';
import '../auth_service_base.dart';
import 'legacy_functions.dart';

/// Restore session from saved cookies and validate by fetching current user
/// Returns true if cookies are valid and user info has been set.
Future<bool> restoreSessionFromCookies(AuthServiceBase authService) async {
  try {
    final savedCookies = await authService.cookiesStorageService.loadCookies();
    if (savedCookies.isEmpty) {
      return false;
    }
    authService.httpService.setCookies(savedCookies);
    final response = await authService.httpService.get(
      ApiConstants.accountUserUrl,
      headers: {
        'referer': ApiConstants.cmsReferer,
      },
    );
    if (response.statusCode == 200) {
      final data = response.jsonBody ?? {};
      final username = (data['username'] ?? '').toString();
      // Update auth state and user info
      authService.authState.setAuthenticated(
        username: username,
        additionalInfo: data,
      );
      
      // Ensure legacy cookies are valid as well
      try {
        final ok = await ensureLegacyCookies(authService);
        print('AuthService: ensureLegacyCookies after restore => $ok');
        await authService.cookiesStorageService.saveCookies(authService.httpService.currentCookies);
      } catch (e) {
        print('AuthService: Failed to initialize legacy cookies after restore: $e');
      }
      return true;
    }
    // Invalidate bad cookies to force login fallback
    authService.authState.clearAuthentication();
    authService.httpService.clearCookies();
    await authService.cookiesStorageService.clearCookies();
    return false;
  } catch (e) {
    // On error, clear and fallback to login
    authService.authState.clearAuthentication();
    authService.httpService.clearCookies();
    await authService.cookiesStorageService.clearCookies();
    return false;
  }
}

/// Fetch current user info and merge into auth state. Returns true on success.
Future<bool> fetchAndSetCurrentUserInfo(AuthServiceBase authService) async {
  try {
    final response = await authService.httpService.get(
      ApiConstants.accountUserUrl,
      headers: {
        'referer': ApiConstants.cmsReferer,
      },
    );
    if (response.statusCode == 200) {
      final data = response.jsonBody ?? {};
      if ((data['username'] ?? '').toString().isNotEmpty) {
        authService.authState.updateUserInfo(data);
      }
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
}

/// Logout user and clear session
Future<void> performLogout(AuthServiceBase authService) async {
  print('AuthService: Logging out user');
  
  authService.authState.clearAuthentication();
  authService.httpService.clearCookies();
  await authService.cookiesStorageService.clearCookies();
  
  print('AuthService: Logout completed');
}

/// Check if current session is still valid
bool isSessionValid(AuthServiceBase authService) {
  return authService.authState.isAuthenticated && 
         authService.httpService.currentCookies.isNotEmpty &&
         !authService.authState.isSessionExpired();
}

/// Get debug information about current session
Map<String, dynamic> getSessionDebugInfo(AuthServiceBase authService) {
  return {
    'authState': authService.authState.getDebugInfo(),
    'cookies': authService.httpService.currentCookies,
    'sessionValid': isSessionValid(authService),
  };
}


