import 'package:flutter/foundation.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/auth/services/login_state.dart';

import '../../../shared/constants/api_endpoints.dart';
import 'package:dio/dio.dart';

String convertToProxyUrl(String url) {
  final uri = Uri.parse(url);
  final domain = uri.host;

  if (API.domainMapping.containsKey(domain)) {
    final proxyDomain = API.domainMapping[domain]!;
    final path = uri.path;
    final query = uri.query.isNotEmpty ? '?${uri.query}' : '';
    return '${API.mockUrl}/$proxyDomain$path$query';
  }

  return url;
}

/// Interceptor that redirects URLs to proxy when running on web
class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (di<LoginState>().isMock && !kIsWeb) {
      // Convert the URL to use proxy
      final originalUrl = options.uri.toString();
      final proxyUrl = convertToProxyUrl(originalUrl);
      print(proxyUrl);

      if (proxyUrl != originalUrl) {
        options.path = proxyUrl;
        options.baseUrl = '';
        options.followRedirects = true;

        // Update headers for proxy
        options.headers['X-Original-Host'] = options.uri.host;
        options.headers['X-Proxy-Request'] = 'true';
      }
    }

    handler.next(options);
  }
}
