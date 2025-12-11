import 'dart:io';

import 'package:dio/io.dart';
import 'package:opencms/features/core/di/locator.dart';
import 'package:opencms/features/core/storage/cookie_storage.dart';
import 'package:opencms/features/core/networking/interceptors/legacy_cache_interceptor.dart';
import 'package:opencms/features/core/networking/interceptors/auth_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../../data/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'adapter/http_adapter_web.dart'
    if (dart.library.io) 'adapter/http_adapter_stub.dart'
    as http_adapter;


/// HTTP Service for handling all HTTP requests
class HttpService {
  late final Dio _dio;

  HttpService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: API.baseApiUrl,
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status >= 200 && status < 400,
        connectTimeout: API.connectTimeout,
        receiveTimeout: API.defaultTimeout,
        headers: API.defaultHeaders,
        followRedirects: false,
      ),
    );

    // allow self-signed certificate
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    // add authorization header
    _dio.interceptors.add(AuthInterceptor(_dio));

    if (kIsWeb) {
      http_adapter.HttpAdapterHelper.configureAdapter(_dio);
    } else {
      _dio.interceptors.add(CookieManager(di<CookieStorage>().cookieJar));
    }
    _dio.interceptors.add(CacheInterceptor());
    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
      ));
    }
  }

  Future<Response<dynamic>> fetch(RequestOptions requestOptions) async {
    return _dio.fetch(requestOptions);
  }

  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? data,
    bool refresh = false,
    bool legacy = false,
    Options? options,
  }) async {
    final opt = (refresh ? cacheOptions.copyWith(policy: CachePolicy.refresh).toOptions() : options ?? Options()).copyWith(
      headers: legacy
          ? {...?options?.headers, 'Referer': API.legacyCMSReferer}
          : options?.headers,
    );
    return _dio.get(legacy ? API.legacyCMSBaseUrl + endpoint : endpoint, queryParameters: data, options: opt);
  }

  Future<Response<dynamic>> post(
    String endpoint, {
    dynamic data,
    bool refresh = false,
    bool legacy = false,
    Options? options,
  }) async {
    final opt = (refresh ? cacheOptions.copyWith(policy: CachePolicy.refresh).toOptions() : options ?? Options()).copyWith(
      headers: legacy
          ? {...?options?.headers, 'Referer': API.legacyCMSReferer}
          : options?.headers,
    );
    return _dio.post(legacy ? API.legacyCMSBaseUrl + endpoint : endpoint, data: data, options: opt);
  }
}
