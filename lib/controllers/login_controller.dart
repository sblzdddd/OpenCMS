import 'package:flutter/material.dart';
import '../api/api.dart';
import '../components/common/snackbar_utils.dart';
import '../components/common/error_dialog.dart';

/// Controller to manage login flow, captcha handling, and credential persistence
class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SecureStorageService _secureStorageService = SecureStorageService();

  bool _isCaptchaVerified = false;
  Object? _captchaData;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _isLoadingCredentials = true;

  bool get isCaptchaVerified => _isCaptchaVerified;
  Object? get captchaData => _captchaData;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  bool get isLoadingCredentials => _isLoadingCredentials;

  set rememberMe(bool value) {
    if (_rememberMe != value) {
      _rememberMe = value;
      notifyListeners();
    }
  }

  /// Handle captcha state changes from the CaptchaInput component
  void onCaptchaStateChanged(bool isVerified, Object? data) {
    _isCaptchaVerified = isVerified;
    _captchaData = data;
    notifyListeners();

    print('Captcha state changed - Verified: $isVerified, Data: ${data?.runtimeType}');
  }

  /// Clear all form data and state (username, password, captcha, loading, remember me)
  void clearForm({
    required TextEditingController usernameController,
    required TextEditingController passwordController,
    GlobalKey? captchaKey,
    required BuildContext context,
  }) {
    usernameController.clear();
    passwordController.clear();
    _isCaptchaVerified = false;
    _captchaData = null;
    _isLoading = false;
    _rememberMe = false;
    notifyListeners();

    // Call CaptchaInput.resetVerification() via dynamic to avoid tight coupling
    (captchaKey?.currentState as dynamic)?.resetVerification();

    if (context.mounted) {
      SnackbarUtils.showSuccess(context, 'Form cleared');
    }
  }

  /// Load saved credentials when the page initializes
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
        print('Loaded saved credentials for user: ${savedCredentials.username}');
      }
    } catch (e) {
      print('Error loading saved credentials: $e');
    } finally {
      _isLoadingCredentials = false;
      notifyListeners();
    }
  }

  /// Full login flow including optional auto-solve and manual captcha fallback
  Future<void> performLogin(
    BuildContext context, {
    required String username,
    required String password,
    required GlobalKey captchaKey,
  }) async {
    // Attempt auto-solve via solvecaptcha when enabled and captcha not yet verified
    if (!_isCaptchaVerified || _captchaData == null) {
      final settings = CaptchaSettingsService();
      final loginMethod = await settings.getLoginMethod();
      if (loginMethod == CaptchaVerificationMethod.solveCaptcha) {
        final apiKey = await settings.getSolveCaptchaApiKey();
        if (apiKey == null || apiKey.trim().isEmpty) {
          if (context.mounted) {
            SnackbarUtils.showWarning(
              context,
              'Solvecaptcha API key missing. Please configure it in captcha settings.',
            );
          }
        } else {
          _isLoading = true;
          notifyListeners();
          final solver = SolveCaptchaService();
          final result = await solver.solveWithApiKey(apiKey.trim());
          _isLoading = false;
          notifyListeners();
          if (result.isSuccess && result.captchaData != null) {
            _isCaptchaVerified = true;
            _captchaData = result.captchaData;
            notifyListeners();
            if (context.mounted) {
              SnackbarUtils.showSuccess(
                context,
                'Captcha auto-solved by solvecaptcha',
              );
            }
          } else {
            if (context.mounted) {
              SnackbarUtils.showWarning(
                context,
                'Auto-solve failed: ${result.message}. Opening manual captcha...',
              );

              // Trigger manual captcha dialog as fallback
              (captchaKey.currentState as dynamic)?.triggerManualVerification(
                onSuccess: (data) {
                  _isCaptchaVerified = true;
                  _captchaData = data;
                  notifyListeners();
                  // attempt to login after manual captcha
                  performLogin(
                    context,
                    username: username,
                    password: password,
                    captchaKey: captchaKey,
                  );
                },
              );
              return; // Exit early to wait for manual captcha completion
            }
          }
        }
      }
    }

    if (!_isCaptchaVerified || _captchaData == null) {
      SnackbarUtils.showWarning(
        context,
        'Please complete captcha verification first',
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final loginResult = await _authService.login(
        username: username,
        password: password,
        captchaData: _captchaData!,
      );
      _isLoading = false;
      notifyListeners();

      if (loginResult.isSuccess) {
        print('Successfully logged in as $username');

        // Save credentials if remember me is checked
        if (_rememberMe) {
          try {
            await _secureStorageService.saveCredentials(
              username: username,
              password: password,
              remember: _rememberMe,
            );
            print('Credentials saved securely');
          } catch (e) {
            print('Error saving credentials: $e');
          }
        } else {
          // Clear any previously saved credentials if remember me is unchecked
          try {
            await _secureStorageService.clearCredentials();
            print('Previously saved credentials cleared');
          } catch (e) {
            print('Error clearing credentials: $e');
          }
        }

        // Show success message
        SnackbarUtils.showSuccess(
          context,
          'Successfully logged in as $username!',
        );
        
        // Ensure user info is fetched so Home can display en_name immediately
        try {
          await _authService.fetchAndSetCurrentUserInfo();
        } catch (_) {}

        // Print session debug info
        final debugInfo = _authService.getSessionDebugInfo();
        print('Session Debug Info: $debugInfo');

        // Navigate to home page
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        print('Login failed: ${loginResult.message}');

        // Error dialog with rich details and copy action
        if (!context.mounted) return;
        await ErrorDialog.show(
          context: context,
          title: 'Login Failed',
          message: loginResult.message,
          additionalData: {
            'resultType': loginResult.resultType.toString(),
            'data': loginResult.data,
            'debugInfo': loginResult.debugInfo ?? {},
          },
        );

        // Reset captcha on any error to force re-verification
        _isCaptchaVerified = false;
        _captchaData = null;
        notifyListeners();
        (captchaKey.currentState as dynamic)?.resetVerification();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      print('Login exception: $e');

      SnackbarUtils.showError(context, 'Login error: $e');
    }
  }

  /// Utility to expose debug info for tests or logs
  Map<String, dynamic> getSessionDebugInfo() {
    return _authService.getSessionDebugInfo();
  }
}


