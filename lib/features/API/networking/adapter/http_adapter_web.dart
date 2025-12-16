import 'package:dio/dio.dart';
import 'package:dio/browser.dart';
import 'web_proxy_interceptor.dart';

/// Web-specific HTTP adapter configuration
class HttpAdapterHelper {
  /// Configure the Dio adapter for web platform
  static void configureAdapter(Dio dio) {
    // add proxy redirection interceptor for web
    dio.interceptors.add(WebProxyInterceptor());
    (dio.httpClientAdapter as BrowserHttpClientAdapter).withCredentials = true;
  }
}
