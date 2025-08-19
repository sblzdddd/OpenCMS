import '../../../data/constants/api_constants.dart';
import '../../shared/storage_client.dart';
import '../auth_service_base.dart';

/// Fetch current user info and merge into auth state. Returns true on success.
Future<Map<String, dynamic>> fetchAndSetCurrentUserInfo(AuthServiceBase authService) async {
  try {
    final response = await authService.httpService.get(ApiConstants.accountUserUrl);
    final data = response.data ?? {};
    if ((data['en_name'] ?? '').toString().isNotEmpty) {
      authService.authState.updateUserInfo(data);
      authService.authState.setAuthenticated(username: data['en_name']);
    } else {
      print('AuthService: Failed to fetch user info: No username found');
      throw Exception('No username found');
    }
    return data;
  } catch (e) {
    print('AuthService: Failed to fetch user info: $e');
    rethrow;
  }
}

Future<String> fetchCurrentUsername(AuthServiceBase authService) async {
  final response = await authService.httpService.get(ApiConstants.accountUserUrl);
  if (response.statusCode == 200) {
    final data = response.data ?? {};
    return (data['username'] ?? '').toString();
  } else {
    throw Exception('Failed to fetch user info: ${response.statusCode}');
  }
}

/// Logout user and clear session
Future<void> performLogout(AuthServiceBase authService) async {
  print('AuthService: Logging out user');
  
  authService.authState.clearAuthentication();
  await StorageClient.clearCookies();
  
  print('AuthService: Logout completed');
}

/// Check if current session is still valid
Future<bool> isSessionValid(AuthServiceBase authService) async {
  final currentCookies = await StorageClient.currentCookies;
  return authService.authState.isAuthenticated && 
         currentCookies.isNotEmpty &&
         !authService.authState.isSessionExpired();
}

/// Get debug information about current session
Future<Map<String, dynamic>> getSessionDebugInfo(AuthServiceBase authService) async {
  return {
    'authState': authService.authState.getDebugInfo(),
    'cookies': await StorageClient.currentCookies,
    'sessionValid': await isSessionValid(authService),
  };
}


