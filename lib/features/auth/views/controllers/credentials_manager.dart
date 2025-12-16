import 'package:flutter/material.dart';
import '../../services/credentials_storage_service.dart';

/// Component responsible for managing credential loading and saving
class CredentialsManager extends ChangeNotifier {
  final CredentialsStorageService _secureStorageService =
      CredentialsStorageService();

  bool _isLoadingCredentials = true;
  bool _rememberMe = false;

  bool get isLoadingCredentials => _isLoadingCredentials;
  bool get rememberMe => _rememberMe;

  set rememberMe(bool value) {
    if (_rememberMe != value) {
      _rememberMe = value;
      notifyListeners();
    }
  }

  /// Load saved credentials when the form initializes
  Future<void> loadSavedCredentials({
    required TextEditingController usernameController,
    required TextEditingController passwordController,
  }) async {
    try {
      final savedCredentials = await _secureStorageService.loadCredentials();
      if (savedCredentials.hasCredentials) {
        usernameController.text = savedCredentials.username;
        passwordController.text = savedCredentials.password;
        _rememberMe = savedCredentials.remember;
        debugPrint(
          'CredentialsManager: Loaded saved credentials for user: ${savedCredentials.username}',
        );
      }
    } catch (e) {
      debugPrint('CredentialsManager: Error loading saved credentials: $e');
    } finally {
      _isLoadingCredentials = false;
      notifyListeners();
    }
  }

  /// Save credentials if remember me is enabled, otherwise clear them
  Future<void> handleCredentialsSaving({
    required String username,
    required String password,
  }) async {
    if (_rememberMe) {
      try {
        await _secureStorageService.saveCredentials(
          username: username,
          password: password,
          remember: _rememberMe,
        );
        debugPrint('CredentialsManager: Credentials saved securely');
      } catch (e) {
        debugPrint('CredentialsManager: Error saving credentials: $e');
      }
    } else {
      // Clear any previously saved credentials if remember me is unchecked
      try {
        await _secureStorageService.clearCredentials();
        debugPrint('CredentialsManager: Previously saved credentials cleared');
      } catch (e) {
        debugPrint('CredentialsManager: Error clearing credentials: $e');
      }
    }
  }

  /// Clear the remember me state
  void clearRememberMe() {
    _rememberMe = false;
    notifyListeners();
  }
}
