import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:synchronized/synchronized.dart';

/// Storage Client providing a shared instance of [FlutterSecureStorage]
/// wrapped with a [Lock] to ensure thread safety.
class StorageClient {
  StorageClient._();

  static final StorageClient instance = StorageClient._();

  final _lock = Lock();
  
  /// Shared [FlutterSecureStorage] instance with platform-specific options
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
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

  Future<String?> read({required String key}) async {
    return _lock.synchronized(() => _storage.read(key: key));
  }

  Future<Map<String, String>> readAll() async {
    return _lock.synchronized(() => _storage.readAll());
  }

  Future<void> write({required String key, required String value}) async {
    await _lock.synchronized(() => _storage.write(key: key, value: value));
  }

  Future<void> delete({required String key}) async {
    await _lock.synchronized(() => _storage.delete(key: key));
  }

  Future<void> deleteAll() async {
    await _lock.synchronized(() => _storage.deleteAll());
  }
}
