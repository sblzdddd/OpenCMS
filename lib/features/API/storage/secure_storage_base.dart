import 'package:cookie_jar/cookie_jar.dart' show Storage;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageBase implements Storage {
  SecureStorageBase(this._secureStorage, this._prefixId);

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
    for (final key in keys) {
      await _secureStorage.delete(key: _namespaced(key));
    }
  }

  Future<void> clear() async {
    await _ensureInitialized();
    final all = await _secureStorage.readAll();
    for (final key in all.keys) {
      if (key.startsWith(_prefix)) {
        await _secureStorage.delete(key: key);
      }
    }
  }
}
