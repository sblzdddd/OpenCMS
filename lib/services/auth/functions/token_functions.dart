import '../../../data/constants/api_constants.dart';
import '../auth_service_base.dart';
import 'session_functions.dart';
import 'legacy_functions.dart';

/// Refresh authentication token using the refresh endpoint
/// Returns true if refresh was successful, false otherwise
Future<bool> refreshToken(AuthServiceBase authService) async {
  try {
    print('AuthService: Attempting to refresh token');
    
    // Temporarily disable the refresh callback to prevent infinite loops
    final hadRefreshCallback = authService.httpService.hasTokenRefreshCallback;
    authService.httpService.disableTokenRefresh();
    
    try {
      final response = await authService.httpService.post(
        ApiConstants.tokenRefreshUrl,
        headers: {
          'referer': ApiConstants.cmsReferer,
        },
      );
      
      if (response.isSuccess) {
        print('AuthService: Token refresh successful');
        
        // Update cookies storage with new token
        try {
          await authService.cookiesStorageService.saveCookies(authService.httpService.currentCookies);
          print('AuthService: Updated cookies after token refresh');
        } catch (err) {
          print('AuthService: Error saving cookies after refresh: $err');
        }
        
        // Optionally fetch updated user info
        try {
          await fetchAndSetCurrentUserInfo(authService);
        } catch (e) {
          print('AuthService: Could not fetch user info after token refresh: $e');
        }
        
        // Re-initialize legacy cookies as new token could impact exchange
        try {
          final ok = await ensureLegacyCookies(authService);
          print('AuthService: ensureLegacyCookies after token refresh => $ok');
          await authService.cookiesStorageService.saveCookies(authService.httpService.currentCookies);
        } catch (e) {
          print('AuthService: Failed to initialize legacy cookies after token refresh: $e');
        }
        
        return true;
      } else {
        print('AuthService: Token refresh failed with status: ${response.statusCode}');
        print('AuthService: Token refresh response: ${response.body}');
        return false;
      }
    } finally {
      // Restore the refresh callback if it was there before
      if (hadRefreshCallback) {
        authService.httpService.setTokenRefreshCallback(() => refreshToken(authService));
      }
    }
  } catch (e) {
    print('AuthService: Token refresh exception: $e');
    return false;
  }
}

/// Proactively refresh token if session is getting close to expiration
/// Call this periodically or before important operations
Future<bool> refreshTokenIfNeeded(AuthServiceBase authService) async {
  // If not authenticated, no need to refresh
  if (!authService.authState.isAuthenticated) {
    return false;
  }
  
  // Always try refreshing when we have cookies but uncertain about expiration
  // This is safer than trying to predict expiration times
  if (authService.httpService.currentCookies.isNotEmpty) {
    print('AuthService: Proactively refreshing token');
    return await refreshToken(authService);
  }
  
  return false;
}


