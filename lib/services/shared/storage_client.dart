import 'package:cookie_jar/cookie_jar.dart' show PersistCookieJar, Storage;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart' show Cookie;

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'dart:convert';



/// Storage Client
///
/// Provides a single configured instance of [FlutterSecureStorage]
/// to be used across atomic storage services.
class StorageClient {
  const StorageClient._();

  /// Shared [FlutterSecureStorage] instance with platform-specific options
  static const FlutterSecureStorage instance = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    lOptions: LinuxOptions(
      
    ),
    wOptions: WindowsOptions(
      
    ),
    mOptions: MacOsOptions(
      
    ),
  );

  // Legacy API kept for compatibility during refactor
  // static const FlutterSecureStorage storage = instance;

  /// Cookie-jar compatible storage backed by [FlutterSecureStorage].
  /// Useful if you want to construct your own `PersistCookieJar`.
  static final Storage cookieStorage = _SecureStorageBase(instance, 'cj4');

  /// Cache storage backed by [FlutterSecureStorage].
  static final Storage cacheStorage = _SecureStorageBase(instance, 'ch4');

  /// Secure cache store backed by [FlutterSecureStorage].
  /// Provides persistent, encrypted caching for HTTP responses.
  static final SecureCacheStore secureCacheStore = SecureCacheStore(
    storage: instance,
    prefix: 'cache_',
    maxSize: 7340032, // 7MB default
    maxEntrySize: 512000, // 500KB default
  );

  /// Shared [PersistCookieJar] that persists into secure storage on all
  /// supported platforms. Session cookies are persisted by default.
  static final PersistCookieJar cookieJar = PersistCookieJar(
    persistSession: true,
    storage: cookieStorage,
  );

  static Future<List<Cookie>>get currentCookies async {
    await StorageClient.cookieJar.forceInit();
    
    final allCookies = <Cookie>[];
    
    // Get all domain cookies (cookies with domain attribute)
    for (final domainEntry in StorageClient.cookieJar.domainCookies.entries) {
      for (final pathEntry in domainEntry.value.entries) {
        for (final cookieEntry in pathEntry.value.entries) {
          allCookies.add(cookieEntry.value.cookie);
        }
      }
    }
    
    // Get all host cookies (cookies without domain attribute)
    for (final hostEntry in StorageClient.cookieJar.hostCookies.entries) {
      for (final pathEntry in hostEntry.value.entries) {
        for (final cookieEntry in pathEntry.value.entries) {
          allCookies.add(cookieEntry.value.cookie);
        }
      }
    }
    
    return allCookies;
  }

  static Future<void> setCookies(List<Cookie> cookies) async {
    for (final cookie in cookies) {
      await StorageClient.cookieJar.saveFromResponse(Uri.parse(cookie.domain ?? ''), [cookie]);
    }
  }

  static Future<void> clearCookies() async {
    await StorageClient.cookieJar.deleteAll();
  }
}

class _SecureStorageBase implements Storage {
  _SecureStorageBase(this._secureStorage, this._prefixId);

  final FlutterSecureStorage _secureStorage;
  final String _prefixId;
  String _prefix = 'st4_ie0_ps1_';
  bool _initialized = false;

  String _namespaced(String key) => '$_prefix$key';

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {
    // Match FileStorage path scheme logically so different configs don't clash
    _prefix = '${_prefixId}_ie${ignoreExpires ? 1 : 0}_ps${persistSession ? 1 : 0}_';
    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init(true, false);
    }
  }

  @override
  Future<String?> read(String key) async {
    await _ensureInitialized();
    return _secureStorage.read(key: _namespaced(key));
  }

  @override
  Future<void> write(String key, String value) async {
    await _ensureInitialized();
    await _secureStorage.write(key: _namespaced(key), value: value);
  }

  @override
  Future<void> delete(String key) async {
    await _ensureInitialized();
    await _secureStorage.delete(key: _namespaced(key));
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    await _ensureInitialized();
    // Best-effort: delete only known keys under this namespace
    for (final key in keys) {
      await _secureStorage.delete(key: _namespaced(key));
    }
  }
}

/// A secure store saving responses in encrypted storage with LRU-like behavior.
///
/// This implementation provides persistent, encrypted caching for HTTP responses
/// while maintaining similar performance characteristics to MemCacheStore.
class SecureCacheStore extends CacheStore {
  SecureCacheStore({
    required FlutterSecureStorage storage,
    required String prefix,
    int maxSize = 7340032,
    int maxEntrySize = 512000,
  }) : _storage = storage,
       _prefix = prefix,
       _maxSize = maxSize,
       _maxEntrySize = maxEntrySize {
    assert(maxEntrySize * 5 <= maxSize, 
           'maxEntrySize * 5 must be <= maxSize to prevent store from becoming useless');
    _sizeKey = '${_prefix}total_size';
    _keysKey = '${_prefix}all_keys';
  }

