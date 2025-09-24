import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../shared/storage_client.dart';
import '../../data/models/auth/saved_credentials.dart';


/// Handles secure storage operations for credentials and related flags.
class CredentialsStorageService {
  static final CredentialsStorageService _instance = CredentialsStorageService._internal();
  factory CredentialsStorageService() => _instance;
  CredentialsStorageService._internal();

  // Keys
  static const String _usernameKey = 'saved_username';
  static const String _passwordKey = 'saved_password';
  static const String _rememberCredentialsKey = 'remember_credentials';

  FlutterSecureStorage get _storage => StorageClient.instance;

  /// Save user credentials securely
  Future<bool> saveCredentials({
    required String username,
    required String password,
    required bool remember,
  }) async {
    try {
      if (remember) {
          await _storage.write(key: _usernameKey, value: username);
          await _storage.write(key: _passwordKey, value: password);
          await _storage.write(key: _rememberCredentialsKey, value: 'true');
        debugPrint('CredentialsStorageService: Credentials saved successfully');
      } else {
        await clearCredentials();
      }
      return true;
    } catch (e) {
      debugPrint('CredentialsStorageService: Error saving credentials: $e');
      return false;
    }
  }

  /// Load saved credentials
  Future<SavedCredentials> loadCredentials() async {
    try {
      final username = await _storage.read(key: _usernameKey);
      final password = await _storage.read(key: _passwordKey);
      final rememberStr = await _storage.read(key: _rememberCredentialsKey);
      final remember = rememberStr == 'true';

      if (remember && username != null && password != null) {
        debugPrint('CredentialsStorageService: Credentials loaded successfully');
        return SavedCredentials(
          username: username,
          password: password,
          remember: remember,
          hasCredentials: true,
        );
      }
      debugPrint('CredentialsStorageService: No saved credentials found');
      return SavedCredentials.empty();
    } catch (e) {
      debugPrint('CredentialsStorageService: Error loading credentials: $e');
      return SavedCredentials.empty();
    }
  }

  /// Clear all saved credentials
  Future<bool> clearCredentials() async {
    try {
      await _storage.delete(key: _usernameKey);
      await _storage.delete(key: _passwordKey);
      await _storage.delete(key: _rememberCredentialsKey);
      debugPrint('CredentialsStorageService: Credentials cleared successfully');
      return true;
    } catch (e) {
      debugPrint('CredentialsStorageService: Error clearing credentials: $e');
      return false;
    }
  }

  /// Check if credentials are saved
  Future<bool> hasCredentials() async {
    try {
      final remember = await _storage.read(key: _rememberCredentialsKey);
      return remember == 'true';
    } catch (e) {
      debugPrint('CredentialsStorageService: Error checking credentials: $e');
      return false;
    }
  }

  /// Get debug information about stored data (without exposing sensitive info)
  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final bool hasUsername = await _storage.containsKey(key: _usernameKey);
      final bool hasPassword = await _storage.containsKey(key: _passwordKey);
      final String? remember = await _storage.read(key: _rememberCredentialsKey);

      return {
        'hasUsername': hasUsername,
        'hasPassword': hasPassword,
        'rememberCredentials': remember == 'true',
        'storageAvailable': true,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'storageAvailable': false,
      };
    }
  }
}


