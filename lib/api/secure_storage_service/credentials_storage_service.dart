import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_client.dart';

/// Data class for saved credentials
class SavedCredentials {
  final String username;
  final String password;
  final bool remember;
  final bool hasCredentials;

  const SavedCredentials({
    required this.username,
    required this.password,
    required this.remember,
    required this.hasCredentials,
  });

  /// Create an empty SavedCredentials object
  factory SavedCredentials.empty() {
    return const SavedCredentials(
      username: '',
      password: '',
      remember: false,
      hasCredentials: false,
    );
  }

  /// Create a copy with updated values
  SavedCredentials copyWith({
    String? username,
    String? password,
    bool? remember,
    bool? hasCredentials,
  }) {
    return SavedCredentials(
      username: username ?? this.username,
      password: password ?? this.password,
      remember: remember ?? this.remember,
      hasCredentials: hasCredentials ?? this.hasCredentials,
    );
  }

  @override
  String toString() {
    return 'SavedCredentials(hasCredentials: $hasCredentials, remember: $remember, username: ${username.isNotEmpty ? '[REDACTED]' : '[EMPTY]'})';
  }
}


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
        await Future.wait([
          _storage.write(key: _usernameKey, value: username),
          _storage.write(key: _passwordKey, value: password),
          _storage.write(key: _rememberCredentialsKey, value: 'true'),
        ]);
        print('CredentialsStorageService: Credentials saved successfully');
      } else {
        await clearCredentials();
      }
      return true;
    } catch (e) {
      print('CredentialsStorageService: Error saving credentials: $e');
      return false;
    }
  }

  /// Load saved credentials
  Future<SavedCredentials> loadCredentials() async {
    try {
      final results = await Future.wait([
        _storage.read(key: _usernameKey),
        _storage.read(key: _passwordKey),
        _storage.read(key: _rememberCredentialsKey),
      ]);

      final String? username = results[0];
      final String? password = results[1];
      final String? rememberStr = results[2];
      final bool remember = rememberStr == 'true';

      if (remember && username != null && password != null) {
        print('CredentialsStorageService: Credentials loaded successfully');
        return SavedCredentials(
          username: username,
          password: password,
          remember: remember,
          hasCredentials: true,
        );
      }
      print('CredentialsStorageService: No saved credentials found');
      return SavedCredentials.empty();
    } catch (e) {
      print('CredentialsStorageService: Error loading credentials: $e');
      return SavedCredentials.empty();
    }
  }

  /// Clear all saved credentials
  Future<bool> clearCredentials() async {
    try {
      await Future.wait([
        _storage.delete(key: _usernameKey),
        _storage.delete(key: _passwordKey),
        _storage.delete(key: _rememberCredentialsKey),
      ]);
      print('CredentialsStorageService: Credentials cleared successfully');
      return true;
    } catch (e) {
      print('CredentialsStorageService: Error clearing credentials: $e');
      return false;
    }
  }

  /// Check if credentials are saved
  Future<bool> hasCredentials() async {
    try {
      final remember = await _storage.read(key: _rememberCredentialsKey);
      return remember == 'true';
    } catch (e) {
      print('CredentialsStorageService: Error checking credentials: $e');
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


