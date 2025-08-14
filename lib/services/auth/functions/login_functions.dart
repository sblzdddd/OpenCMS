import '../../../data/constants/api_constants.dart';
import '../../../data/models/auth/login_result.dart';
import '../../../data/models/shared/http_response.dart';
import '../../shared/http_service.dart';
import '../auth_service_base.dart';
import 'legacy_functions.dart';

/// Login with username, password and captcha verification
/// 
/// Returns [LoginResult] with success status and relevant data
/// Handles multiple response scenarios:
/// - Success: {"detail": "Successfully logged in!"}
/// - Token Expired: {"error": "Token Expired"}
/// - Captcha Fail: {"error": "Captcha Fail"}
/// - Other errors: Various error formats
Future<LoginResult> performLogin(
  AuthServiceBase authService, {
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
    'referer': ApiConstants.loginReferer,
  };

  try {
    print('AuthService: Starting login process for user: $username');
    
    // Prepare and send login request
    final response = await sendLoginRequest(
      authService.httpService,
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
          if (authService.httpService.currentCookies.isNotEmpty)
            'Cookie': authService.httpService.cookieHeader,
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
    final result = processLoginResponse(response, username, debugInfo);
    
    // Update authentication state on success
    if (result.isSuccess) {
      authService.authState.setAuthenticated(username: username);
      // Persist cookies for auto-login on app restart (initial)
      try {
        await authService.cookiesStorageService.saveCookies(authService.httpService.currentCookies);
      } catch (err) {
        print('AuthService: Error saving cookies: $err');
      }

      // Fetch user profile to hydrate userInfo (e.g., en_name) immediately after first login
      try {
        final userResp = await authService.httpService.get(
          ApiConstants.accountUserUrl,
          headers: {
            'referer': ApiConstants.cmsReferer,
          },
        );
        if (userResp.statusCode == 200) {
          final data = userResp.jsonBody ?? {};
          authService.authState.updateUserInfo(data);
        } else {
          print('AuthService: Failed to fetch user info after login. Status: ${userResp.statusCode}');
        }
      } catch (e) {
        print('AuthService: Exception while fetching user info after login: $e');
      }

      // Initialize legacy (old CMS) cookies so legacy pages work immediately
      try {
        final ok = await ensureLegacyCookies(authService);
        print('AuthService: ensureLegacyCookies after login => $ok');
        // Persist updated cookies (including legacy) after successful acquisition
        await authService.cookiesStorageService.saveCookies(authService.httpService.currentCookies);
      } catch (e) {
        print('AuthService: Failed to initialize legacy cookies after login: $e');
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
          if (authService.httpService.currentCookies.isNotEmpty)
            'Cookie': authService.httpService.cookieHeader,
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

/// Send login request to the API
Future<HttpResponse> sendLoginRequest(
  HttpService httpService, {
  required Map<String, dynamic> payload,
  required Map<String, String> headers,
}) async {
  print('AuthService: Sending login request to ${ApiConstants.loginUrl}');
  print('AuthService: Payload keys: ${payload.keys}');
  
  // Make POST request to login endpoint
  final response = await httpService.post(
    ApiConstants.loginUrl,
    body: payload,
    headers: headers,
  );
  
  print('AuthService: Login response status: ${response.statusCode}');
  print('AuthService: Login response body: ${response.body}');
  
  return response;
}

/// Process login response and return appropriate LoginResult
LoginResult processLoginResponse(
  HttpResponse response,
  String username,
  Map<String, dynamic> debugInfo,
) {
  final responseData = response.jsonBody;
  
  if (response.isSuccess) {
    return handleSuccessResponse(responseData, debugInfo);
  } else {
    return handleErrorResponse(responseData, response.statusCode, debugInfo);
  }
}

/// Handle successful HTTP responses
LoginResult handleSuccessResponse(
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
LoginResult handleErrorResponse(
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


