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
    final token = await storage.getAccessToken();
    final urlPath = options.path;
    // User must authenticate to add auth headers / refresh their token
    if (!urlPath.startsWith(API.accountUserUrl) && 
        !urlPath.contains('logout') && 
        (urlPath.startsWith(API.loginUrl) || !loginState.isAuthenticated)) {
      log.fine("skipping auth");
      return handler.next(options);
    }

    if (token != null && token.isNotEmpty) {
      options.headers['authorization'] = token;
    } else {
      final refreshed = await tokenRefreshService.refreshNewToken();
      options.headers['authorization'] = refreshed ? token : null;
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    var options = err.requestOptions;
    if (options.path.startsWith(API.loginUrl) || !loginState.isAuthenticated) {
      return handler.next(err);
    }
    // check retry count
    var retries = options.extra['retries'];
    if (retries == null || retries is! int) retries = 0;
    if (retries >= API.maxRetries) return handler.next(err);
    // If unauthorized, try refreshing token
    if (err.response?.statusCode == 401 || err.response?.statusCode == 400) {
      final success = await tokenRefreshService.refreshNewToken();
      if (!success) return handler.next(err);
      final token = await storage.getAccessToken();
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
