import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:opencms/features/shared/constants/api_endpoints.dart';
import 'package:opencms/features/auth/services/login_state.dart';
import 'package:opencms/features/auth/services/token_refresh_service.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/API/storage/token_storage.dart';

final log = Logger('LegacyAuthInterceptor');

class LegacyAuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage storage = di<TokenStorage>();
  final LoginState loginState = di<LoginState>();
  final TokenRefreshService tokenRefreshService = di<TokenRefreshService>();

  LegacyAuthInterceptor(this._dio);

  Future<bool> updateCookies(RequestOptions options) async {
    final sidNb = await storage.sidNb;
    final sidScie = await storage.sidScie;
    final userName = di<LoginState>().currentUsername;
    if (sidNb != null && sidNb.isNotEmpty && sidScie != null && sidScie.isNotEmpty) {
      options.headers[HttpHeaders.cookieHeader] = 'psid=$userName; sid_scie=$sidScie; sid_nb=$sidNb; rpsid=$userName;';
      return true;
    }
    return false;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final urlPath = options.path;
    final isRefresh = options.extra['legacyRefresh'] == true;
    
    if(!urlPath.startsWith(API.legacyBaseUrl) || !loginState.isAuthenticated || isRefresh) {
      log.fine("Skipping legacy auth headers for: $urlPath");
      return handler.next(options);
    }

    if (await updateCookies(options)) {
      return handler.next(options);
    }
    options.extra['noLegacyCookies'] = true;
    return handler.reject(DioException(requestOptions: options, error: 'No legacy session cookies available'));
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    var options = err.requestOptions;
    final urlPath = options.path;
    final userName = di<LoginState>().currentUsername;
    
    if(!urlPath.startsWith(API.legacyBaseUrl) || !loginState.isAuthenticated || userName.isEmpty) {
      return handler.next(err);
    }
    // check retry count
    var retries = options.extra['retries'];
    if (retries == null || retries is! int) retries = 0;
    if (retries >= API.maxRetries) return handler.next(err);
    // If unauthorized, try refreshing token
    if (err.response?.statusCode == 401 || err.response?.statusCode == 400 || options.extra['noLegacyCookies'] == true) {
      final success = await tokenRefreshService.refreshLegacyCookies();
      if (!success || !await updateCookies(options)) {
        return handler.next(err);
      }
    }

    final response = await _dio.fetch(options.copyWith(extra: {
      'retries': retries + 1,
    }));
    return handler.resolve(response);
  }
}
