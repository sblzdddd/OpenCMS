import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:opencms/features/shared/constants/api_endpoints.dart';
import 'package:opencms/features/auth/services/login_state.dart';
import 'package:opencms/features/auth/services/token_refresh_service.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/API/storage/token_storage.dart';

final log = Logger('AuthInterceptor');

// manages auth headers and token refreshing
class AuthInterceptor extends Interceptor {
  final Dio _dio; // avoid circular dependency
  final TokenStorage storage = di<TokenStorage>();
  final LoginState loginState = di<LoginState>();
  final TokenRefreshService tokenRefreshService = di<TokenRefreshService>();

  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.accessToken;
    final urlPath = options.path;
    
    final isAccountUser = urlPath.startsWith(API.accountUserUrl);
    final isLogout = urlPath.contains('logout');
    final isLogin = urlPath.startsWith(API.loginUrl);
    final isAuthenticated = loginState.isAuthenticated;
    final isLegacyUrl = urlPath.startsWith(API.legacyBaseUrl);

    if (!isAccountUser && !isLogout && (isLogin || !isAuthenticated || isLegacyUrl)) {
      log.fine("Skipping auth headers for: $urlPath");
      return handler.next(options);
    }

    if (token != null && token.isNotEmpty) {
      options.headers['authorization'] = token;
      return handler.next(options);
    }
    options.extra['noToken'] = true;
    return handler.reject(DioException(requestOptions: options, error: 'No access token available'));
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    var options = err.requestOptions;
    if (options.path.startsWith(API.loginUrl) || options.path.startsWith(API.legacyBaseUrl) || !loginState.isAuthenticated) {
      return handler.next(err);
    }
    // check retry count
    var retries = options.extra['retries'];
    if (retries == null || retries is! int) retries = 0;
    if (retries >= API.maxRetries) return handler.next(err);
    // If unauthorized, try refreshing token
    if (err.response?.statusCode == 401 || err.response?.statusCode == 400 || options.extra['noToken'] == true) {
      final success = await tokenRefreshService.refreshNewToken();
      if (!success) return handler.next(err);
      final token = await storage.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['authorization'] = token;
      }
    }

    final response = await _dio.fetch(options.copyWith(extra: {
      'retries': retries + 1,
    }));
    return handler.resolve(response);
  }
}
