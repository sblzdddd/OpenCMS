import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Secure Storage Service
/// 
/// Handles secure storage operations for sensitive data like credentials.
/// Uses flutter_secure_storage to securely store data in the device's keychain/keystore.
/// 
/// Features:
/// - Credential storage and retrieval
/// - Secure deletion of stored data
/// - Error handling and fallback mechanisms

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // FlutterSecureStorage instance with additional security options
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
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

  // Storage keys
  static const String _usernameKey = 'saved_username';
  static const String _passwordKey = 'saved_password';
  static const String _rememberCredentialsKey = 'remember_credentials';
  static const String _cookiesKey = 'session_cookies_json';
  static const String _quickActionsKey = 'quick_actions_preferences';

  /// Save user credentials securely
  /// 
  /// [username] - The username to save
  /// [password] - The password to save
  /// [remember] - Whether to remember these credentials
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
        print('SecureStorageService: Credentials saved successfully');
      } else {
        // If remember is false, clear any existing credentials
        await clearCredentials();
      }
      return true;
    } catch (e) {
      print('SecureStorageService: Error saving credentials: $e');
      return false;
    }
  }

  /// Persist cookies as JSON in secure storage
  Future<bool> saveCookies(Map<String, String> cookies) async {
    try {
      final jsonString = jsonEncode(cookies);
      await _storage.write(key: _cookiesKey, value: jsonString);
      print('SecureStorageService: Cookies saved (${cookies.length})');
      return true;
    } catch (e) {
      print('SecureStorageService: Error saving cookies: $e');
      return false;
    }
  }

  /// Load persisted cookies
  Future<Map<String, String>> loadCookies() async {
    try {
      final jsonString = await _storage.read(key: _cookiesKey);
      if (jsonString == null || jsonString.isEmpty) return <String, String>{};
      final decoded = jsonDecode(jsonString);
      if (decoded is Map) {
        return decoded.map<String, String>((key, value) => MapEntry(key.toString(), value.toString()));
      }
      return <String, String>{};
    } catch (e) {
      print('SecureStorageService: Error loading cookies: $e');
      return <String, String>{};
    }
  }

  /// Clear persisted cookies
  Future<bool> clearCookies() async {
    try {
      await _storage.delete(key: _cookiesKey);
      print('SecureStorageService: Cookies cleared');
      return true;
    } catch (e) {
      print('SecureStorageService: Error clearing cookies: $e');
      return false;
    }
  }

  /// Whether cookies exist in storage
  Future<bool> hasCookies() async {
    try {
      final value = await _storage.read(key: _cookiesKey);
      return value != null && value.isNotEmpty;
    } catch (e) {
      print('SecureStorageService: Error checking cookies: $e');
      return false;
    }
  }

  /// Load saved credentials
  /// 
  /// Returns a [SavedCredentials] object with the saved data
  Future<SavedCredentials> loadCredentials() async {
    try {
      final results = await Future.wait([
        _storage.read(key: _usernameKey),
        _storage.read(key: _passwordKey),
        _storage.read(key: _rememberCredentialsKey),
      ]);

      final username = results[0];
      final password = results[1];
      final rememberStr = results[2];
      final remember = rememberStr == 'true';

      if (remember && username != null && password != null) {
        print('SecureStorageService: Credentials loaded successfully');
        return SavedCredentials(
          username: username,
          password: password,
          remember: remember,
          hasCredentials: true,
        );
      } else {
        print('SecureStorageService: No saved credentials found');
        return SavedCredentials.empty();
      }
    } catch (e) {
      print('SecureStorageService: Error loading credentials: $e');
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
      print('SecureStorageService: Credentials cleared successfully');
      return true;
    } catch (e) {
      print('SecureStorageService: Error clearing credentials: $e');
      return false;
    }
  }

  /// Check if credentials are saved
  Future<bool> hasCredentials() async {
    try {
      final remember = await _storage.read(key: _rememberCredentialsKey);
      return remember == 'true';
    } catch (e) {
      print('SecureStorageService: Error checking credentials: $e');
      return false;
    }
  }

  /// Get debug information about stored data (without exposing sensitive info)
  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final hasUsername = await _storage.containsKey(key: _usernameKey);
      final hasPassword = await _storage.containsKey(key: _passwordKey);
      final remember = await _storage.read(key: _rememberCredentialsKey);

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

  /// Save quick actions preferences
  /// 
  /// [actionIds] - Ordered list of action IDs representing user's quick actions
  Future<bool> saveQuickActionsPreferences(List<String> actionIds) async {
    try {
      final jsonString = jsonEncode(actionIds);
      await _storage.write(key: _quickActionsKey, value: jsonString);
      print('SecureStorageService: Quick actions preferences saved (${actionIds.length} items)');
      return true;
    } catch (e) {
      print('SecureStorageService: Error saving quick actions preferences: $e');
      return false;
    }
  }

  /// Load quick actions preferences
  /// 
  /// Returns ordered list of action IDs, or null if no preferences saved
  Future<List<String>?> loadQuickActionsPreferences() async {
    try {
      final jsonString = await _storage.read(key: _quickActionsKey);
      if (jsonString == null || jsonString.isEmpty) return null;
      
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        final actionIds = decoded.map<String>((item) => item.toString()).toList();
        print('SecureStorageService: Quick actions preferences loaded (${actionIds.length} items)');
        return actionIds;
      }
      return null;
    } catch (e) {
      print('SecureStorageService: Error loading quick actions preferences: $e');
      return null;
    }
  }

  /// Clear quick actions preferences
  Future<bool> clearQuickActionsPreferences() async {
    try {
      await _storage.delete(key: _quickActionsKey);
      print('SecureStorageService: Quick actions preferences cleared');
      return true;
    } catch (e) {
      print('SecureStorageService: Error clearing quick actions preferences: $e');
      return false;
    }
  }

  /// Check if quick actions preferences exist
  Future<bool> hasQuickActionsPreferences() async {
    try {
      final value = await _storage.read(key: _quickActionsKey);
      return value != null && value.isNotEmpty;
    } catch (e) {
      print('SecureStorageService: Error checking quick actions preferences: $e');
      return false;
    }
  }

  /// Clear all secure storage (use with caution)
  Future<bool> clearAllStorage() async {
    try {
      await _storage.deleteAll();
      print('SecureStorageService: All storage cleared');
      return true;
    } catch (e) {
      print('SecureStorageService: Error clearing all storage: $e');
      return false;
    }
  }
}

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
