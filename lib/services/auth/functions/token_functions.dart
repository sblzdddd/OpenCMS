import '../../../data/constants/api_constants.dart';
import '../../shared/storage_client.dart';
import '../auth_service_base.dart';

/// Refresh authentication token using the refresh endpoint
/// Returns true if refresh was successful, false otherwise
Future<bool> refreshCookies(AuthServiceBase authService) async {
  try {
    print('AuthService: Attempting to refresh token');
    
    final response = await authService.httpService.post(
      ApiConstants.tokenRefreshEndpoint,
      refresh: true,
    );
    
    if (response.statusCode == 200) {
      print('AuthService: Token refresh successful');
      return true;
    } else {
      print('AuthService: Token refresh failed with status: ${response.statusCode}');
      print('AuthService: Token refresh response: ${response.data}');
      return false;
    }
  } catch (e) {
    print('AuthService: Token refresh exception: $e');
    return false;
  }
}

/// Proactively refresh token if session is getting close to expiration
/// Call this periodically or before important operations
Future<bool> refreshCookiesIfNeeded(AuthServiceBase authService) async {
  // If not authenticated, no need to refresh
  if (!authService.authState.isAuthenticated) {
    return false;
  }
  
  // Always try refreshing when we have cookies but uncertain about expiration
  // This is safer than trying to predict expiration times
  final currentCookies = await StorageClient.currentCookies;
  if (currentCookies.isNotEmpty) {
    return await refreshCookies(authService);
  }
  
  return false;
}


