import 'package:flutter/material.dart';
import '../../../shared/views/custom_snackbar/snackbar_utils.dart';
import 'credentials_manager.dart';
import 'captcha_manager.dart';
import 'auth_controller.dart';
import 'package:logging/logging.dart';

final logger = Logger('LoginFormController');

/// Controller responsible for coordinating the login form logic
/// Manages the interaction between credentials, captcha, and authentication
class LoginFormController extends ChangeNotifier {
  late final CredentialsManager _credentialsManager;
  late final CaptchaManager _captchaManager;
  late final AuthController _authController;

  CredentialsManager get credentialsManager => _credentialsManager;
  CaptchaManager get captchaManager => _captchaManager;
  AuthController get authController => _authController;

  /// Combined loading state from all managers
  bool get isLoading =>
      _authController.isLoading || _captchaManager.isAutoSolving;
  bool get isLoadingCredentials => _credentialsManager.isLoadingCredentials;

  /// Initialize all managers and set up listeners
  void initialize() {
    _credentialsManager = CredentialsManager();
    _captchaManager = CaptchaManager();
    _authController = AuthController();

    // Listen to changes from all managers
    _credentialsManager.addListener(_notifyListeners);
    _captchaManager.addListener(_notifyListeners);
    _authController.addListener(_notifyListeners);
  }

  void _notifyListeners() {
    notifyListeners();
  }

  /// Load saved credentials when the form initializes
  Future<void> loadSavedCredentials({
    required TextEditingController usernameController,
    required TextEditingController passwordController,
  }) async {
    await _credentialsManager.loadSavedCredentials(
      usernameController: usernameController,
      passwordController: passwordController,
    );
  }

  /// Clear all form data and state
  void clearForm(
    BuildContext context, {
    required TextEditingController usernameController,
    required TextEditingController passwordController,
    required GlobalKey captchaKey,
  }) {
    usernameController.clear();
    passwordController.clear();
    _captchaManager.resetCaptcha();
    _captchaManager.resetCaptchaUI(captchaKey);
    _credentialsManager.clearRememberMe();

    SnackbarUtils.showSuccess(context, 'Form cleared');
  }

  /// Perform the complete login flow
  Future<void> performLogin(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required TextEditingController usernameController,
    required TextEditingController passwordController,
    required GlobalKey captchaKey,
  }) async {
    // Check form validation
    if (!formKey.currentState!.validate()) {
      return;
    }

    final username = usernameController.text.trim();
    final password = passwordController.text;

    // Try to auto-solve captcha first if not already verified
    if (!_captchaManager.isCaptchaVerified ||
        _captchaManager.captchaData == null) {
      logger.fine('Attempting auto captcha solve');
      final autoSolveSuccess = await _captchaManager.autoSolveCaptcha(username);

      if (!autoSolveSuccess) {
        // Fallback to manual captcha if auto-solve fails
        logger.fine('Auto captcha solve failed, falling back to manual verification');
        _captchaManager.triggerManualVerification(
          captchaKey,
          onSuccess: (data) {
            // Retry login after manual captcha
            performLogin(
              context,
              formKey: formKey,
              usernameController: usernameController,
              passwordController: passwordController,
              captchaKey: captchaKey,
            );
          },
        );
        return;
      }
    }

    // Check if captcha is verified
    if (!_captchaManager.isCaptchaVerified ||
        _captchaManager.captchaData == null) {
      if (!context.mounted) {
        logger.warning('Context is not mounted');
        return;
      }
      SnackbarUtils.showWarning(
        context,
        'Please complete captcha verification first',
      );
      return;
    }
    if (!context.mounted) {
      logger.warning('Context is not mounted');
      return;
    }
    // Perform authentication
    final success = await _authController.performAuthentication(
      context,
      username: username,
      password: password,
      captchaData: _captchaManager.captchaData!,
    );

    if (success) {
      // Handle credentials saving
      await _credentialsManager.handleCredentialsSaving(
        username: username,
        password: password,
      );
    } else {
      // Reset captcha on authentication failure
      _captchaManager.resetCaptcha();
      _captchaManager.resetCaptchaUI(captchaKey);
    }
  }

  @override
  void dispose() {
    _credentialsManager.removeListener(_notifyListeners);
    _captchaManager.removeListener(_notifyListeners);
    _authController.removeListener(_notifyListeners);

    _credentialsManager.dispose();
    _captchaManager.dispose();
    _authController.dispose();
    super.dispose();
  }
}
