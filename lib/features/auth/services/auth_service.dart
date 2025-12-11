library;

import 'package:logging/logging.dart';
import 'package:opencms/data/constants/api_endpoints.dart';
import 'package:opencms/features/auth/login_state.dart';
import 'package:opencms/features/auth/models/auth_models.dart';
import 'package:opencms/features/auth/services/token_refresh_service.dart';
import 'package:opencms/features/core/di/locator.dart';
import 'package:opencms/features/core/networking/http_service.dart';
import 'package:opencms/features/core/storage/cookie_storage.dart';
import 'package:opencms/features/core/storage/token_storage.dart';
import 'package:opencms/features/user/services/user_service.dart';

import '../models/login_result.dart';

final log = Logger('AuthService');

class AuthService {
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
    try {
      log.info('Starting login process for user: $username');

      // Prepare and send login request
      final response = await di<HttpService>().post(
        API.loginUrl,
        data: {
          'username': username,
          'password': password, // Plain text
          'captcha': captchaData, // Whole captcha object
        },
        refresh: true,
      );

      // Process the response
      if (response.statusCode != 200) {
        return LoginResult.error(
          message: 'Login failed with status ${response.statusCode}',
          data: response.data,
        );
      }
      // Update authentication state on success
      final data = LoginResponse.fromJson(response.data);
      await di<TokenStorage>().setAccessToken('Bearer ${data.accessToken}');
      await di<TokenStorage>().setRefreshToken(data.refreshToken);
      try {
        final userInfo = await di<UserService>().fetchUserAccountInfo();
        di<LoginState>().setAuthenticated(userInfo);
      } catch(e) {
        log.severe('Failed to fetch user info after login: $e');
        return LoginResult.error(
          message: 'Failed to fetch user info after login.',
          exception: e,
        );
      }
      di<TokenRefreshService>().refreshLegacyCookies();
      return LoginResult.success(
        message: 'Successfully logged in!',
        data: response.data,
      );
    } catch (e) {
      log.severe('Login exception: $e');

      return LoginResult.error(
        message: 'Login request failed: $e',
        exception: e,
      );
    }
  }

  /// Logout user and clear session
  Future<void> logout() async {
    log.info('Logging out user');

    di<LoginState>().clearAuthentication();
    di<TokenStorage>().clearAll();
    di<CookieStorage>().clearCookies();
    await di<CookieStorage>().clearCookies();
    try {
      await di<HttpService>().post(API.logoutUrl);
    } catch (e) {
      log.warning('Logout request failed: $e');
    }

    log.info('Logout completed');
  }

  Future<void> checkAuth() async {
    final accessToken = await di<TokenStorage>().getAccessToken();
    final refreshToken = await di<TokenStorage>().getRefreshToken();
    final isAuthenticated = accessToken != null && accessToken.isNotEmpty &&
        refreshToken != null && refreshToken.isNotEmpty;

    if (isAuthenticated) {
      try {
        final userInfo = await di<UserService>().fetchUserAccountInfo();
        di<LoginState>().setAuthenticated(userInfo);
      } catch (e) {
        log.warning('Failed to fetch user info during auth check: $e');
        di<LoginState>().clearAuthentication();
        di<CookieStorage>().clearCookies();
        di<TokenStorage>().clearAll();
      }
    } else {
      di<LoginState>().clearAuthentication();
      di<CookieStorage>().clearCookies();
      di<TokenStorage>().clearAll();
    }
  }

  Future<String> getJumpUrlToLegacy({String initialUrl = ""}) async {
    try {
      if (di<LoginState>().isAuthenticated == false) {
        log.warning('Cannot refresh: user not authenticated.');
        return "";
      }
      final userInfo = di<LoginState>().userInfo;
      if (userInfo == null) {
        log.warning('Cannot refresh: no user info available.');
        return "";
      }

      // Exchange for legacy token
      final tokenResp = await di<HttpService>().get(
        API.legacyTokenUrlForHref,
        refresh: true,
      );
      final data = LegacyTokenResponse.fromJson(tokenResp.data);

      if (data.code.isEmpty || data.iv.isEmpty) {
        log.warning('Response missing code/iv');
        return "";
      }

      String path = (initialUrl.isNotEmpty
          ? initialUrl.replaceAll("${API.legacyCMSBaseUrl}/", '')
          : '');
      path = path.isEmpty ? userInfo.name : path;

      // Construct the jump URL
      final jumpUrl =
          '${API.legacyCMSBaseUrl}/$path/?token=${data.code}&iv=${data.iv}&redirect=false';
      log.fine('Jump URL to legacy CMS: $jumpUrl');
      return jumpUrl;
    } catch (e) {
      log.fine('getJumpUrlToLegacy exception: $e');
      return "";
    }
  }
}