import 'package:flutter/material.dart';
import '../../../services/services.dart';
import '../../shared/custom_snackbar/snackbar_utils.dart';
import '../../shared/error/error_dialog.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
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
      final loginResult = await _authService.login(
        username: username,
        password: password,
        captchaData: captchaData,
      );
      
      _isLoading = false;
      notifyListeners();

      if (loginResult.isSuccess) {
        print('Successfully logged in as $username');

        // Show success message
        SnackbarUtils.showSuccess(
          context,
          'Successfully logged in as $username!',
        );
        
        // Ensure user info is fetched so Home can display en_name immediately
        try {
          await _authService.fetchAndSetCurrentUserInfo();
        } catch (_) {}

        // Navigate to home page
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
        
        return true;
      } else {
        print('Login failed: ${loginResult.message}');

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

      print('Login exception: $e');
      SnackbarUtils.showError(context, 'Login error: $e');
      return false;
    }
  }
}
