import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage Client providing a shared instance of [FlutterSecureStorage]
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
}
