import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

/// Web-specific HTTP adapter configuration
class HttpAdapterHelper {
  /// Configure the Dio adapter for web platform
  static void configureAdapter(Dio dio) {
    (dio.httpClientAdapter as BrowserHttpClientAdapter).withCredentials = true;
  }
}
