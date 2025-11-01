import '../../data/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'http_adapter_web.dart'
    if (dart.library.io) 'http_adapter_stub.dart'
    as http_adapter;
import 'storage_client.dart';
import 'proxy_service.dart';

// Global options
final cacheOptions = CacheOptions(
  // A default store is required for interceptor.
  store: MemCacheStore(),

  // All subsequent fields are optional to get a standard behaviour.

  // Default.
  policy: CachePolicy.forceCache,
  // Overrides any HTTP directive to delete entry past this duration.
  // Useful only when origin server has no cache config or custom behaviour is desired.
  // Defaults to `null`.
  maxStale: const Duration(days: 7),
  // Default. Allows 3 cache sets and ease cleanup.
  priority: CachePriority.normal,
  // Default. Body and headers encryption with your own algorithm.
  cipher: null,
  // Default. Key builder to retrieve requests.
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  // Default. Allows to cache POST requests.
  // Assigning a [keyBuilder] is strongly recommended when `true`.
  allowPostMethod: true,
);

/// HTTP Service for handling all HTTP requests and cookie management
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;

  late final Dio _dio;

  HttpService._internal() {
    _dio = Dio();
    if (!kIsWeb) {
      _dio.interceptors.add(CookieManager(StorageClient.cookieJar));
    } else {
      _dio.interceptors.add(WebProxyInterceptor());
      http_adapter.HttpAdapterHelper.configureAdapter(_dio);
    }
    _dio
      ..interceptors.add(DioCacheInterceptor(options: cacheOptions))
      ..options.connectTimeout = ApiConstants.connectTimeout
      ..options.receiveTimeout = ApiConstants.defaultTimeout
      ..options.headers = ApiConstants.defaultHeaders
      ..options.validateStatus = (status) =>
          status != null && status >= 200 && status < 400;
  }
  // Centralized request executor
  Future<Response<dynamic>> _request(
    String method,
    String endpoint, {
    dynamic data,
    Map<String, String> headers = const {},
    bool refresh = false,
    bool legacy = false,
    bool followRedirects = true,
  }) {
    final options =
        (refresh
              ? cacheOptions.copyWith(policy: CachePolicy.refresh).toOptions()
              : Options())
          ..headers = <String, dynamic>{
            ..._dio.options.headers,
            ...headers,
            if (!kIsWeb && legacy) 'Referer': ApiConstants.legacyCMSReferer,
          }
          ..followRedirects = followRedirects
          ..method = method.toUpperCase();

    final url =
        endpoint.startsWith('http://') || endpoint.startsWith('https://')
        ? endpoint
        : (legacy
              ? '${ApiConstants.legacyCMSBaseUrl}$endpoint'
              : '${ApiConstants.baseApiUrl}$endpoint');
    debugPrint("[$method] $url");
    return _dio.request(url, data: data, options: options);
  }

  /// Make a POST request with automatic token refresh on 401
  Future<Response<dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const {},
    bool refresh = false,
  }) async {
    return _request(
      'POST',
      endpoint,
      data: body,
      headers: headers,
      refresh: refresh,
    );
  }

  /// Make a GET request with automatic token refresh on 401
  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, String> headers = const {},
    bool refresh = false,
  }) async {
    return _request('GET', endpoint, headers: headers, refresh: refresh);
  }

  /// Make a POST request with automatic token refresh on 401
  Future<Response<dynamic>> postLegacy(
    String endpoint, {
    String? body,
    Map<String, String> headers = const {},
    bool refresh = false,
    bool followRedirects = true,
  }) async {
    return _request(
      'POST',
      endpoint,
      data: body,
      headers: headers,
      refresh: refresh,
      legacy: true,
      followRedirects: followRedirects,
    );
  }

  /// Make a GET request with automatic token refresh on 401
  Future<Response<dynamic>> getLegacy(
    String endpoint, {
    Map<String, String> headers = const {},
    bool refresh = false,
    bool followRedirects = true,
  }) async {
    return _request(
      'GET',
      endpoint,
      headers: headers,
      refresh: refresh,
      legacy: true,
      followRedirects: followRedirects,
    );
  }

  Future<Response<dynamic>> postNative(
    String endpoint, {
    Map<String, dynamic>? body,
    Options? options,
  }) async {
    return _dio.post(endpoint, data: body, options: options);
  }

  Future<Response<dynamic>> getNative(
    String endpoint, {
    Options? options,
  }) async {
    return _dio.get(endpoint, options: options);
  }
}
