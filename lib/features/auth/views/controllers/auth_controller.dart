import 'package:flutter/material.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/auth/services/auth_service.dart';
import '../../../shared/views/custom_snackbar/snackbar_utils.dart';
import '../../../shared/views/error/error_dialog.dart';
import 'package:logging/logging.dart';

final logger = Logger('AuthController');

class AuthController extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Core authentication logic
  Future<bool> performAuthentication(
    BuildContext context, {
    required String username,
    required String password,
    required Object captchaData,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final loginResult = await di<AuthService>().login(
        username: username,
        password: password,
        captchaData: captchaData,
      );

      _isLoading = false;
      notifyListeners();

      if (loginResult.isSuccess) {
        logger.info('AuthController: Successfully logged in as $username');
        if (!context.mounted) {
          logger.warning('AuthController: Context is not mounted');
          return false;
        }

        // Show success message
        SnackbarUtils.showSuccess(
          context,
          'Successfully logged in as $username!',
        );

        // Navigate to home page
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }

        return true;
      } else {
        logger.warning('AuthController: Login failed: ${loginResult.message}');

        // Error dialog with rich details and copy action
        if (!context.mounted) return false;
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

        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      logger.severe('AuthController: Login exception: $e');
      if (!context.mounted) {
        logger.warning('AuthController: Context is not mounted');
        return false;
      }
      SnackbarUtils.showError(context, 'Login error: $e');
      return false;
    }
  }
}
