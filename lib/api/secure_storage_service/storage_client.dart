import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
      // Additional Android security options
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      // Additional iOS security options
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    lOptions: LinuxOptions(
      // Additional Linux security options
    ),
    wOptions: WindowsOptions(
      // Additional Windows security options
    ),
    mOptions: MacOsOptions(
      // Additional macOS security options
    ),
  );
}


