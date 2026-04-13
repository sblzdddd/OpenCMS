import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/auth/services/login_state.dart';

const Duration kCacheExpiry = Duration(days: 7);

/// Format: `cache_{username}_{METHOD}_{sanitizedUrl}_{urlHash}`
String _buildCacheKey(RequestOptions options) {
  final username = di<LoginState>().currentUsername;
  final method = options.method.toUpperCase();
  final url = options.uri.toString();
  final sanitized = url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  final truncated = sanitized.length > 160
      ? sanitized.substring(0, 160)
      : sanitized;
  return 'cache_${username}_${method}_${truncated}_${url.hashCode}';
}

/// Encodes response headers (a [Headers] instance) into a plain JSON-serialisable
/// map so they can be persisted and later reconstructed.
Map<String, List<String>> _encodeHeaders(Headers headers) {
  final result = <String, List<String>>{};
  headers.forEach((name, values) => result[name] = values);
  return result;
}

/// Reconstructs a [Headers] instance from the map written by [_encodeHeaders].
Headers _decodeHeaders(Map<String, dynamic> raw) {
  return Headers.fromMap(
    raw.map((k, v) => MapEntry(k, List<String>.from(v as List))),
  );
}

class SecureCacheInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  SecureCacheInterceptor({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  // ── onRequest ────────────────────────────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Bypass cache when caller explicitly requests a fresh fetch.
    if (options.extra['cacheRefresh'] == true) {
      return handler.next(options);
    }

    final key = _buildCacheKey(options);
    try {
      final raw = await _storage.read(key: key);
      if (raw != null) {
        final entry = jsonDecode(raw) as Map<String, dynamic>;
        final expiresAt = DateTime.parse(entry['expiresAt'] as String);

        if (DateTime.now().isBefore(expiresAt)) {
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: entry['statusCode'] as int,
              data: entry['data'],
              headers: _decodeHeaders(entry['headers'] as Map<String, dynamic>),
            ),
            true,
          );
        }
      }
    } catch (_) {
      // Corrupt or missing entry — proceed to network.
    }

    handler.next(options);
  }

  // ── onResponse ───────────────────────────────────────────────────────────────

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final options = response.requestOptions;
    final onlyCacheSuccess = options.extra['onlyCacheSuccess'] == true;

    final statusCode = response.statusCode ?? 0;
    final shouldCache = !onlyCacheSuccess || statusCode == 200;

    if (shouldCache && statusCode >= 200 && statusCode < 300) {
      final key = _buildCacheKey(options);
      final now = DateTime.now();
      try {
        final entry = {
          'cachedAt': now.toIso8601String(),
          'expiresAt': now.add(kCacheExpiry).toIso8601String(),
          'statusCode': statusCode,
          'headers': _encodeHeaders(response.headers),
          'data': response.data,
        };
        await _storage.write(key: key, value: jsonEncode(entry));
      } catch (_) {
        // Storage failure must not break the response chain.
      }
    }

    handler.next(response);
  }

  // ── onError ──────────────────────────────────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Serve any existing cache entry as an offline fallback.
    final key = _buildCacheKey(err.requestOptions);
    try {
      final raw = await _storage.read(key: key);
      if (raw != null) {
        final entry = jsonDecode(raw) as Map<String, dynamic>;
        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            statusCode: entry['statusCode'] as int,
            data: entry['data'],
            headers: _decodeHeaders(entry['headers'] as Map<String, dynamic>),
          ),
        );
      }
    } catch (_) {}

    handler.next(err);
  }
}
