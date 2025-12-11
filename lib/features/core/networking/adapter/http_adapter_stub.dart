import 'package:dio/dio.dart';

/// Stub HTTP adapter configuration for non-web platforms
class HttpAdapterHelper {
  /// Configure the Dio adapter for non-web platforms (no-op)
  static void configureAdapter(Dio dio) {
    // No-op on non-web platforms
    // The default adapter is used automatically
  }
}
