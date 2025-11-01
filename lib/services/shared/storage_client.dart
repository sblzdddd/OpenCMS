import 'package:cookie_jar/cookie_jar.dart' show PersistCookieJar, Storage;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart' show Cookie;

/// Storage Client
///
/// Provides a single configured instance of [FlutterSecureStorage]
/// to be used across atomic storage services.
class StorageClient {
  const StorageClient._();

  /// Shared [FlutterSecureStorage] instance with platform-specific options
  static const FlutterSecureStorage instance = FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(),
    mOptions: MacOsOptions(),
  );

  /// Cookie-jar compatible storage backed by [FlutterSecureStorage].
  static final Storage cookieStorage = _SecureStorageBase(instance, 'cj4');

  /// Cache storage backed by [FlutterSecureStorage].
  static final Storage cacheStorage = _SecureStorageBase(instance, 'ch4');

  /// Shared [PersistCookieJar] that persists into secure storage on all
  /// supported platforms. Session cookies are persisted by default.
  static final PersistCookieJar cookieJar = PersistCookieJar(
    persistSession: true,
    storage: cookieStorage,
  );

  static Future<List<Cookie>> get currentCookies async {
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
      await StorageClient.cookieJar.saveFromResponse(
        Uri.parse(cookie.domain ?? ''),
        [cookie],
      );
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
    _prefix =
        '${_prefixId}_ie${ignoreExpires ? 1 : 0}_ps${persistSession ? 1 : 0}_';
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
