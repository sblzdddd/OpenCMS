import '../../../data/constants/api_endpoints.dart';
import '../../../data/models/auth/login_result.dart';
import '../auth_service_base.dart';
import 'legacy_functions.dart';
import 'session_functions.dart';
import 'package:flutter/foundation.dart';

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
  
  final loginPayload = {
    'username': username,
    'password': password, // Plain text
    'captcha': captchaData, // Whole captcha object
  };

  try {
    debugPrint('LoginFunctions: Starting login process for user: $username');
    
    // Prepare and send login request
    final response = await authService.httpService.post(
      ApiConstants.loginEndpoint,
      body: loginPayload,
      refresh: true,
    );
    
    // Build debug info (mask sensitive fields)
    final sanitizedPayload = Map<String, dynamic>.from(loginPayload);
    sanitizedPayload['password'] = '[HIDDEN]';

    // Process the response
    if(response.statusCode == 200) {
      // Update authentication state on success
      await fetchAndSetCurrentUserInfo(authService);
      await refreshLegacyCookies(authService);
      return LoginResult.success(
        message: 'Successfully logged in!',
        data: response.data,
      );
    } else {
      return LoginResult.error(
        message: 'Login failed with status ${response.statusCode}',
        data: response.data,
      );
    }
    
  } catch (e) {
    debugPrint('LoginFunctions: Login exception: $e');
    
    final sanitizedPayload = Map<String, dynamic>.from(loginPayload);
    if (sanitizedPayload.containsKey('password')) {
      sanitizedPayload['password'] = '[HIDDEN]';
    }
    final debugInfo = <String, dynamic>{
      'request': {
        'method': 'POST',
        'url': ApiConstants.loginEndpoint,
        'headers': {
          ...ApiConstants.defaultHeaders,
          'Referer': ApiConstants.cmsReferer,
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

/// Handle successful HTTP responses
LoginResult handleSuccessResponse(
  Map<String, dynamic>? responseData,
) {
  if (responseData != null && responseData.containsKey('detail')) {
    final detail = responseData['detail'];
    // Safe casting with null check
    if (detail is String) {
      if (detail != 'Successfully logged in!') {
        debugPrint('Warning: Login might not be successful with detail: $detail');
        return LoginResult.error(
          message: detail,
          data: responseData,
        );
      }
    }
    return LoginResult.success(
      message: detail,
      data: responseData,
    );
  }
  
  // Unexpected success response format
  return LoginResult.error(
    message: 'Unexpected response format',
    data: responseData,
  );
}

/// Handle error HTTP responses (surface server-provided string if present)
LoginResult handleErrorResponse(
  Map<String, dynamic>? responseData,
  int statusCode,
) {
  if (responseData != null) {
    // Prefer explicit 'error' string from API
    if (responseData['error'] is String) {
      final error = responseData['error'] as String;
      debugPrint('LoginFunctions: Login failed with error: $error');
      return LoginResult.error(
        message: error,
        errorCode: error,
        data: responseData,
      );
    }

    // Sometimes servers put error message under 'detail'
    if (responseData['detail'] is String) {
      final detail = responseData['detail'] as String;
      debugPrint('LoginFunctions: Login failed with detail: $detail');
      return LoginResult.error(message: detail, data: responseData);
    }
  }

  // Fallback generic message
  return LoginResult.error(
    message: 'Login failed with status $statusCode',
    data: responseData,
  );
}


