import '../../data/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'storage_client.dart';

/// HTTP Service for handling all HTTP requests and cookie management
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  final Dio _dio = Dio()
    ..interceptors.add(CookieManager(StorageClient.cookieJar))
    ..options.connectTimeout = ApiConstants.connectTimeout
    ..options.receiveTimeout = ApiConstants.defaultTimeout
    ..options.headers = ApiConstants.defaultHeaders
    ..options.followRedirects = false
    ..options.validateStatus =
        (status) => status != null && status >= 200 && status < 400;
  
  /// Make a POST request with automatic token refresh on 401
  Future<Response<dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const {},
  }) async {
    final url = '${ApiConstants.baseApiUrl}$endpoint';
    return _dio.post(url, data: body, options: Options(
      headers: {
        ..._dio.options.headers,
        ...headers,
        'Referer': ApiConstants.cmsReferer,
      },
    ));
  }
  
  /// Make a GET request with automatic token refresh on 401
  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, String> headers = const {},
  }) async {
    return _dio.get('${ApiConstants.baseApiUrl}$endpoint', options: Options(
      headers: {
        ..._dio.options.headers,
        ...headers,
        'Referer': ApiConstants.cmsReferer,
      }
    ));
  }

  /// Make a POST request with automatic token refresh on 401
  Future<Response<dynamic>> postLegacy(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const {},
  }) async {
    final url = '${ApiConstants.legacyCMSBaseUrl}$endpoint';
    return _dio.post(url, data: body, options: Options(
      headers: {
        ..._dio.options.headers,
        ...headers,
        'Referer': ApiConstants.legacyCMSReferer,
      },
    ));
  }
  
  /// Make a GET request with automatic token refresh on 401
  Future<Response<dynamic>> getLegacy(
    String endpoint, {
    Map<String, String> headers = const {},
  }) async {
    return _dio.get('${ApiConstants.legacyCMSBaseUrl}$endpoint', options: Options(
      headers: {
        ..._dio.options.headers,
        ...headers,
        'Referer': ApiConstants.legacyCMSReferer,
      }
    ));
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

