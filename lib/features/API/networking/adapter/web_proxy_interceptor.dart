import '../../../shared/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

String convertToProxyUrl(String url) {
  if (!kIsWeb) return url;

  final uri = Uri.parse(url);
  final domain = uri.host;

  if (API.domainMapping.containsKey(domain)) {
    final proxyDomain = API.domainMapping[domain]!;
    final path = uri.path;
    final query = uri.query.isNotEmpty ? '?${uri.query}' : '';
    return '${API.proxyBaseUrl}/proxy/$proxyDomain$path$query';
  }

  return url;
}

/// Interceptor that redirects URLs to proxy when running on web
class WebProxyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kIsWeb) {
      // Convert the URL to use proxy
      final originalUrl = options.uri.toString();
      final proxyUrl = convertToProxyUrl(originalUrl);

      if (proxyUrl != originalUrl) {
        options.path = proxyUrl;
        options.baseUrl = '';

        // Update headers for proxy
        options.headers['X-Original-Host'] = options.uri.host;
        options.headers['X-Proxy-Request'] = 'true';
      }
    }

    handler.next(options);
  }
}
