import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

export 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

// Global options
final cacheOptions = CacheOptions(
  // A default store is required for interceptor.
  store: MemCacheStore(),
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

class CacheInterceptor extends DioCacheInterceptor {
  CacheInterceptor() : super(options: cacheOptions);
}
