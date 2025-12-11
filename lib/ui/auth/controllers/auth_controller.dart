import 'package:flutter/material.dart';
import 'package:opencms/features/core/di/locator.dart';
import '../../../services/services.dart';
import '../../shared/custom_snackbar/snackbar_utils.dart';
import '../../shared/error/error_dialog.dart';

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
        debugPrint('AuthController: Successfully logged in as $username');
        if (!context.mounted) {
          debugPrint('AuthController: Context is not mounted');
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
        debugPrint('AuthController: Login failed: ${loginResult.message}');

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

      debugPrint('AuthController: Login exception: $e');
      if (!context.mounted) {
        debugPrint('AuthController: Context is not mounted');
        return false;
      }
      SnackbarUtils.showError(context, 'Login error: $e');
      return false;
    }
  }
}
