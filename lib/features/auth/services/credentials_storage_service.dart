import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import '../../API/storage/storage_client.dart';
import '../models/saved_credentials.dart';

final logger = Logger('CredentialsStorage');

/// Handles secure storage operations for credentials and related flags.
class CredentialsStorageService {
  static final CredentialsStorageService _instance =
      CredentialsStorageService._internal();
  factory CredentialsStorageService() => _instance;
  CredentialsStorageService._internal();

  // Keys
  static const String _usernameKey = 'saved_username';
  static const String _passwordKey = 'saved_password';
  static const String _rememberCredentialsKey = 'remember_credentials';
  static const String _autoLoginKey = 'auto_login';

  FlutterSecureStorage get _storage => StorageClient.instance;

  /// Save user credentials securely
  Future<bool> saveCredentials({
    required String username,
    required String password,
    required bool remember,
    required bool autoLogin,
  }) async {
    try {
      if (remember) {
        await _storage.write(key: _usernameKey, value: username);
        await _storage.write(key: _passwordKey, value: password);
        await _storage.write(key: _rememberCredentialsKey, value: 'true');
        await _storage.write(key: _autoLoginKey, value: autoLogin.toString());
        logger.info('Credentials saved successfully');
      } else {
        await clearCredentials();
      }
      return true;
    } catch (e) {
      logger.severe('Error saving credentials: $e');
      return false;
    }
  }

  /// Set auto-login state independently
  Future<bool> setAutoLogin(bool enabled) async {
    try {
      await _storage.write(key: _autoLoginKey, value: enabled.toString());
      logger.info('Auto-login state set to $enabled');
      return true;
    } catch (e) {
      logger.severe('Error setting auto-login state: $e');
      return false;
    }
  }

  /// Load saved credentials
  Future<SavedCredentials> loadCredentials() async {
    try {
      final username = await _storage.read(key: _usernameKey);
      final password = await _storage.read(key: _passwordKey);
      final rememberStr = await _storage.read(key: _rememberCredentialsKey);
      final autoLoginStr = await _storage.read(key: _autoLoginKey);
      
      final remember = rememberStr == 'true';
      final autoLogin = autoLoginStr == 'true';

      if (remember && username != null && password != null) {
        logger.info('Credentials loaded successfully');
        return SavedCredentials(
          username: username,
          password: password,
          remember: remember,
          autoLogin: autoLogin,
          hasCredentials: true,
        );
      }
      logger.warning('No saved credentials found');
      return SavedCredentials.empty();
    } catch (e) {
      logger.severe('Error loading credentials: $e');
      return SavedCredentials.empty();
    }
  }

  /// Clear all saved credentials
  Future<bool> clearCredentials() async {
    try {
      await _storage.delete(key: _usernameKey);
      await _storage.delete(key: _passwordKey);
      await _storage.delete(key: _rememberCredentialsKey);
      await _storage.delete(key: _autoLoginKey);
      logger.info('Credentials cleared successfully');
      return true;
    } catch (e) {
      logger.severe('Error clearing credentials: $e');
      return false;
    }
  }

  /// Check if credentials are saved
  Future<bool> hasCredentials() async {
    try {
      final remember = await _storage.read(key: _rememberCredentialsKey);
      return remember == 'true';
    } catch (e) {
      logger.severe('Error checking credentials: $e');
      return false;
    }
  }
}