  final FlutterSecureStorage _storage;
  final String _prefix;
  final int _maxSize;
  final int _maxEntrySize;
  
  // Track cache metadata for LRU-like behavior
  final Map<String, _CacheEntry> _metadata = {};
  int _currentSize = 0;
  bool _initialized = false;

  String _namespaced(String key) => '${_prefix}data_$key';
  String _metadataKey(String key) => '${_prefix}meta_$key';
  late final String _sizeKey;
  late final String _keysKey;

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    await _ensureInitialized();
    
    final keysToRemove = <String>[];
    
    for (final entry in _metadata.entries) {
      final key = entry.key;
      final metadata = entry.value;
      
      var shouldRemove = metadata.priority.index <= priorityOrBelow.index;
      shouldRemove &= (staleOnly && metadata.isStale) || !staleOnly;
      
      if (shouldRemove) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      await delete(key);
    }
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    await _ensureInitialized();
    
    final metadata = _metadata[key];
    if (metadata == null) return;
    
    if (staleOnly && !metadata.isStale) return;
    
    await _storage.delete(key: _namespaced(key));
    await _storage.delete(key: _metadataKey(key));
    
    _currentSize -= metadata.size;
    _metadata.remove(key);
    
    await _updateStorageMetadata();
  }

  @override
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    await _ensureInitialized();
    
    final responses = await getFromPath(pathPattern, queryParams: queryParams);
    
    for (final response in responses) {
      await delete(response.key);
    }
  }

  @override
  Future<bool> exists(String key) async {
    await _ensureInitialized();
    return _metadata.containsKey(key);
  }

  @override
  Future<CacheResponse?> get(String key) async {
    await _ensureInitialized();
    
    final metadata = _metadata[key];
    if (metadata == null) return null;
    
    // Check if expired
    if (metadata.isStale) {
      await delete(key);
      return null;
    }
    
    try {
      final data = await _storage.read(key: _namespaced(key));
      if (data == null) return null;
      
      final responseData = jsonDecode(data) as Map<String, dynamic>;
      final response = _reconstructCacheResponse(responseData);
      
      // Update access time for LRU behavior
      metadata.lastAccessed = DateTime.now();
      await _storage.write(key: _metadataKey(key), value: jsonEncode(metadata.toJson()));
      
      return response;
    } catch (e) {
      // If deserialization fails, remove the corrupted entry
      await delete(key);
      return null;
    }
  }

  @override
  Future<List<CacheResponse>> getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    await _ensureInitialized();
    
    final responses = <CacheResponse>[];
    
    for (final entry in _metadata.entries) {
      final key = entry.key;
      final metadata = entry.value;
      
      if (metadata.isStale) {
        await delete(key);
        continue;
      }
      
      if (_pathExists(metadata.url, pathPattern, queryParams: queryParams)) {
        final response = await get(key);
        if (response != null) {
          responses.add(response);
        }
      }
    }
    
    return responses;
  }

  @override
  Future<void> set(CacheResponse response) async {
    await _ensureInitialized();
    
    final key = response.key;
    final size = _computeSize(response);
    
    // Check if entry is too large
    if (size > _maxEntrySize) return;
    
    // Remove existing entry if it exists
    if (_metadata.containsKey(key)) {
      await delete(key);
    }
    
    // Check if we need to evict entries to make space
    while (_currentSize + size > _maxSize && _metadata.isNotEmpty) {
      final oldestKey = _getOldestKey();
      if (oldestKey != null) {
        await delete(oldestKey);
      } else {
        break;
      }
    }
    
    // Store the response data as a Map
    final responseData = _serializeCacheResponse(response);
    await _storage.write(key: _namespaced(key), value: jsonEncode(responseData));
    
    // Store metadata
    final metadata = _CacheEntry(
      key: key,
      url: response.url,
      priority: response.priority,
      size: size,
      createdAt: DateTime.now(),
      lastAccessed: DateTime.now(),
      expiresAt: null, // CacheResponse doesn't have expiresAt, we'll use maxStale from options
    );
    
    await _storage.write(key: _metadataKey(key), value: jsonEncode(metadata.toJson()));
    
    _metadata[key] = metadata;
    _currentSize += size;
    
    await _updateStorageMetadata();
  }

  @override
  Future<void> close() async {
    await _ensureInitialized();
    
    // Clear all cache entries
    final keys = _metadata.keys.toList();
    for (final key in keys) {
      await _storage.delete(key: _namespaced(key));
      await _storage.delete(key: _metadataKey(key));
    }
    
    _metadata.clear();
    _currentSize = 0;
    
    await _updateStorageMetadata();
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _loadMetadata();
      _initialized = true;
    }
  }

  Future<void> _loadMetadata() async {
    try {
      final sizeData = await _storage.read(key: _sizeKey);
      final keysData = await _storage.read(key: _keysKey);
      
      if (sizeData != null) {
        _currentSize = int.tryParse(sizeData) ?? 0;
      }
      
      if (keysData != null) {
        final keys = jsonDecode(keysData) as List<dynamic>;
        
        for (final key in keys) {
          final metadataData = await _storage.read(key: _metadataKey(key));
          if (metadataData != null) {
            try {
              final metadata = _CacheEntry.fromJson(jsonDecode(metadataData));
              _metadata[key] = metadata;
            } catch (e) {
              // Skip corrupted metadata
              continue;
            }
          }
        }
      }
    } catch (e) {
      // If loading fails, start with empty state
      _currentSize = 0;
      _metadata.clear();
    }
  }

  Future<void> _updateStorageMetadata() async {
    await _storage.write(key: _sizeKey, value: _currentSize.toString());
    await _storage.write(key: _keysKey, value: jsonEncode(_metadata.keys.toList()));
  }

  String? _getOldestKey() {
    if (_metadata.isEmpty) return null;
    
    String? oldestKey;
    DateTime? oldestTime;
    
    for (final entry in _metadata.entries) {
      if (oldestTime == null || entry.value.lastAccessed.isBefore(oldestTime)) {
        oldestTime = entry.value.lastAccessed;
        oldestKey = entry.key;
      }
    }
    
    return oldestKey;
  }

  int _computeSize(CacheResponse response) {
    var size = response.content?.length ?? 0;
    size += response.headers?.length ?? 0;
    return size;
  }

  bool _pathExists(String url, RegExp pathPattern, {Map<String, String?>? queryParams}) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      
      if (!pathPattern.hasMatch(path)) return false;
      
      if (queryParams != null) {
        for (final entry in queryParams.entries) {
          if (entry.value != null && uri.queryParameters[entry.key] != entry.value) {
            return false;
          }
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Serialize CacheResponse to a Map for storage
  Map<String, dynamic> _serializeCacheResponse(CacheResponse response) {
    return {
      'key': response.key,
      'url': response.url,
      'headers': response.headers,
      'content': response.content,
      'priority': response.priority.index,
      'date': response.date?.millisecondsSinceEpoch,
      'expires': response.expires?.millisecondsSinceEpoch,
      'lastModified': response.lastModified,
    };
  }

  /// Reconstruct CacheResponse from stored Map data
  CacheResponse _reconstructCacheResponse(Map<String, dynamic> data) {
    // Create a minimal CacheResponse with required parameters
    // Note: Some parameters may need to be provided from the original request context
    return CacheResponse(
      key: data['key'] as String,
      url: data['url'] as String,
      headers: data['headers'] as List<int>?,
      content: data['content'] as List<int>?,
      priority: CachePriority.values[data['priority'] as int],
      date: data['date'] != null ? DateTime.fromMillisecondsSinceEpoch(data['date'] as int) : null,
      expires: data['expires'] != null ? DateTime.fromMillisecondsSinceEpoch(data['expires'] as int) : null,
      lastModified: data['lastModified'],
      // Required parameters with default values
      cacheControl: CacheControl(maxAge: 7 * 24 * 60 * 60),
      eTag: '',
      maxStale: null,
      requestDate: DateTime.now(),
      responseDate: DateTime.now(),
    );
  }
}

/// Internal class to track cache entry metadata
class _CacheEntry {
  final String key;
  final String url;
  final CachePriority priority;
  final int size;
  final DateTime createdAt;
  DateTime lastAccessed;
  final DateTime? expiresAt;

  _CacheEntry({
    required this.key,
    required this.url,
    required this.priority,
    required this.size,
    required this.createdAt,
    required this.lastAccessed,
    this.expiresAt,
  });

  bool get isStale {
    if (expiresAt != null) {
      return DateTime.now().isAfter(expiresAt!);
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'url': url,
      'priority': priority.index,
      'size': size,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastAccessed': lastAccessed.millisecondsSinceEpoch,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
    };
  }

  factory _CacheEntry.fromJson(Map<String, dynamic> json) {
    return _CacheEntry(
      key: json['key'] as String,
      url: json['url'] as String,
      priority: CachePriority.values[json['priority'] as int],
      size: json['size'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      lastAccessed: DateTime.fromMillisecondsSinceEpoch(json['lastAccessed'] as int),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['expiresAt'] as int)
          : null,
    );
  }
}
