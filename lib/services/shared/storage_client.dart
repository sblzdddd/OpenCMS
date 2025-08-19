import 'package:cookie_jar/cookie_jar.dart' show PersistCookieJar, Storage;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart' show Cookie;
import '../../data/constants/api_constants.dart';

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
  static final Storage cookieStorage = _SecureCookieStorage(instance);

  /// Shared [PersistCookieJar] that persists into secure storage on all
  /// supported platforms. Session cookies are persisted by default.
  static final PersistCookieJar cookieJar = PersistCookieJar(
    persistSession: true,
    storage: cookieStorage,
  );

  static Future<List<Cookie>> get currentCookies async {
    final newCMSCookies = await StorageClient.cookieJar.loadForRequest(Uri.parse(ApiConstants.baseApiUrl));
    final legacyCookies = await StorageClient.cookieJar.loadForRequest(Uri.parse(ApiConstants.legacyCMSBaseUrl));
    return [...newCMSCookies, ...legacyCookies];
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

/// A cookie_jar [Storage] implementation backed by [FlutterSecureStorage].
///
/// Keys are namespaced by a computed prefix to keep separate stores per
/// (persistSession, ignoreExpires) configuration.
class _SecureCookieStorage implements Storage {
  _SecureCookieStorage(this._secureStorage);

  final FlutterSecureStorage _secureStorage;
  String _prefix = 'cj4_ie0_ps1_';
  bool _initialized = false;

  String _namespaced(String key) => '$_prefix$key';

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {
    // Match FileStorage path scheme logically so different configs don't clash
    _prefix = 'cj4_ie${ignoreExpires ? 1 : 0}_ps${persistSession ? 1 : 0}_';
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

