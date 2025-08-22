import '../../data/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'storage_client.dart';


// Global options
final cacheOptions = CacheOptions(
  // A default store is required for interceptor.
  // store: StorageClient.secureCacheStore,
  store: MemCacheStore(),

  // All subsequent fields are optional to get a standard behaviour.
  
  // Default.
  policy: CachePolicy.forceCache,
  // Returns a cached response on error for given status codes.
  // Defaults to `[]`.
  // hitCacheOnErrorCodes: [500],
  // Allows to return a cached response on network errors (e.g. offline usage).
  // Defaults to `false`.
  hitCacheOnErrorExcept: [401],
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
  HttpService._internal();

  final Dio _dio = Dio()
    ..interceptors.add(CookieManager(StorageClient.cookieJar))
    ..interceptors.add(DioCacheInterceptor(options: cacheOptions))
    ..options.connectTimeout = ApiConstants.connectTimeout
    ..options.receiveTimeout = ApiConstants.defaultTimeout
    ..options.headers = ApiConstants.defaultHeaders
    ..options.validateStatus =
        (status) => status != null && status >= 200 && status < 400;
  
  /// Make a POST request with automatic token refresh on 401
  Future<Response<dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const {},
    bool refresh = false,
  }) async {
    Options options = Options();
    if(refresh) {
      options = cacheOptions.copyWith(policy: CachePolicy.refresh).toOptions();
    }
    options.headers = {
      ..._dio.options.headers,
      ...headers,
      'Referer': ApiConstants.cmsReferer,
    };
    return _dio.post('${ApiConstants.baseApiUrl}$endpoint', data: body, options: options);
  }
  
  /// Make a GET request with automatic token refresh on 401
  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, String> headers = const {},
    bool refresh = false,
  }) async {
    Options options = Options();
    if(refresh) {
      options = cacheOptions.copyWith(policy: CachePolicy.refresh).toOptions();
    }
    options.headers = {
      ..._dio.options.headers,
      ...headers,
      'Referer': ApiConstants.cmsReferer,
    };
    return _dio.get('${ApiConstants.baseApiUrl}$endpoint', options: options);
  }

  /// Make a POST request with automatic token refresh on 401
  Future<Response<dynamic>> postLegacy(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const {},
    bool refresh = false,
    bool followRedirects = true,
  }) async {
    Options options = Options();
    if(refresh) {
      options = cacheOptions.copyWith(policy: CachePolicy.refresh).toOptions();
    }
    options.headers = {
      ..._dio.options.headers,
      ...headers,
      'Referer': ApiConstants.legacyCMSReferer,
    };
    options.followRedirects = followRedirects;
    final url = '${ApiConstants.legacyCMSBaseUrl}$endpoint';
    return _dio.post(url, data: body, options: options);
  }
  
  /// Make a GET request with automatic token refresh on 401
  Future<Response<dynamic>> getLegacy(
    String endpoint, {
    Map<String, String> headers = const {},
    bool refresh = false,
    bool followRedirects = true,
  }) async {
    Options options = Options();
    if(refresh) {
      options = cacheOptions.copyWith(policy: CachePolicy.refresh).toOptions();
    }
    options.headers = {
      ..._dio.options.headers,
      ...headers,
      'Referer': ApiConstants.legacyCMSReferer,
    };
    options.followRedirects = followRedirects;
    return _dio.get('${ApiConstants.legacyCMSBaseUrl}$endpoint', options: options);
  }

  /// Make a POST request with automatic token refresh on 401
  Future<Response<dynamic>> postNative(
    String endpoint, {
    Map<String, dynamic>? body,
    Options? options,
  }) async {
    return _dio.post(endpoint, data: body, options: options);
  }
  
  /// Make a GET request with automatic token refresh on 401
  Future<Response<dynamic>> getNative(
    String endpoint, {
    Options? options,
  }) async {
    return _dio.get(endpoint, options: options);
  }
}

