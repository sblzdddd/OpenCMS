import 'package:flutter/material.dart';
import '../../../services/services.dart';
import '../../shared/custom_snackbar/snackbar_utils.dart';

/// Component responsible for managing captcha verification and auto-solving
class CaptchaManager extends ChangeNotifier {
  bool _isCaptchaVerified = false;
  Object? _captchaData;

  bool get isCaptchaVerified => _isCaptchaVerified;
  Object? get captchaData => _captchaData;

  /// Handle captcha state changes from the CaptchaInput component
  void onCaptchaStateChanged(bool isVerified, Object? data) {
    _isCaptchaVerified = isVerified;
    _captchaData = data;
    notifyListeners();

    print('Captcha state changed - Verified: $isVerified, Data: ${data?.runtimeType}');
  }

  /// Reset captcha verification state
  void resetCaptcha() {
    _isCaptchaVerified = false;
    _captchaData = null;
    notifyListeners();
  }

  /// Attempt to auto-solve captcha using solvecaptcha service
  Future<bool> attemptAutoSolve(BuildContext context) async {
    final settings = CaptchaSettingsService();
    final loginMethod = await settings.getLoginMethod();
    
    if (loginMethod != CaptchaVerificationMethod.solveCaptcha) {
      return false;
    }

    final apiKey = await settings.getSolveCaptchaApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) {
      if (context.mounted) {
        SnackbarUtils.showWarning(
          context,
          'Solvecaptcha API key missing. Please configure it in captcha settings.',
        );
      }
      return false;
    }

    final solver = SolveCaptchaService();
    final result = await solver.solveWithApiKey(apiKey.trim());
    
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
      return true;
    } else {
      if (context.mounted) {
        SnackbarUtils.showWarning(
          context,
          'Auto-solve failed: ${result.message}. Please verify manually.',
        );
      }
      return false;
    }
  }

  /// Trigger manual captcha verification
  void triggerManualVerification(
    GlobalKey captchaKey, {
    Function(Object?)? onSuccess,
  }) {
    (captchaKey.currentState as dynamic)?.triggerManualVerification(
      onSuccess: (data) {
        _isCaptchaVerified = true;
        _captchaData = data;
        notifyListeners();
        onSuccess?.call(data);
      },
    );
  }

  /// Reset captcha UI component
  void resetCaptchaUI(GlobalKey captchaKey) {
    (captchaKey.currentState as dynamic)?.resetVerification();
  }
}
